Deploy
======

deploy
------

In order to spawn container you need to play setup-site.yaml playbook.
Ansible will setup all needed containers according to vars/hosts.yaml

```
$ sudo ansible-playbook -i /dev/null -l localhost setup-site.yaml
```

Once done jump in the scenario directory.


clean
-----

In order to clean (stop container and delete delta union FS) run both
playbooks:

```
#Shutdown containers
sudo ansible-playbook -i /dev/null -l localhost shutdown-site.yaml
#Clean container rootfs (wipe overlay work dirs)
sudo ansible-playbook -i /dev/null -l localhost clean-site.yaml
```
