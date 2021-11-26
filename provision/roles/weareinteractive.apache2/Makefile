PWD=$(shell pwd)
ROLE_NAME=weareinteractive.apache2
ROLE_PATH=/etc/ansible/roles/$(ROLE_NAME)
TEST_VERSION=ansible --version
TEST_DEPS=apt-get update && apt-get install -y python3-pip && pip3 install pyopenssl  && ansible-galaxy install -c weareinteractive.apt weareinteractive.openssl weareinteractive.htpasswd
TEST_SYNTAX=ansible-playbook -v -i 'localhost,' -c local $(ROLE_PATH)/tests/main.yml --syntax-check
TEST_PLAYBOOK=ansible-playbook -vvvv -i 'localhost,' -c local -e 'ansible_python_interpreter=/usr/bin/python3' $(ROLE_PATH)/tests/main.yml
TEST_IDEMPOTENT=$(TEST_PLAYBOOK) | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
TEST_CMD=$(TEST_DEPS); $(TEST_VERSION); $(TEST_SYNTAX); $(TEST_PLAYBOOK); $(TEST_IDEMPOTENT)

docs:
	ansible-role docgen

lint:
	ansible-lint .

ubuntu18.04: dist=ubuntu-18.04
ubuntu18.04: .run

ubuntu16.04: dist=ubuntu-16.04
ubuntu16.04: .run

debian9: dist=debian-9
debian9: .run

debian8: dist=debian-8
debian8: .run

.run:
	@echo "RUN:"
	@echo "	docker run -it --rm -v $(PWD):$(ROLE_PATH) ansiblecheck/ansiblecheck:$(dist) /bin/bash"
	@echo "	$(TEST_CMD)"
	@docker run -it --rm -v $(PWD):$(ROLE_PATH) ansiblecheck/ansiblecheck:$(dist) /bin/bash -c "$(TEST_CMD)"
