FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-runtime

# Install causalnex and apt-get statements

RUN apt-get update && apt-get install -y \
        gcc \
        graphviz \
        graphviz-dev \
        nano \
	git \
        vim

RUN pip install git+git://github.com/quantumblacklabs/causalnex.git@13aa7473138c4aecb2cd2cc16afba74141d79593
