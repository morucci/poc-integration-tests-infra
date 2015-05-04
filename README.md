Infra deploy and validate
-------------------------

This is a POC regarding https://review.openstack.org/#/c/172833/.
Still an early WIP, I put it here to got feedbacks.

This has been tested on Fedora 21 where overlayfs is available and needed to run
this POC.

1. Have a look to prepare/README.md
2. Have a look to deploy/README.md
3. Have a look to scenario/infra/README.md


Note:
firewall.sh should be run on the host node to allow puppet manifests
fetch remote data.
