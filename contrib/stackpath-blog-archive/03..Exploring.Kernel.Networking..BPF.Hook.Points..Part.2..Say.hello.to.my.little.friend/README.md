# Exploring Kernel Networking: BPF Hook Points, Part 2 - Say "hello" to my little friend!
#   ↳ "Hello, World!" triggered by skbs.

"Hello, World!" programs have long been _the_ classic first program when exploring new languages, frameworks, or paradigms. While these simple programs do introduce some coding concepts and patterns, they also permit interacting with the other aspects of the program: compilation, execution, and results (in the "Hello, World!" case, output). All of these aspects apply to bpf programs; let's explore them.

This blog post is part of a series intended to help you navigate the abundance of information available on bpf, specifically for networking hook points. You'll find part 1 here: [Exploring Kernel Networking: BPF Hook Points, Part 1 – Elementary, My Dear Watson](https://blog.stackpath.com/bpf-hook-points-part-1/).

In today's post we print "Hello, World!", triggered by packets.

## Environment Setup

In order to compile and execute, we'll need a suitable environment. As in our previous post, a vanilla CentOS-8 VM is a reasonable starting point. One of our run time dependencies needs at least 2 vcpus, so we've included a `Vagrantfile` alongside our source.

We need to install our build time dependencies, source, and run time dependencies. Pay attention to the prompts—they show the suggested working directory for each recipe.

### Source

Our source is easiest to obtain via `git`. Let's clone the containing project and spin up our VM.
```
$ git clone https://github.com/stackpath/blog-post-support
...
$ cd blog-post-support/exploring_kernel_networking__bpf_hook_points__part_2/
$ vagrant up
$ vagrant ssh
```

The source will be accessible inside the VM at `/vagrant/`.

### Build Time Dependencies

The llvm project has a bpf backend for compiling C code into eBPF instructions. We'll need the `clang` and `llvm` components from this project.

We'll also need `gcc` to compile libbpf and a custom loader. Our custom loader requires `elfutils-libelf-devel` and `zlib`. And we use a `Makefile` to simplify transmission of the build steps.

Finally, we'll need `git` to pull down some more source.
```
[vagrant@localhost ~]$ sudo yum install -y clang elfutils-libelf-devel gcc git llvm make zlib
...
```

#### bpf_helpers.h and libbpf

We need `bpf_helpers.h` to build our bpf programs. Seeing a couple ways to get at this info is helpful since the process has evolved over time.

You only need to use one of the below methods. Since libbpf is needed for more than headers, it is the suggested method.

#### Method 1 (bpf_helpers.h only)

In the previous post, we simply downloaded the `bpf_helpers.h` from linux v4.18 (the default CentOS-8 kernel is based on this version). This method is suitable for our current bpf program needs (i.e. building `hello.c` and friends), but will be missing newer helper function declarations and similar. For a more substantial project, a newer `bpf_helpers.h` is desirable. This method doesn't include libbpf, which we need for our loader.

```
[vagrant@localhost vagrant]$ curl -LO https://raw.githubusercontent.com/torvalds/linux/v4.18/tools/testing/selftests/bpf/bpf_helpers.h
...
```

#### Method 2 (bpf_helper{,_def}s.h only)

bpf sees a lot of development and mainline has moved on from a single, directly committed `bpf_helpers.h`. Here is the recipe to get at this info in v5.6. This method will also satisfy our current bpf program needs. It too doesn't include libbpf.

```
[vagrant@localhost ~]$ sudo yum install -y python3
...
[vagrant@localhost ~]$ curl -LO https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.6.tar.xz
...
[vagrant@localhost ~]$ tar xf linux-5.6.tar.xz
[vagrant@localhost ~]$ cd linux-5.6/
[vagrant@localhost linux-5.6]$ cp tools/lib/bpf/bpf_helpers.h /vagrant/
[vagrant@localhost linux-5.6]$ ./scripts/bpf_helpers_doc.py --header --file tools/include/uapi/linux/bpf.h > /vagrant/bpf_helper_defs.h
```

#### Method 3 (libbpf and bpf_helper{,_defs.h)

libbpf contains modern copies of these headers as well. Keep in mind libbpf is a sync of select files from bpf-next, so it may contain some code which hasn't yet been merged into mainline.

We also need libbpf to build our custom loader, so this recipe should be run up through `sudo make install` even if you used another method to obtain `bpf_helpers.h`.

```
[vagrant@localhost ~]$ git clone https://github.com/libbpf/libbpf
...
[vagrant@localhost ~]$ cd libbpf/src/
[vagrant@localhost src]$ make
...
[vagrant@localhost src]$ sudo make install
...
[vagrant@localhost src]$ cp bpf_helper{,_def}s.h /vagrant/
```

