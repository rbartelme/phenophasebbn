FROM cyversevice/jupyterlab-datascience:latest

LABEL maintainer="Ryan Bartelme rbartelme@arizona.edu"

USER root

RUN apt-get update && apt-get install -y \
	gcc \
	graphviz \
	graphviz-dev

#Install python3.8 since causalnex has not updated codebase to 3.9

RUN echo "**** Installing Python 3.8 ****" && \
    add-apt-repository ppa:deadsnakes/ppa &&  \
    apt-get install -y build-essential python3.8 python3.8-dev python3-pip && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3.8 get-pip.py && \
    rm -rf /var/lib/apt/lists/*

USER jovyan

RUN pip3.8 install torch --no-warn-script-location
RUN pip3.8 install pygraphviz --no-warn-script-location
RUN pip3.8 install causalnex --no-warn-script-location