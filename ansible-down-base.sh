#!/bin/bash

function down_kube(){
    [ ! -f kubernetes-server-linux-amd64.tar.gz ] && {
        docker pull registry.aliyuncs.com/zhangguanzhang/k8s_bin:$KUBE_VERSION-full
        docker run --rm -d --name kube registry.aliyuncs.com/zhangguanzhang/k8s_bin:$KUBE_VERSION-full sleep 10
        docker cp kube:/kubernetes-server-linux-amd64.tar.gz .
        tar -zxvf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}
    } || :
}

function down_etcd(){
    docker pull registry.aliyuncs.com/k8sxio/etcd:$ETCD_version
    docker run --rm -d --name etcd registry.aliyuncs.com/k8sxio/etcd:$ETCD_version sleep 10
    docker cp etcd:/usr/local/bin/etcd /usr/local/bin
    docker cp etcd:/usr/local/bin/etcdctl /usr/local/bin
}

function down_flanneld(){
# https://github.com/coreos/flannel/releases

#    [ ! -f "flannel-${FLANNEL_version}-linux-amd64.tar.gz" ] && \
#        wget https://github.com/coreos/flannel/releases/download/${FLANNEL_version}/flannel-${FLANNEL_version}-linux-amd64.tar.gz
#    [ ! -f /usr/local/bin/flanneld ] && tar -zxvf flannel-${FLANNEL_version}-linux-amd64.tar.gz -C /usr/local/bin flanneld
    docker pull zhangguanzhang/quay.io.coreos.flannel:${FLANNEL_version}-amd64
    docker run --rm --entrypoint sh -d --name flanneld zhangguanzhang/quay.io.coreos.flannel:${FLANNEL_version}-amd64 -c 'sleep 10'
    docker cp flanneld:/opt/bin/flanneld /usr/local/bin/

}

function down_cni(){
    [ ! -f cni-plugins-linux-amd64-${CNI_VERSION}.tgz ] && \
#    wget "${CNI_URL}/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" 
    docker pull registry.aliyuncs.com/zhangguanzhang/cni-plugins:${OS}-${ARCH}-${CNI_VERSION}
    docker run -d --rm --name cni registry.aliyuncs.com/zhangguanzhang/cni-plugins:${OS}-${ARCH}-${CNI_VERSION} sleep 10
    docker cp cni:/cni-plugins-${OS}-${ARCH}-${CNI_VERSION}.tgz .
}

function down_base(){
    down_kube
    down_etcd
}

if [ "${#@}" -eq 1 ];then
    if [ "$1" != 'all' ];then
        down_$1
    else
        down_kube
        down_etcd
        down_cni
        down_flanneld
    fi
else
    echo you must choose a type to download
    exit 0
fi
