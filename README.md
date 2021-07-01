# *Sorghum bicolor bicolor* Phenophase Bayesian Belief Network in R & Python

This project uses:

  - [Rocker Group](https://github.com/rocker-org)'s Tidyverse R 4.0 Ubuntu 18 LTS docker container image
  - data from the [TERRA-REF project](https://www.terraref.org/) accessed through the [traits](https://docs.ropensci.org/traits/) R package
  - [jags](https://mcmc-jags.sourceforge.io/) for Gibbs Sampled MCMC modeling
  - [causalnex](https://causalnex.readthedocs.io/en/latest/) to implement the `NO TEARS` directed acyclic graph structure learning algorithm as described [here](https://github.com/xunzheng/notears)
  - Under the hood, `causalnex` also uses `pandas`, `sklearn`, and `igraph`

To develop a causal Bayesian network, also known as a Bayesian Belief Network,  predicting growth rate as a phenotype from the  *Sorghum bicolor* biomass accumulation panel.

This analysis produces a casual inference Bayesian Belief Network similar to Judea Pearle's [work](https://escholarship.org/content/qt53n4f34m/qt53n4f34m.pdf), where the nodes (vertices) of the network represent variables and the edges (arcs) represent linked dependencies supported by [conditional probailities](https://en.wikipedia.org/wiki/Conditional_probability#:~:text=In%20probability%20theory%2C%20conditional%20probability,or%20evidence)%20has%20already%20occurred.)


---

### Docker Container Setup

For reproducibility and scalability, we have containerized the dependencies into an Ubuntu 18 LTS RStudio Server docker environment, which allows users to run the R code without installing or troubleshooting dependencies.

Additionally, a command-line container for CausalNex was created to streamline graph structure learning while also maintaining the same standard of reproduction as the R code.

---

#### Docker Container Availability

The Docker container for these R analyses is hosted on the [CyVerse VICE DockerHub page](https://hub.docker.com/repository/docker/cyversevice/rstudio-bayes-cpu). This is hosted in [CyVerse VICE](https://de2.cyverse.org/). 


To run the latest version of this docker container image locally you can do the following:

1. Install [docker](https://www.docker.com/) locally. 
2. Execute the following docker command: `docker pull cyversevice/rstudio-bayes-cpu:latest`
3. Wait for docker to pull the container from docker hub
4. Execute the following command to run the container `docker run -d -it -rm -p 8787:80 -e REDIRECT_URL=http://localhost:8787 cyversevice/rstudio-bayes-cpu:latest`
5. Open a web browser and go to the url `http://localhost:8787`, RStudio Server should be available in this browser window.

*Note: if docker is running remotelyyou can replace localhost with the address of the remote machine*


#### Log on to CyVerse Discovery environment

[Click here for details on the CyVerse Discovery Environment](https://learning.cyverse.org/projects/container_camp_workshop_2019/en/latest/cyverse/de_docker.html)

  1. Load application `Bnlearn_Rstudio_CPU`

  2. When prompted that the analysis is running log in to the Rstudio container

  - the `username` is `rstudio` and the `password` is `rstudio1`

  3. This directory can be cloned in the `RStudio` environment by navigating through the GUI menu:

  - `File` &#8594; `New R Project` &#8594; `git`

  - You will then be prompted for this directory and able to clone it into the container environment

  4. At this point you will need to setup the iRODS system to transfer files

---

#### iRODS setup in Rstudio

  1. Open `RStudio` `Terminal` tab

  2. Execute `iinit` to begin iRODS setup for the [CyVerse Data Store](https://data.cyverse.org/)

  3. You will be prompted to enter the following:
  - Enter your irods user name: `(your CyVerse.org login)`
  - Enter your current iRODS password: `(your CyVerse password)`

  4. Input files may now be moved into the container environment with `iget`

  5. Files may be exported with `iput`
  
  6. Scripts in this repository that make calls to iRODS with the R function `system()` will now work

---

#### Transferring Files and Using Clean Up Script

  1. Use `icd` to navigate to the directory containing the season 4 data

  2. Use `iget` to move the csv `FILENAME` from `/some/cyverse/datastore/dir/` into the directory `phenophasebbn/`

  3. Repeat step 2 for the `/season4/weather/data/dir` and `/cultivar/experiment/list`

  4. Run cleanup script `season4_bnprocess.R` in Rstudio environment

  - Note: Each step should be documented with comments in the script

  5. Export combined season 4 dataset

---

#### Importing this repository into Docker Container environment

1. Under the Rstudio menu "New Project", select "version control"

2. In the next menu select "Git"

3. Input the full url of this repo and the directory information should autopopulate

4. Now the analyses can be run inside the container.

5. Refer to the iRODS documentation on how the analysis outputs may be moved around in the CyVerse Data Store 

---
### Running Bayesian Belief Network Analysis

#### JupyterLab Docker Image

To access the latest version of the Bayesian Belief Network JupyterLab container with `torch` + `causalnex` run `docker pull rbartelme/jupyterlab-pytorch-causalnex:latest`

#### Command Line Causal Nex Docker Image

Run `docker pull rbartelme pytorch-causalnex:0.0.2`

