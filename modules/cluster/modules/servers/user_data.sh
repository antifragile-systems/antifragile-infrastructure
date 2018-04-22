#!/bin/bash
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config

yum update -y && yum -y install nfs-utils && \
yum -y install python27 && yum -y install python27-pip

pip install awscli && pip install --upgrade awscli

aws configure set preview.efs true && \
mkdir /mnt/efs && \
mount -t nfs4 ${efs_filesystem_id}.efs.${region}.amazonaws.com:/ /mnt/efs && \
echo -e "${efs_filesystem_id}.efs.${region}.amazonaws.com:/ \t\t /mnt/efs \t\t nfs \t\t defaults \t\t 0 \t\t 0" | tee -a /etc/fstab;

