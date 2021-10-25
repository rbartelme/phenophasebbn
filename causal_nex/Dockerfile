FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime

# Install causalnex and apt-get statements

RUN apt-get update && apt-get install -y \
        gcc \
        graphviz \
        graphviz-dev \
        nano \
	git \
        vim

#install causalnex via pip
RUN pip install causalnex pygraphviz
