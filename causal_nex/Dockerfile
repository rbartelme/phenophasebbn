FROM pytorch/pytorch:1.6.0-cuda10.1-cudnn7-runtime

# AS OF 8-25-2021 THIS THROWS AN ERROR FOR PYTHON VERSIONING, BUT WILL RUN ON TORCH >=1.4.0, < 2.0

# this now uses an earlier version of torch


# Install causalnex and apt-get statements

RUN apt-get update && apt-get install -y \
        gcc \
        graphviz \
        graphviz-dev \
        nano \
	git \
        vim

#install causalnex from personal fork and tag
RUN git clone https://github.com/rbartelme/causalnex.git && cd causalnex \
	&& python setup.py install
