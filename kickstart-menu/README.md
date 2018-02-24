# Red Hat Kickstart menu system.

## Getting Started

To launch the menu run the following command.  In order to gather the
system hard drives, this should be ran as root.

```
$ sudo ./menu.py
```

For the best experience run inside of the vagrant image provided.

```
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ sudo ./menu.py
```

### Prerequisites

The following items are required to use this development environment.

 * vagrant
 * virtualbox
 * internet access (to download vagrant box image)