### Run Time Dependencies

We'll be using `ip`, `tc`, and `bpftool` as loaders and for validation of loading. And `iptables` will be used to attach an already loaded program.

```
[vagrant@localhost ~]$ sudo yum install -y bpftool iproute{,-tc} iptables
...
```

#### tap-mq-pong

Most of the hook points we'll be using today work with a basic veth pair (many even work with the loopback device). However, also included is a driver-specific hook point to uncover this as a possibility. We'll be using `TUNSETSTEERINGEBPF` and, therefore, need a device driven by `tun.ko`.

tun/tap devices use a program to implement the "wire". Packets transmitted by the driver are then read by the wire program. Packets written by the wire program are then received by the driver.

[`tap_mq_pong.c`](https://github.com/stackpath/rxtxcpu/blob/master/helpers/tap_mq_pong.c) is a very simple program which writes a pong (icmp echo reply) for any ipv4 ping (icmp echo request) it reads. In other words, when you ping the program via the tap device, it replies. This code was originally written to provide a multiqueue device against which to test [`rxtxqueue`](https://github.com/stackpath/rxtxcpu/blob/master/rxtxqueue.c) without incurring a multiqueue adapter hardware requirement. Reusing it now simplifies our setup.

`tap_mq_pong.c` spins up combined queues equal to the number of cpus. In order for the resultant tap device to be multiqueue, we need at least 2 cpus. This requirement was met by our `Vagrantfile` if using vagrant as an environment.

The install target requires `/vagrant/Vagrantfile` as a simple guard. If you're not using vagrant as an environment, it will need minor modification. The `Makefile` is simple, so this is left as an exercise to the reader if needed.

```
[vagrant@localhost ~]$ curl -Lo rxtxcpu-1.2.6.tar.gz https://github.com/stackpath/rxtxcpu/archive/v1.2.6.tar.gz
...
[vagrant@localhost ~]$ tar xf rxtxcpu-1.2.6.tar.gz
[vagrant@localhost ~]$ cd rxtxcpu-1.2.6/helpers/
[vagrant@localhost helpers]$ make
...
[vagrant@localhost helpers]$ sudo make install
[vagrant@localhost helpers]$ sudo install -m 644 tap0.sysconf /etc/sysconfig/tap-mq-pong/tap0
[vagrant@localhost helpers]$ sudo systemctl start tap-mq-pong@tap0
[vagrant@localhost helpers]$ sudo systemctl enable tap-mq-pong@tap0
```

Once installed and running, you should be able to successfully ping the wire program.

```
[vagrant@localhost ~]$ ping -c1 169.254.254.1
PING 169.254.254.1 (169.254.254.1) 56(84) bytes of data.
64 bytes from 169.254.254.1: icmp_seq=1 ttl=64 time=0.288 ms

--- 169.254.254.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.288/0.288/0.288/0.000 ms
```


## Basic "Hello, World!"

We'll be using a few pieces of code in this post. Here we'll cover our most basic "Hello, World!" bpf program.

```
#include <linux/bpf.h>
#include "bpf_helpers.h"

#ifdef HELLO_XDP
  #define RET XDP_PASS

#else
  #define RET 0

#endif

SEC("hello")
int _hello(void *ctx) {
	char fmt[] = "Hello, World!\n";
	bpf_trace_printk(fmt, sizeof(fmt));

	return RET;
}

char _license[] SEC("license") = "Dual MIT/GPL";
```
Source: https://github.com/stackpath/blog-post-support/blob/b68377de359485e96cfa168ecf03e18ecb351dd7/exploring_kernel_networking__bpf_hook_points__part_2/hello.c

### Sections and Entrypoints

On compilation, this code (`hello.c`) will be transformed into an ELF file (`hello.o`). Due to the `SEC()` macro, `hello.o` will have 2 ELF sections, "hello" and "license".

The "license" section plainly contains a license string which will be used by our loader to inform the kernel of this information.

The "hello" section is a bit more interesting; "hello" is an entrypoint (start of execution). A single bpf source file (`.c`) and compiled counterpart (`.o`) can contain multiple entrypoints and, therefore, multiple bpf programs.

The loader will be used to select an entrypoint by section name. Instructions from sections not reachable by the selected entrypoint are not in the bpf program (i.e. the array of instructions) passed to the kernel.

We'll stick to a single entrypoint per source file in this post.

### BPF Helper Functions

In our code we call `bpf_trace_printk()`; this is a bpf helper function. Helper functions are implemented in the kernel proper, but are callable from bpf programs.

Some helper functions, including `bpf_trace_printk()`, require the calling code (i.e. the bpf program which calls the helper) to be GPL licensed—one of the reasons we pass a license string to the kernel.


> bpf_trace_printk() should only be used for debugging.
Source: https://www.kernel.org/doc/html/latest/bpf/bpf_design_QA.html#q-bpf-trace-printk-helper-warning

`bpf_trace_printk()` is a great tool for "Hello, World!" and debugging, but should be avoided in performance critical bpf programs.

> BPF calling convention only allows registers R1-R5 to be used as arguments.
Source: https://www.kernel.org/doc/html/v5.6/bpf/bpf_design_QA.html#q-can-more-than-5-function-arguments-be-supported-in-the-future

bpf calls support up-to 5 arguments. `bpf_trace_printk()` uses one for `fmt` (format) and another for `sizeof(fmt)`, leaving room for up-to 3 subsequent arguments. This post doesn't include the use of any subsequent arguments.

### Return Value

A zero return value is suitable for almost all of the hook points we'll be exploring today.

However, a functional xdp program should never return `XDP_ABORTED`.
```
	XDP_ABORTED = 0,
```
Source: https://github.com/torvalds/linux/blob/v5.6/include/uapi/linux/bpf.h#L3299

For the xdp hook points, we'll need to return `XDP_PASS` instead.

In this basic program, we're simplifying the return code phrasing to keep the example concise. We'll look at a more accurate example later in the post.


## Compiling

Now that our environment is setup, let's make our `.o` files from `hello.c`. As mentioned during setup, the source is accessible inside the VM at `/vagrant/`.

```
[vagrant@localhost vagrant]$ make hello
clang -O2 -g -S -emit-llvm             -c hello.c -o - | llc -march=bpf -filetype=obj -o hello.o
clang -O2 -g -S -emit-llvm -DHELLO_XDP -c hello.c -o - | llc -march=bpf -filetype=obj -o hello_xdp.o
```


## Loaders

In order to facilitate execution, we'll be using loaders. `ip`, `tc`, and our custom loader, `tunsetsteeringebpf-loader`, will all load and attach a bpf program from one of our `.o` files as a single command.

For iptables' `xt_bpf` module, we'll be loading and pinning the bpf program from `hello.o` to bpffs (a pseudo-filesystem a la procfs and sysfs, generally mounted at `/sys/fs/bpf/`). The pinned bpf program will then be attached via `iptables`.

Depending on the versions of your kernel and loaders, you may see one of the following (or similar) when loading a bpf program.

```
BTF debug data section '.BTF' rejected: Invalid argument (22)!
 - Length:       407
Verifier analysis:

magic: 0xeb9f
version: 1
flags: 0x0
hdr_len: 24
type_off: 0
type_len: 212
str_off: 212
str_len: 171
btf_total_size: 407
[1] PTR (anon) type_id=0
[2] ARRAY (anon) type_id=4 index_type_id=3 nr_elems=15
[3] INT __ARRAY_SIZE_TYPE__ size=4 bits_offset=0 nr_bits=32 encoding=(none)
[4] INT char size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
[5] Invalid kind:13
```

```
libbpf: Error loading BTF: Invalid argument(22)
libbpf: magic: 0xeb9f
version: 1
flags: 0x0
hdr_len: 24
type_off: 0
type_len: 212
str_off: 212
str_len: 171
btf_total_size: 407
[1] PTR (anon) type_id=0
[2] ARRAY (anon) type_id=4 index_type_id=3 nr_elems=15
[3] INT __ARRAY_SIZE_TYPE__ size=4 bits_offset=0 nr_bits=32 encoding=(none)
[4] INT char size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
[5] Invalid kind:13
libbpf: Error loading .BTF into kernel: -22. Ignored and continue.
```

These looks similar to, and are often confused with, a verification failure for the bpf program being loaded. However, the loading actually succeeded in both of the above cases.

We'll also cover verifying a bpf program is actually loaded at a given hook point. This output will contain a program id which can be used to detect a successful load when replacing another program.


## Hook Points

As mentioned last time, a hook point is a place in the kernel to which a bpf program can be attached. Let's attach our "Hello, World" programs to some networking hook points.

### XDP Hook Points

xdp isn't a single hook point, but a set of three: one in lowest parts of core networking, one—even lower—inside the driver, and one so low it's actually offloaded into the adapter.

For the xdp hook points, we'll be using `hello_xdp.o`. bpf programs attached to an xdp hook point operate on packets in the rx path.

#### xdp

Let's start with just "xdp" in our `ip` command. This command doesn't specify which of the three xdp hook points to use, but is valid.

```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdp obj hello_xdp.o sec hello
...
```

We can validate an xdp program is loaded with `ip link show` (`prog/xdp` as seen below indicates an xdp program is loaded for this interface).

```
[vagrant@localhost vagrant]$ ip link show dev tap0
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdp qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
    prog/xdp id 1
```

We can also validate an xdp program is loaded with `bpftool net show`. Take note of the "driver" keyword in this output. This shows that for this interface the xdpdrv hook point is the one actually in use.

```
[vagrant@localhost vagrant]$ bpftool net show
xdp:
tap0(4) driver id 1

tc:

```

A third way to validate an xdp program is loaded is `bpftool prog list`.

```
[vagrant@localhost vagrant]$ sudo bpftool prog list
1: xdp  tag c76ac638cb75bca4  gpl
	loaded_at 2020-05-19T19:06:40+0000  uid 0
	xlated 120B  jited 118B  memlock 4096B
```

Now that we know our bpf program is loaded, let's trigger execution by sending a packet via `tap0`.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
PING 169.254.254.1 (169.254.254.1) 56(84) bytes of data.
64 bytes from 169.254.254.1: icmp_seq=1 ttl=64 time=0.308 ms

--- 169.254.254.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.308/0.308/0.308/0.000 ms
```

Results (output from `bpf_trace_printk()`) can be seen in `/sys/kernel/debug/tracing/trace_pipe`. We're using `timeout` since this pipe won't reach an `EOF`.

```
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
     tap-mq-pong-25908 [000] ....  2392.063724: 0: Hello, World!
```

Let's clean up the program and validate it is so.

```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdp off
[vagrant@localhost vagrant]$ ip link show dev tap0
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

#### xdpgeneric

The xdpgeneric hook point is implemented in one of the lowest parts of core networking. As the name suggests, it is generic: it doesn't require the driver to be xdp-aware nor specialized hardware to facilitate offload. It is also the least performant of the three xdp hook points.

Let's load our bpf program, forcing xdpgeneric.

```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdpgeneric obj hello_xdp.o sec hello
...
```

We can validate in the same ways. Take note of the "generic" keyword in the `bpf net show` output. As expected, we're using the xdpgeneric hook point.

```
[vagrant@localhost vagrant]$ ip link show dev tap0
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
    prog/xdp id 2 
[vagrant@localhost vagrant]$ bpftool net show
xdp:
tap0(4) generic id 2

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
2: xdp  tag c76ac638cb75bca4  gpl
	loaded_at 2020-05-19T19:10:33+0000  uid 0
	xlated 120B  jited 118B  memlock 4096B
```

Ping and we get results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
     tap-mq-pong-25908 [000] ....  2560.128069: 0: Hello, World!
```

Let's clean up.

```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdpgeneric off
[vagrant@localhost vagrant]$ ip link show dev tap0
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

#### xdpdrv

The xdpdrv hook point is implemented in the network adapter's driver. It requires the driver to be xdp-aware (i.e. for the driver to have been extended to work with xdp directly).

Let's load our bpf program, forcing xdpdrv.

```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdpdrv obj hello_xdp.o sec hello
...
```

Validation shows we're again using the xdpdrv hook point.

```
[vagrant@localhost vagrant]$ ip link show dev tap0
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdp qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
    prog/xdp id 3 
[vagrant@localhost vagrant]$ bpftool net show
xdp:
tap0(4) driver id 3

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
3: xdp  tag c76ac638cb75bca4  gpl
	loaded_at 2020-05-19T19:15:15+0000  uid 0
	xlated 120B  jited 118B  memlock 4096B
```

Ping and results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
     tap-mq-pong-25908 [000] ....  2831.408978: 0: Hello, World!
```

Let's clean up.

```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdpdrv off
[vagrant@localhost vagrant]$ ip link show dev tap0
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

#### xdpoffload

The xdpoffload hook point generally requires specialized hardware. It is possible to play with xdpoffload using a netdevsim interface. However, this is not available in the vanilla CentOS-8 kernel (it requires `CONFIG_NETDEVSIM`). We won't be using this hook point in this post.

### Selected skb Hook Points

For the selected skb hook points, we'll be using `hello.o`.

#### tc clsact

tc supports classifiers (cls) and actions (act) as bpf programs which can be attached to hook points provided by ingress and egress queueing disciplines. We'll use the cls hook point via the `filter` subcommand in direct action (`da`) mode since we have no need for our action to be independent from our classifier.

##### Ingress

bpf programs attached to an ingress qdisc operate on packets in the rx path.

Setting up a clsact qdisk for the interface is an easy way to be able to attach bpf programs. The bpf program will then be attached to the qdisc.

```
[vagrant@localhost vagrant]$ sudo tc qdisc add dev tap0 clsact
[vagrant@localhost vagrant]$ sudo tc qdisc show dev tap0
qdisc mq 0: root 
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms memory_limit 32Mb ecn 
qdisc clsact ffff: parent ffff:fff1 
```

With our qdisc in place, we can now use `tc` to load and attach our bpf program.

```
[vagrant@localhost vagrant]$ sudo tc filter add dev tap0 ingress prio 1 handle 1 bpf da obj hello.o sec hello
...
```

We can validate a tc bpf program is loaded with `tc filter show`.

```
[vagrant@localhost vagrant]$ tc filter show dev tap0 ingress
filter protocol all pref 1 bpf chain 0 
filter protocol all pref 1 bpf chain 0 handle 0x1 hello.o:[hello] direct-action not_in_hw id 4 tag c514db71faba4034
```

`bpftool net show` also works.

```
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:
tap0(4) clsact/ingress hello.o:[hello] id 4

```

`bpftool prog list` does too.

```
[vagrant@localhost vagrant]$ sudo bpftool prog list
4: sched_cls  tag c514db71faba4034  gpl
	loaded_at 2020-05-19T19:18:49+0000  uid 0
	xlated 120B  jited 115B  memlock 4096B
```

Ping and we get results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
     tap-mq-pong-25908 [000] ..s1  3122.722302: 0: Hello, World!
```

Let's clean up our bpf program.

```
[vagrant@localhost vagrant]$ sudo tc filter del dev tap0 ingress prio 1 handle 1 bpf
[vagrant@localhost vagrant]$ tc filter show dev tap0 egress
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

Now we can clean up our qdisc.

```
[vagrant@localhost vagrant]$ sudo tc qdisc del dev tap0 clsact
[vagrant@localhost vagrant]$ sudo tc qdisc show dev tap0
qdisc mq 0: root 
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms memory_limit 32Mb ecn 
```

##### Egress

bpf programs attached to an egress qdisc operate on packets in the tx path. The egress setup is essentially the same as ingress; it simply applies to packets in the other direction.

Let's setup our qdisc.

```
[vagrant@localhost vagrant]$ sudo tc qdisc add dev tap0 clsact
[vagrant@localhost vagrant]$ sudo tc qdisc show dev tap0
qdisc mq 0: root
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms memory_limit 32Mb ecn
qdisc clsact ffff: parent ffff:fff1
```

Now we can load our bpf program

```
[vagrant@localhost vagrant]$ sudo tc filter add dev tap0 egress prio 1 handle 1 bpf da obj hello.o sec hello
...
[vagrant@localhost vagrant]$ tc filter show dev tap0 egress
filter protocol all pref 1 bpf chain 0 
filter protocol all pref 1 bpf chain 0 handle 0x1 hello.o:[hello] direct-action not_in_hw id 5 tag c514db71faba4034 
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:
tap0(4) clsact/egress hello.o:[hello] id 5

[vagrant@localhost vagrant]$ sudo bpftool prog list
5: sched_cls  tag c514db71faba4034  gpl
	loaded_at 2020-05-19T19:44:51+0000  uid 0
	xlated 120B  jited 115B  memlock 4096B
```

Ping and results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
            ping-26058 [001] ....  4652.158176: 0: Hello, World!
```

Let's clean up.

```
[vagrant@localhost vagrant]$ sudo tc filter del dev tap0 egress prio 1 handle 1 bpf
[vagrant@localhost vagrant]$ tc filter show dev tap0 egress
[vagrant@localhost vagrant]$ bpftool net show
xdp:

tc:

[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ sudo tc qdisc del dev tap0 clsact
[vagrant@localhost vagrant]$ sudo tc qdisc show dev tap0
qdisc mq 0: root
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms memory_limit 32Mb ecn
```


#### iptables xt_bpf

iptables' `xt_bpf` module let's you use a bpf program as a match rule and can be used across the various tables and chains. Let's attach our "Hello, World!" program to the very common `INPUT` and `OUPUT` chains from the filter table.

##### INPUT

bpf programs attached to the `INPUT` chain operate on packets in the rx path.

Let's load our bpf program. Unlike our previous examples, this does not attach the program to any hook point.

```
[vagrant@localhost vagrant]$ sudo bpftool prog load hello.o /sys/fs/bpf/hello type socket
...
```

The load can be validated using `bpftool prog list`.

```
[vagrant@localhost vagrant]$ sudo bpftool prog list
8: socket_filter  name _hello  tag c514db71faba4034  gpl
	loaded_at 2020-05-19T20:03:31+0000  uid 0
	xlated 120B  jited 115B  memlock 4096B
```

Now we can attach the program to the `INPUT` chain as a match rule.

```
[vagrant@localhost vagrant]$ sudo iptables -A INPUT -i tap0 -m bpf --object-pinned /sys/fs/bpf/hello -j LOG
```

We can validate by printing the `INPUT` chain.

```
[vagrant@localhost vagrant]$ sudo iptables -nL INPUT
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
LOG        all  --  0.0.0.0/0            0.0.0.0/0           match bpf pinned /sys/fs/bpf/hello LOG flags 0 level 4
```

Ping and we get results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
     tap-mq-pong-25908 [000] ..s1  5747.708899: 0: Hello, World!
```

Let's clean up.

```
[vagrant@localhost vagrant]$ sudo iptables -D INPUT -i tap0 -m bpf --object-pinned /sys/fs/bpf/hello -j LOG
[vagrant@localhost vagrant]$ sudo iptables -nL INPUT
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
[vagrant@localhost vagrant]$ sudo rm /sys/fs/bpf/hello
[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

##### OUTPUT

bpf programs attached to the `OUTPUT` chain operate on packets in the tx path. The `OUTPUT` setup is essentially the same as `INPUT`; it simply applies to packets in the other direction.

Let's load our bpf program.

```
[vagrant@localhost vagrant]$ sudo bpftool prog load hello.o /sys/fs/bpf/hello type socket
...
```

Validate the load.

```
[vagrant@localhost vagrant]$ sudo bpftool prog list
11: socket_filter  name _hello  tag c514db71faba4034  gpl
	loaded_at 2020-05-19T20:05:01+0000  uid 0
	xlated 120B  jited 115B  memlock 4096B
```

Attach our program, this time to an `OUTPUT` chain rule.

```
[vagrant@localhost vagrant]$ sudo iptables -A OUTPUT -o tap0 -m bpf --object-pinned /sys/fs/bpf/hello -j LOG
[vagrant@localhost vagrant]$ sudo iptables -nL OUTPUT
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
LOG        all  --  0.0.0.0/0            0.0.0.0/0           match bpf pinned /sys/fs/bpf/hello LOG flags 0 level 4
```

Ping and results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
            ping-26202 [000] ....  5844.663290: 0: Hello, World!
```

And clean up.

```
[vagrant@localhost vagrant]$ sudo iptables -D OUTPUT -o tap0 -m bpf --object-pinned /sys/fs/bpf/hello -j LOG
[vagrant@localhost vagrant]$ sudo iptables -nL OUTPUT
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
[vagrant@localhost vagrant]$ sudo rm /sys/fs/bpf/hello
[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

#### TUNSETSTEERINGEBPF

`TUNSETSTEERINGEBPF` permits tx queue selection for a tun/tap device via a bpf program. As mentioned earlier, the `TUNSETSTEERINGEBPF` hook point is in, and specific to, the `tun.ko` driver.

##### Custom Loader

We need a custom loader to attach to the `TUNSETSTEERINGEBPF` hook point. Let's examine the key aspects of this loader.

```
...
#define UNLOAD_PROG -1
...
    if (argc == NO_ARGS) {
        prog_fd = UNLOAD_PROG;
...
    } else {
        const char *filename = argv[1];

        err = bpf_prog_load(filename, BPF_PROG_TYPE_SOCKET_FILTER, &obj, &prog_fd);
...
    err = ioctl(tun_fd, TUNSETSTEERINGEBPF, (void *)&prog_fd);
...
```
Source: https://github.com/stackpath/blog-post-support/blob/b68377de359485e96cfa168ecf03e18ecb351dd7/exploring_kernel_networking__bpf_hook_points__part_2/tunsetsteeringebpf_loader.c

`bpf_prog_load()` does the same thing as `bpftool prog load`: it passes the bpf program to the kernel which verifies, loads, and returns a file descriptor.

The above `ioctl()` makes a `TUNSETSTEERINGEBPF` request against `tun_fd` (a file descriptor associated with tap0) passing `prog_fd` as additional information.

`prog_fd` is either the file descriptor returned by the kernel and associated with our bpf program, or `-1`, the value to signal unloading.

##### Compiling

Let's build our custom loader.

```
[vagrant@localhost vagrant]$ make loader
gcc -Wall -Wcast-align -Wcast-qual -Wimplicit -Wpointer-arith -Wredundant-decls -Wreturn-type -Wshadow -o tunsetsteeringebpf-loader tunsetsteeringebpf_loader.c -lbpf -lelf -lz
```

##### Using the TUNSETSTEERINGEBPF Hook Point

bpf programs attached to the `TUNSETSTEERINGEBPF` hook point operate on packets in the tx path.

Let's load our program.

```
[vagrant@localhost vagrant]$ sudo ./tunsetsteeringebpf-loader hello.o
[vagrant@localhost vagrant]$ sudo bpftool prog list
15: socket_filter  name _hello  tag c514db71faba4034  gpl
	loaded_at 2020-05-19T20:08:05+0000  uid 0
	xlated 120B  jited 115B  memlock 4096B
```

Ping and we get results.

```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
            ping-26294 [000] ....  6006.795410: 0: Hello, World!
```

Let's clean up.

```
[vagrant@localhost vagrant]$ sudo ./tunsetsteeringebpf-loader
[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```

## Amplified "Hello, World!"

Now that we've seen a bpf program attached to each of our selected hook points one-at-a-time, let's attach to (nearly) all of them simultaneously (we can't attach to xdpdrv and xdpgenric at the same time, so we'll skip the latter).

### Source

Here is the code we'll use for this section.

```
#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <stdbool.h>
#include "bpf_helpers.h"

#ifdef HELLO_IP_XDPDRV
  #define LOC "ip xdpdrv"
  #define RET XDP_PASS

#elif defined(HELLO_TUNSETSTEERINGEBPF)
  #define LOC "tun.ko tunsetsteeringebpf"
  #define RET 0

#elif defined(HELLO_TC_CLSACT_INGRESS)
  #define LOC "tc clsact ingress"
  #define RET TC_ACT_OK

#elif defined(HELLO_TC_CLSACT_EGRESS)
  #define LOC "tc clsact egress"
  #define RET TC_ACT_OK

#elif defined(HELLO_IPTABLES_XT_BPF_INPUT)
  #define LOC "iptables xt_bpf input"
  #define RET false

#elif defined(HELLO_IPTABLES_XT_BPF_OUTPUT)
  #define LOC "iptables xt_bpf output"
  #define RET false

#else
  #define LOC "unspecified"
  #define RET 0

#endif

SEC("hello")
int _hello(void *ctx) {
	char fmt[] = LOC ": Hello, World!\n";
	bpf_trace_printk(fmt, sizeof(fmt));

	return RET;
}

char _license[] SEC("license") = "Dual MIT/GPL";
```
Source: https://github.com/stackpath/blog-post-support/blob/b68377de359485e96cfa168ecf03e18ecb351dd7/exploring_kernel_networking__bpf_hook_points__part_2/hello_loc.c

To make our results clear, a location string has been added to our output.

We're also using more proper phrasing for our return codes: an xdp action for xdpdrv, an unsigned integer representing a queue index for `TUNSETSTEERINGEBPF`, a tc action for tc, and a bool for iptables' `xt_bpf`. `TC_ACT_OK` and `false` both resolve to `0`, so these phrasings are functionally equivalent to our earlier program.


### Compiling

Let's make our `.o` files from `hello_loc.c`.

```
[vagrant@localhost vagrant]$ make hello_loc
clang -O2 -g -S -emit-llvm -DHELLO_IP_XDPDRV              -c hello_loc.c -o - | llc -march=bpf -filetype=obj -o hello_ip_xdpdrv.o
clang -O2 -g -S -emit-llvm -DHELLO_TUNSETSTEERINGEBPF     -c hello_loc.c -o - | llc -march=bpf -filetype=obj -o hello_tunsetsteering.o
clang -O2 -g -S -emit-llvm -DHELLO_TC_CLSACT_INGRESS      -c hello_loc.c -o - | llc -march=bpf -filetype=obj -o hello_tc_clsact_ingress.o
clang -O2 -g -S -emit-llvm -DHELLO_TC_CLSACT_EGRESS       -c hello_loc.c -o - | llc -march=bpf -filetype=obj -o hello_tc_clsact_egress.o
clang -O2 -g -S -emit-llvm -DHELLO_IPTABLES_XT_BPF_INPUT  -c hello_loc.c -o - | llc -march=bpf -filetype=obj -o hello_iptables_xt_bpf_input.o
clang -O2 -g -S -emit-llvm -DHELLO_IPTABLES_XT_BPF_OUTPUT -c hello_loc.c -o - | llc -march=bpf -filetype=obj -o hello_iptables_xt_bpf_output.o
```

### The "Hello, World!" Hook Point Choir

Time to load 'em all.
```
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdpdrv obj hello_ip_xdpdrv.o sec hello
...
[vagrant@localhost vagrant]$ sudo tc qdisc add dev tap0 clsact
[vagrant@localhost vagrant]$ sudo tc filter add dev tap0 ingress prio 1 handle 1 bpf da obj hello_tc_clsact_ingress.o sec hello
...
[vagrant@localhost vagrant]$ sudo tc filter add dev tap0 egress prio 1 handle 1 bpf da obj hello_tc_clsact_egress.o sec hello
...
[vagrant@localhost vagrant]$ sudo bpftool prog load hello_iptables_xt_bpf_input.o /sys/fs/bpf/hello_iptables_xt_bpf_input type socket
...
[vagrant@localhost vagrant]$ sudo iptables -A INPUT -i tap0 -m bpf --object-pinned /sys/fs/bpf/hello_iptables_xt_bpf_input -j LOG
[vagrant@localhost vagrant]$ sudo bpftool prog load hello_iptables_xt_bpf_output.o /sys/fs/bpf/hello_iptables_xt_bpf_output type socket
...
[vagrant@localhost vagrant]$ sudo iptables -A OUTPUT -o tap0 -m bpf --object-pinned /sys/fs/bpf/hello_iptables_xt_bpf_output -j LOG
[vagrant@localhost vagrant]$ sudo ./tunsetsteeringebpf-loader hello_tunsetsteering.o
```

Validate the loads.
```
[vagrant@localhost vagrant]$ sudo bpftool prog list
16: xdp  tag dc2a3a987ff2a98a  gpl
	loaded_at 2020-05-19T20:56:26+0000  uid 0
	xlated 136B  jited 132B  memlock 4096B
18: sched_cls  tag 3c6910928dd5db64  gpl
	loaded_at 2020-05-19T20:57:11+0000  uid 0
	xlated 160B  jited 143B  memlock 4096B
19: sched_cls  tag fe3d7554304f4c4c  gpl
	loaded_at 2020-05-19T20:57:38+0000  uid 0
	xlated 160B  jited 140B  memlock 4096B
22: socket_filter  name _hello  tag e4d5c114687f383e  gpl
	loaded_at 2020-05-19T20:58:34+0000  uid 0
	xlated 176B  jited 151B  memlock 4096B
25: socket_filter  name _hello  tag cd3b19fa7c17b397  gpl
	loaded_at 2020-05-19T20:59:08+0000  uid 0
	xlated 192B  jited 157B  memlock 4096B
29: socket_filter  name _hello  tag 75bea6925c661983  gpl
	loaded_at 2020-05-19T20:59:32+0000  uid 0
	xlated 184B  jited 157B  memlock 4096B
```

A single ping and we get results from each hook point.
```
[vagrant@localhost vagrant]$ ping -c1 169.254.254.1
...
[vagrant@localhost vagrant]$ sudo timeout .1 cat /sys/kernel/debug/tracing/trace_pipe
            ping-26427 [000] ....  9128.768819: 0: iptables xt_bpf output: Hello, World!
            ping-26427 [000] ....  9128.768828: 0: tc clsact egress: Hello, World!
            ping-26427 [000] ....  9128.768829: 0: tun.ko tunsetsteeringebpf: Hello, World!
     tap-mq-pong-25908 [000] ....  9128.769090: 0: ip xdpdrv: Hello, World!
     tap-mq-pong-25908 [000] ..s1  9128.769095: 0: tc clsact ingress: Hello, World!
     tap-mq-pong-25908 [000] ..s1  9128.769101: 0: iptables xt_bpf input: Hello, World!
```

Let's clean up.
```
[vagrant@localhost vagrant]$ sudo ./tunsetsteeringebpf-loader
[vagrant@localhost vagrant]$ sudo iptables -D OUTPUT -o tap0 -m bpf --object-pinned /sys/fs/bpf/hello_iptables_xt_bpf_output -j LOG
[vagrant@localhost vagrant]$ sudo rm /sys/fs/bpf/hello_iptables_xt_bpf_output
[vagrant@localhost vagrant]$ sudo iptables -D INPUT -i tap0 -m bpf --object-pinned /sys/fs/bpf/hello_iptables_xt_bpf_input -j LOG
[vagrant@localhost vagrant]$ sudo rm /sys/fs/bpf/hello_iptables_xt_bpf_input
[vagrant@localhost vagrant]$ sudo tc filter del dev tap0 egress prio 1 handle 1 bpf
[vagrant@localhost vagrant]$ sudo tc filter del dev tap0 ingress prio 1 handle 1 bpf
[vagrant@localhost vagrant]$ sudo tc qdisc del dev tap0 clsact
[vagrant@localhost vagrant]$ sudo ip link set dev tap0 xdpdrv off
[vagrant@localhost vagrant]$ sudo bpftool prog list
[vagrant@localhost vagrant]$ 
```


## Environment Teardown

When you are finished, the vagrant VM can be cleaned up from the same working directory in which it was initialized.

```
$ vagrant destroy
...
```

## Final Thoughts

Compiling, executing, and getting results are fundamentals of programming. We've now looked at simple forms of these activities in the context of bpf. Using this knowledge to dive into bpf with your own programs is a great next step.

Our simple "Hello, World!" programs introduced some coding patterns as well, but we still have some basics to explore.

This series will continue in _Exploring Kernel Networking: BPF Hook Points, Part 3 - You talkin' to me?_
