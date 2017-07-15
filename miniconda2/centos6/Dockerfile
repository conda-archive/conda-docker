FROM centos:centos6
MAINTAINER Conda Development Team <conda@continuum.io>

RUN yum -y update \
    && yum -y install curl bzip2 \
    && curl -sSL https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local/envs/_conda_ \
    && rm -rf /tmp/miniconda.sh \
    && pushd /usr/local/bin \
    && ln -s ../envs/_conda_/bin/activate ../envs/_conda_/bin/conda ../envs/_conda_/bin/conda-env ../envs/_conda_/bin/deactivate . \
    && mkdir -p /usr/local/conda-meta \
    && touch /usr/local/conda-meta/history \
    && conda install -y python=2 \
    && conda update conda \
    && conda clean --all --yes \
    && rpm --erase --nodeps curl bzip2 \
    && yum clean all

