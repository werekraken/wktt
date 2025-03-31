# Exploring Kernel Networking: BPF Hook Points, Part 1 - Elementary, my dear Watson.
#   ↳ Basic anatomy of a BPF program.

There is an abundance of information available on bpf (documentation, examples, selftests, projects, blog posts, articles, presentations, etc.). Information is a good thing, especially on a complex topic such as bpf, but the sheer volume can make getting started difficult.

This series of blog posts is intended to help with exactly that, specifically for networking hook points. We will gently introduce you to a few foundational bpf concepts in the context of networking and, in doing so, equip you to more easily consume additional information on the subject.


## Why is BPF useful?

The linux kernel is used in all sorts of places; from supercomputers to tiny embedded devices. As you might imagine, there are many points in the kernel code, where a good choice for a supercomputer might not behave well on, say, a cell phone.

The same is true for workloads. An HTTP server aggressively batching packets when delivering a large video file is probably ok, but doing the same for VoIP traffic can ruin a phone call.

Both of these simple examples highlight the need for policy.

Before bpf, policy tended to be coded directly into the kernel. A lot of policy exists in both the core kernel and kernel modules.

Let's look at `PACKET_FANOUT` to see a real example. `PACKET_FANOUT` is a mechanism that allows steering packets to multiple `AF_PACKET` sockets in the same fanout group. This can be used for scaling, classification, or both. A fanout method is the policy by which packets are mapped to sockets.

In linux v4.2, the following fanout methods existed.
```
#define PACKET_FANOUT_HASH		0
#define PACKET_FANOUT_LB		1
#define PACKET_FANOUT_CPU		2
#define PACKET_FANOUT_ROLLOVER		3
#define PACKET_FANOUT_RND		4
#define PACKET_FANOUT_QM		5
```
https://github.com/torvalds/linux/blob/v4.2/include/uapi/linux/if_packet.h#L59-L64

