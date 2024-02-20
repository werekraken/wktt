#!/bin/bash

vagrant up
vagrant ssh -c 'cd /vagrant && ./build.sh'
[[ "$RUNNER_VAGRANT_DESTROY" == "false" ]] ||
  vagrant destroy -f
