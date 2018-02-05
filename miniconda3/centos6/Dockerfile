FROM centos:centos6
MAINTAINER Conda Development Team <conda@continuum.io>
ARG CONDA_VERSION=latest

RUN yum -y update \
    && yum -y install curl bzip2 \
    && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local/ \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=3 \
    && conda update conda \ 
    && conda clean --all --yes \
    && rpm --erase --nodeps curl bzip2 \
    && conda clean --all --yes \
    && yum clean all \
