FROM cyversevice/jupyterlab-datascience:latest

LABEL maintainer="Ryan Bartelme rbartelme@arizona.edu"

USER root

RUN apt-get update && apt-get install -y \
	gcc \
	graphviz \
	graphviz-dev

USER jovyan

RUN pip install torch causalnex pygraphviz


