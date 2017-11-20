FROM circleci/golang
MAINTAINER Conda Development Team <conda@continuum.io>

#  $ docker build . -t condatest/linux-64-python-3.6:latest
#  $ docker push condatest/linux-64-python-3.6

# NOTE: sudo is used in this Dockerfile because the circleci images default user is NOT root

RUN sudo apt-get -qq update && sudo apt-get -qq -y install \
        vim zsh dash \
    && sudo apt-get install patch libmagic1 \
    && sudo rm -rf /var/lib/apt/lists/* /var/log/dpkg.log
# autoclean patch libmagic1 are needed for conda-build tests to pass

ENV PYTHON_VERSION 3.6

# conda and test dependencies
RUN curl -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && sudo bash /tmp/miniconda.sh -bfp /opt/conda/ \
    && rm -rf /tmp/miniconda.sh \
    && sudo /opt/conda/bin/conda install -y \
        python=$PYTHON_VERSION pycosat conda requests ruamel_yaml \
        anaconda-client nbformat \
        pytest pytest-cov pytest-timeout mock responses pexpect \
        flake8 \
    && sudo /opt/conda/bin/conda clean --all --yes

RUN sudo /opt/conda/bin/pip install codecov radon \
    && sudo rm -rf ~root/.cache/pip

# conda-build and test dependencies
RUN sudo /opt/conda/bin/conda install -y -c defaults -c conda-forge \
        conda-build patch git \
        perl pytest-xdist pytest-catchlog pytest-mock \
        anaconda-client \
        filelock jinja2 conda-verify pkginfo \
        glob2 beautifulsoup4 chardet pycrypto \
    && sudo /opt/conda/bin/conda clean --all --yes
