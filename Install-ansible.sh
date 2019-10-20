#!/bin/bash
set -e
yum install -y wget epel-release \
  && yum install -y python-pip git sshpass
pip install --no-cache-dir ansible -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