The policy for `PACKET_FANOUT_CPU` can be found in `fanout_demux_cpu()`. You can read more about `PACKET_FANOUT_CPU` in my post [Per-cpu Packet Captures with rxtxcpu](https://blog.stackpath.com/per-cpu-packet-captures-with-rxtxcpu/).
```
static unsigned int fanout_demux_cpu(struct packet_fanout *f,
				     struct sk_buff *skb,
				     unsigned int num)
{
	return smp_processor_id() % num;
}
```
https://github.com/torvalds/linux/blob/v4.2/net/packet/af_packet.c#L1355-L1360

The policy for `PACKET_FANOUT_QM` can be found in `fanout_demux_qm()`.
```
static unsigned int fanout_demux_qm(struct packet_fanout *f,
				    struct sk_buff *skb,
				    unsigned int num)
{
	return skb_get_queue_mapping(skb) % num;
}
```
https://github.com/torvalds/linux/blob/v4.2/net/packet/af_packet.c#L1408-L1413

These are both examples of policy coded directly into the kernel.

`rxtxnuma` (providing per-numa-node packet captures) and `rxtxqueue` (providing per-queue packet captures) both leverage fanout and, in their optimized form, require policy which doesn't exist in the kernel.

https://github.com/stackpath/rxtxcpu/blob/d2890b21b22aa341242b22fa0b39f2cad72d979f/rxtxnuma.c

https://github.com/stackpath/rxtxcpu/blob/a304078ff0a149b0f1c082ac13382924cb5c2338/rxtxqueue.c

Let's take a look at these in a world without bpf, then see how bpf improves things.

### Without BPF

Without bpf, these utilities would have required the kernel to be patched to add new policies. Let's narrow things down to just `rxtxqueue` and go a little deeper.

A `PACKET_FANOUT_QUEUE` policy would look something like this.
```
static unsigned int fanout_demux_queue(struct packet_fanout *f,
                                       struct sk_buff *skb,
                                       unsigned int num)
{
        if (skb->pkt_type == PACKET_OUTGOING)
                return skb_get_queue_mapping(skb) % num;
        return skb_get_rx_queue(skb) % num;
}
```

`fanout_demux_queue()` and ancillary code would have to be submitted as patch to net-next. The kernel community would have to see it as generic and useful, and, therefore, worthy to be accepted into the core kernel. Assuming that all goes well, the patch is now in net-next; not mainline, not any distro kernels. In order for the util to work for the general user, you'd have to wait a very long time for the patch to make its way around.

### With BPF

Thank goodness we have bpf. PACKET_FANOUT_CBPF and PACKET_FANOUT_EBPF were added in linux v4.3.
```
#define PACKET_FANOUT_CBPF		6
#define PACKET_FANOUT_EBPF		7
```
https://github.com/torvalds/linux/blob/v4.3/include/uapi/linux/if_packet.h#L66-L67

The in-kernel policy for these fanout methods boils down to this line, which leaves most of the policy up to a bpf program.
```
		ret = BPF_PROG_RUN(prog, skb) % num;
```
https://github.com/torvalds/linux/blob/v4.3/net/packet/af_packet.c#L1426

Now the policy needed for `rxtxqueue` can be a simple bpf program defined in userspace and loaded into the kernel. No patch to submit, no requirement to be generic and useful to others, no lengthy waiting on merges to mainline or distro kernels. As long as the kernel has `PACKET_FANOUT_{C,E}BPF`, you can implement new policies for fanout on a whim.


## What is eBPF?

> BPF is generic instruction set with C calling convention.

https://www.kernel.org/doc/html/v5.6/bpf/bpf_design_QA.html#bpf-is-generic-instruction-set-with-c-calling-convention

### A bpf program is simply a series of instructions.

Here are the parts of a bpf instruction. An array of bpf instructions is a bpf program.

```
struct bpf_insn {
	__u8	code;		/* opcode */
	__u8	dst_reg:4;	/* dest register */
	__u8	src_reg:4;	/* source register */
	__s16	off;		/* signed offset */
	__s32	imm;		/* signed immediate constant */
};
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/bpf.h#L65-L71

Let's look at a very simple concrete example, exiting a bpf program.

The following three statements are equivalent and differ only in phrasing.

#### Phrasing 1: integer literals for each member.

```
{ 0x95, 0x0, 0x0, 0x0000, 0x00000000 }
```
https://github.com/stackpath/rxtxcpu/blob/a304078ff0a149b0f1c082ac13382924cb5c2338/rxtxqueue.c#L481

#### Phrasing 2: leveraging object-like macros.

```
{ BPF_JMP | BPF_EXIT, 0, 0, 0, 0 }
```
https://github.com/torvalds/linux/blob/v5.6/tools/testing/selftests/net/psock_fanout.c#L144

This is certainly more readable (for people) than phrasing 1.

With the information below we can see the expression `BPF_JUMP | BPF_EXIT` resolves to 0x95, the same opcode as was seen as an integer literal in phrasing 1.

```
#define		BPF_JMP		0x05
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/bpf_common.h#L12

```
#define BPF_EXIT	0x90	/* function return */
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/bpf.h#L44

#### Phrasing 3: leveraging function-like macros.

```
BPF_EXIT_INSN()
```
https://github.com/torvalds/linux/blob/v5.6/tools/testing/selftests/bpf/verifier/sock.c#L7

This improves on readability over phrasing 2.

With the information below we can see that `BPF_EXIT_INSN()` is little more than shorthand for phrasing 2.

```
#define BPF_EXIT_INSN()						\
	((struct bpf_insn) {					\
		.code  = BPF_JMP | BPF_EXIT,			\
		.dst_reg = 0,					\
		.src_reg = 0,					\
		.off   = 0,					\
		.imm   = 0 })
```
https://github.com/torvalds/linux/blob/v5.6/include/linux/filter.h#L366-L372


### A bpf program can be written in C and compiled into instructions.

Let's keep looking at bpf program exit.

This is about as simple as a program gets; an entry point, an exit point, and little else.

```
#include <linux/bpf.h>
#include "bpf_helpers.h"

SEC("ret")
int _ret(void *ctx) {
	return 0;
}

char _license[] SEC("license") = "Dual MIT/GPL";
```
https://github.com/stackpath/blog-post-support/blob/58e6d3790106096a8886d5ccde6ebafe2336b244/exploring_kernel_networking__bpf_hook_points__part_1/ret.c

In order to compile, we'll need a suitable environment. A vanilla CentOS-8 VM is a reasonable starting point.

```
$ vagrant init centos/8
$ vagrant up
$ vagrant ssh
```

We need to install our build time dependencies and source. More on this in the next post.

```
[vagrant@localhost ~]$ sudo yum install -y clang llvm
...
[vagrant@localhost ~]$ curl -LO https://raw.githubusercontent.com/torvalds/linux/v4.18/tools/testing/selftests/bpf/bpf_helpers.h
...
[vagrant@localhost ~]$ curl -LO https://raw.githubusercontent.com/stackpath/blog-post-support/58e6d3790106096a8886d5ccde6ebafe2336b244/exploring_kernel_networking__bpf_hook_points__part_1/ret.c
...
```

We can now compile and disassemble the result using llvm project executables.

```
[vagrant@localhost ~]$ clang -O2 -g -S -emit-llvm -c ret.c -o - | llc -march=bpf -filetype=obj -o ret.o
[vagrant@localhost ~]$ llvm-objdump -d ret.o

ret.o:	file format ELF64-BPF

Disassembly of section ret:
0000000000000000 _ret:
       0:	b7 00 00 00 00 00 00 00 	r0 = 0
       1:	95 00 00 00 00 00 00 00 	exit
```

This program has two instructions. First, register r0 is set to 0. Second, the program exits.

The hexadecimal representation of the exit instruction (seen in the center column) matches phrasing 1 from above. Compiling the C code transformed it into bpf instructions.

When you are finished, the vagrant VM can be cleaned up from the same working directory in which it was initialized.
```
$ vagrant destroy
...
$ rm Vagrantfile
```


## Recognizing cBPF

Before eBPF there was cBPF. Unfortunately, they are both referred to as simply "BPF" in much of the literature. Additionally, they are sufficiently similar that, when starting out, it can be challenging to tell which you are looking at.

Let's dive into cBPF instructions just enough to be able to recognize it in code or documentation.

### A cBPF program is also just a series of instructions.

Here are the parts of a cBPF instruction. An array of cBPF instructions is a cBPF program.

```
struct sock_filter {	/* Filter block */
	__u16	code;   /* Actual filter code */
	__u8	jt;	/* Jump true */
	__u8	jf;	/* Jump false */
	__u32	k;      /* Generic multiuse field */
};
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/filter.h#L24-L29

A cBPF instruction uses one fewer fields than an eBPF instruction; this is one way to differentiate between the two. cBPF instructions use `struct sock_filter` whereas eBPF instructions use `struct bpf_insn`; this is another.

cBPF doesn't support a stand-alone exit instruction, but it has a way to return a value. We'll tell it to return the value of k, the generic multiuse field from `struct sock_filter`.

Similarly to eBPF, the following three statements are equivalent and differ only in phrasing.

#### Phrasing 1: integer literals for each member.
```
{ 0x06,  0,  0, 0x00000000 }
```
https://github.com/torvalds/linux/blob/v5.6/net/core/ptp_classifier.c#L178

#### Phrasing 2: leveraging object-like macros.
```
{ BPF_RET | BPF_K, 0, 0, 0 }
```

With the information below we can see the expression `BPF_RET | BPF_K` resolves to 0x06, the same opcode as was seen as an integer literal in phrasing 1.

```
#define		BPF_RET		0x06
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/bpf_common.h#L13

```
#define		BPF_K		0x00
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/bpf_common.h#L50

#### Phrasing 3: leveraging function-like macros.
```
BPF_STMT(BPF_RET | BPF_K, 0)
```
https://github.com/torvalds/linux/blob/v5.6/Documentation/networking/cdc_mbim.txt#L256

With the information below we can see that `BPF_STMT(BPF_RET | BPF_K, 0)` is little more than shorthand for phrasing 2.

```
#define BPF_STMT(code, k) { (unsigned short)(code), 0, 0, k }
```
https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/filter.h#L49


## Hook Points

> Classic BPF programs are converted into extend BPF instructions.

https://www.kernel.org/doc/html/v5.6/bpf/bpf_design_QA.html#q-does-classic-bpf-interpreter-still-exist

A hook point is a place in the kernel to which a bpf program can be attached. cBPF programs are converted in-kernel to eBPF instructions, but this doesn't mean a single hook point accepts both cBPF and eBPF programs.

For example, the `SO_ATTACH_FILTER` and `SO_ATTACH_BPF` hook points both filter incoming packets, but do so by leveraging cBPF programs and eBPF programs respectively.

>       SO_ATTACH_FILTER (since Linux 2.2), SO_ATTACH_BPF (since Linux 3.19)
>              Attach a classic BPF (SO_ATTACH_FILTER) or an extended BPF
>              (SO_ATTACH_BPF) program to the socket for use as a filter of
>              incoming packets.
http://man7.org/linux/man-pages/man7/socket.7.html

Many eBPF hook points exist which do not have a cBPF equivalent, but all cBPF hook points should have an eBPF equivalent (e.g. `PACKET_FANOUT_CBPF` has `PACKET_FANOUT_EBPF`, `SO_ATTACH_REUSEPORT_CBPF` has `SO_ATTACH_REUSEPORT_EBPF`, etc.).


## Final Thoughts

Understanding how, and when you need, to differentiate between eBPF and cBPF will greatly ease the process of learning about bpf. Most new development should prefer eBPF (cBPF is converted to eBPF in-kernel after all). However, there is a lot of content out there about each and cBPF hook points are likely to stick around for some time.

Hopefully this post also demystified bpf instructions a little. There is nothing magical about bpf; it's just really cool code doing a highly useful job. Don't be afraid to look behind the curtains.

This series will continue in _Exploring Kernel Networking: BPF Hook Points, Part 2 - Say "hello" to my little friend!_...
