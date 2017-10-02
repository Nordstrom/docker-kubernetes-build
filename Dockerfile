FROM quay.io/nordstrom/kube-deployer:1.0.9
LABEL maintainer.team="Nordstrom Platform Team"
LABEL maintainer.email="techk8s@nordstrom.com"

ARG KUBERNETES_TAG_VERSION
ENV KUBERNETES_TAG_VERSION ${KUBERNETES_TAG_VERSION:-v1.7.7}
ENV K8S_PATH ${GOPATH}/github.com/kubernetes/kubernetes

RUN mkdir -p ${K8S_PATH} \
  && curl -sSL https://github.com/kubernetes/kubernetes/archive/${KUBERNETES_TAG_VERSION}.tar.gz -o ${KUBERNETES_TAG_VERSION}.tar.gz \
  && tar --strip-components 1 -xC ${K8S_PATH} -f ${KUBERNETES_TAG_VERSION}.tar.gz \
  && make -C ${K8S_PATH} all WHAT=test/e2e/e2e.test \
  && rm ${KUBERNETES_TAG_VERSION}.tar.gz