# Finding Boxes on Vagrant Cloud [Vagrant: Development Environments Made Easy]

https://www.youtube.com/watch?v=0hyiw9641KM

## Transcript

Even a cursory look at the vagrant documentation has a good chance of uncovering vagrant cloud: the main, public and searchable, index of vagrant boxes.

https://developer.hashicorp.com/vagrant/vagrant-cloud/boxes/catalog

We're already aware of the centos/7 box--let's search for `rockylinux`.

As mentioned previously, vagrant supports a number of providers. To use a listed box it must be available on your provider.

We can see a provider filter menu just below the search bar. And provider badges in the second column of each listing. These tools will help keep us informed as we discover boxes.

Let's drill into the first entry, `rockylinux/8`.

Right away, we're presented with a simple Vagrantfile. Switching to the "New" tab, we can see the same info in `vagrant init` form.

Both of these were covered previously and should look mostly familiar.

Another thing on this page worth noting is that this box is externally hosted by dl.rockylinux.org.

This box is created and maintained by the rocky linux project--the same group already relied upon by using the rocky linux distro. Trusting distro boxes when already using distro packages sounds reasonable.

It's also worth mentioning, however, that there are officially endorsed box sets--specifically, those found in the hashicorp or bento namespaces.

https://developer.hashicorp.com/vagrant/docs/boxes

vagrant itself is created and maintained by HashiCorp. Trusting HashiCorp boxes when already using vagrant seems sensible.

The bento project is both part of the well-known chef automation software testing kit and officially endosed by HashiCorp. It contains high-quality, open-source code to produce many boxes across several providers.

https://github.com/chef/bento

Back at our search results, we can see `bento/rockylinux-8` as the third listing. This box would be another sound choice.

Now, we know three easy ways to find credible boxes: seek out distro boxes, boxes in the hashicorp namespace, or boxes in the bento namespace.

vagrant cloud can also be searched via command line by using `vagrant cloud search`.
```
werekraken@ubuntu:~/demo$ vagrant cloud search rockylinux
...
```
We can see that this information is very nearly the same as what's found in the web portal. It's even paginated in a similar way.

Feel free to dig in more now with `vagrant cloud search --help` if interested.

Searching for boxes via the web portal has already become a habit for me, so I'll end here.
