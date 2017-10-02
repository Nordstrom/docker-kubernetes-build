FROM quay.io/nordstrom/kube-deployer:1.0.9
MAINTAINER Nordstrom Platform Team "techk8s@nordstrom.com"

ARG KUBERNETES_TAG_VERSION
ENV KUBERNETES_TAG_VERSION ${KUBERNETES_TAG_VERSION:-v1.7.7}

RUN go get github.com/kubernetes/kubernetes \
  && cd $GOPATH/src/github.com/kubernetes/kubernetes \
  && git checkout tags/${KUBERNETES_TAG_VERSION} \
  && make all WHAT=test/e2e/e2e.test
