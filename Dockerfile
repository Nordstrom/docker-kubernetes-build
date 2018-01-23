# stage 0
FROM quay.io/nordstrom/kube-deployer:1.0.9

ARG KUBERNETES_TAG_VERSION
ENV KUBERNETES_TAG_VERSION ${KUBERNETES_TAG_VERSION:-v1.7.7}
ENV K8S_PATH ${GOPATH}/src/github.com/kubernetes/kubernetes

RUN mkdir -p ${K8S_PATH} \
  && curl -sSL https://github.com/kubernetes/kubernetes/archive/${KUBERNETES_TAG_VERSION}.tar.gz -o ${KUBERNETES_TAG_VERSION}.tar.gz \
  && tar --strip-components 1 -xC ${K8S_PATH} -f ${KUBERNETES_TAG_VERSION}.tar.gz \
  && make -C ${K8S_PATH} all WHAT=test/e2e/e2e.test \
  && rm ${KUBERNETES_TAG_VERSION}.tar.gz

# stage 1
FROM quay.io/nordstrom/cfssl:1.2.0

# stage 3
FROM google/cloud-sdk:183.0.0-alpine

# stage 2
FROM quay.io/nordstrom/kube-deployer:1.0.9
LABEL maintainer.team="Nordstrom Platform Team"
LABEL maintainer.email="techk8s@nordstrom.com"

ENV K8S_PATH ${GOPATH}/src/github.com/kubernetes/kubernetes
COPY --from=0 ${K8S_PATH}/_output/bin ${K8S_PATH}/_output/bin

COPY --from=1 \
     /usr/bin/cfssl \
     /usr/bin/cfssl-bundle \
     /usr/bin/cfssl-certinfo \
     /usr/bin/cfssl-newkey \
     /usr/bin/cfssl-scan \
     /usr/bin/cfssljson \
     /usr/bin/mkbundle \
     /usr/bin/multirootca \
     /usr/bin/

COPY --from=2 /google-cloud-sdk/bin:/google-cloud-sdk/bin
ENV PATH /google-cloud-sdk/bin:$PATH
VOLUME ["/.config"]

RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get -y update \
    && apt-get -y install \
        apt-transport-https \
        ca-certificates \
        netcat \
        openjdk-8-jdk \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
    && curl https://bazel.build/bazel-release.pub.gpg | apt-key add - \
    && add-apt-repository \
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" \
    && apt-get -y update \
    && apt-get -y install \
        bazel \
        docker-ce
