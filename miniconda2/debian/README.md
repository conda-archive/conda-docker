# docker-miniconda

Docker container with a bootstrapped installation of conda and python 2.7 that is ready to use.

Conda and python 2.7 are installed into the `/usr/local` prefix, with executables `/usr/local/bin/conda` and `/usr/local/bin/python`.

Anaconda is the leading open data science platform powered by Python. The open source version of Anaconda is a high performance distribution and includes over 100 of the most popular Python packages for data science. Additionally, it provides access to over 720 Python and R packages that can easily be installed using the conda dependency and environment manager, which is included in Anaconda.

Usage
-----

You can download and run this image using the following commands:

    docker pull conda/miniconda2
    docker run -i -t conda/miniconda2 /bin/bash

Alternatively, you can start a Jupyter Notebook server and interact with Miniconda via your browser:

    docker run -i -t -p 8888:8888 conda/miniconda2 /bin/bash -c "/opt/conda/bin/conda install jupyter -y --quiet && mkdir /opt/notebooks && /opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser"

You can then view the Jupyter Notebook by opening `http://localhost:8888` in your browser, or `http://<DOCKER-MACHINE-IP>:8888` if you are using a Docker Machine VM.
