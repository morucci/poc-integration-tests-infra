Deploy
------

This is an uncomplete scenario to deploy openstack-infra/system-config/. Indeed
here we deploy a puppetmaster and deploy openstack-project/server on two nodes.
All is managed by main.yaml playbook.

```
$ ansible-playbook -i inventory.yaml main.yaml
```

You may need to clean your .known_hosts for 192.168.100.[2-4]

Tests
-----

TBD
