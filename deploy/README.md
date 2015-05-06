Deploy
======

deploy
------

In order to spawn containers you need to play setup-site.yaml playbook.
Ansible will setup all needed containers according to vars/config.yaml

```
$ ansible-playbook -i /dev/null -l localhost setup-site.yaml
```

Once done jump in the scenario/infra directory.


clean
-----

In order to clean (stop containers and delete delta union FS) run both
playbooks:

```
# Shutdown containers
$ ansible-playbook -i /dev/null -l localhost shutdown-site.yaml
# Clean container rootfs (wipe overlay work dirs)
$ ansible-playbook -i /dev/null -l localhost clean-site.yaml
```
