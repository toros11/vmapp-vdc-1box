vmapp-vdc-1box
==============

[Wakame-vdc](https://github.com/axsh/wakame-vdc) demobox/testbox.

![vmapp-vdc-1box](https://cloud.githubusercontent.com/assets/76867/5339275/11b1bd34-7f22-11e4-8d21-ecf6779ae3da.png)

Pre-setup
---------

### 1: Donwload vmimage files.

```
$ ./prepare-vmimage.sh
```

### 2: Install submodules.

```
$ make
```

### 3: Generate vdc command set.


```
$ ./gen-vmcmdset.sh
```

> ```
> [INFO] Generating guestroot.kvm.x86_64/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.kvm.i686/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.lxc.x86_64/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.lxc.i686/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.openvz.x86_64/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.openvz.i686/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.dummy.x86_64/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> [INFO] Generating guestroot.dummy.i686/var/lib/wakame-vdc/demo/vdc-manage.d/02_core
> ```

### Optional: Setup a bridge interface to run vm.

```
$ sudo cp hostroot/etc/sysconfig/network-scripts/ifcfg-vboxbr0 /etc/sysconfig/network-scripts/ifcfg-vboxbr0
$ sudo ifup vboxbr0
```

Controlling box
---------------

```
$ ./box-ctl.sh build [hypervisor]
$ ./box-ctl.sh start [hypervisor]
$ ./box-ctl.sh stop  [hypervisor]
```

hypervisor:

+ lxc
+ openvz
+ kvm
+ dummy

Custom configuration
--------------------

+ copy.local.txt
+ postcopy.local.txt
+ copy.local.$(arch).txt
+ postcopy.local.$(arch).txt

Contributing
------------

1. Fork it ( https://github.com/[my-github-username]/vmapp-vdc-1box/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
