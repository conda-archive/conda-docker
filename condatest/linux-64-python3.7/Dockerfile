FROM circleci/golang
MAINTAINER Conda Development Team <conda@continuum.io>

#  $ docker build . -t condatest/linux-64-python-3.7:latest
#  $ docker push condatest/linux-64-python-3.7
#  $ docker run --rm -it condatest/linux-64-python-3.7 /bin/bash

# NOTE: sudo is used in this Dockerfile because the circleci images default user is NOT root

RUN sudo apt-get -qq update && sudo apt-get -qq -y install \
        vim zsh dash csh tcsh posh ksh fish \
        patch libmagic1 \
        curl gnupg apt-transport-https \
    && sudo rm -rf /var/lib/apt/lists/* /var/log/dpkg.log
# autoclean patch libmagic1 are needed for conda-build tests to pass
# curl gnupg apt-transport-https needed for powershell


# https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#debian-9
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - \
    && sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list' \
    && sudo apt-get update \
    && sudo apt-get install -y powershell \
    && sudo rm -rf /var/lib/apt/lists/* /var/log/dpkg.log


ENV PYTHON_VERSION 3.7

# conda bootstrap
RUN curl -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && sudo bash /tmp/miniconda.sh -bfp /opt/conda/ \
    && rm -rf /tmp/miniconda.sh


# conda test dependencies
RUN sudo /opt/conda/bin/conda create -p /opt/conda-py37 -y -c defaults -c conda-forge \
        python=$PYTHON_VERSION  \
    && sudo /opt/conda/bin/conda clean --all --yes

# conda test dependencies 2
RUN sudo /opt/conda-py37/bin/pip install \
        pycosat requests ruamel.yaml \
        anaconda-client nbformat \
        pytest pytest-cov pytest-timeout mock responses pexpect xonsh \
        flake8 \
    && sudo rm -rf ~root/.cache/pip

RUN sudo /opt/conda-py37/bin/pip install codecov radon \
    && sudo rm -rf ~root/.cache/pip

RUN sudo rm -rf /opt/conda \
    && cd /opt && sudo ln -s conda-py37 conda

RUN sudo git clone https://github.com/conda/conda /var/conda \
    && sudo /opt/conda/bin/pip install -e /var/conda

RUN sudo su root -c "/opt/conda/bin/conda init"

# RUN git clone https://github.com/conda/conda /go/conda \
#     && cd /go/conda \
#     && eval "$(sudo /opt/conda/bin/python -m conda init --dev bash)" \
#     && conda info

# # conda-build and test dependencies
# RUN sudo /opt/conda/bin/conda install -y -c defaults -c conda-forge \
#         conda-build patch git \
#         perl pytest-xdist pytest-mock \
#         anaconda-client \
#         filelock jinja2 conda-verify pkginfo \
#         glob2 beautifulsoup4 chardet pycrypto \
#     && sudo /opt/conda/bin/conda clean --all --yes
