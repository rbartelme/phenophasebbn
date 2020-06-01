# phenophasebbn
Phenophase Bayesian Belief Network in R

This project uses:

  - [Rocker Group](https://github.com/rocker-org)'s Tidyverse Docker Container Version 3.6.2 as the base image
  - the [bnlearn](https://www.bnlearn.com/) R library
  - data from the [TERRA-REF project](https://www.terraref.org/)

 To develop a probabilistic network predicting phenotype transitions in *Sorghum bicolor*

---

### Container Setup

---

#### Log on to CyVerse Discovery environment

[Click here for details on the CyVerse Discovery Environment](https://learning.cyverse.org/projects/container_camp_workshop_2019/en/latest/cyverse/de_docker.html)

  1. Load application `Bnlearn_Rstudio_CPU`
  2. When prompted that the analysis is running log in to the Rstudio container
  3.

---

#### iRODS setup in Rstudio

  1. Open `RStudio` `Terminal` tab

  2. Execute `iinit` to begin iRODS setup for the [CyVerse Data Store](https://data.cyverse.org/)

  3. You will be prompted to enter the following:
  - Enter the host name (DNS) of the server to connect to: `data.cyverse.org`
  - Enter the port number: `1247`
  - Enter your irods user name: `(your CyVerse.org login)`
  - Enter your irods zone: `iplant`
  - Enter your current iRODS password: `(your CyVerse password)`

  4. Input files may now be moved into the container environment with `iget`

  5. Files may be exported with `iput`

  6. This directory can be cloned in the `RStudio` environment by navigating through the GUI menu:
    * File => New R Project => git

---

## Project Notes

### Dynamic Bayesian Belief Network Examples

- [Using bnlearn](https://www.github.com/rbartelme/phenophasebbn)
- [Introduction to Dynamic Bayesian Networks](https://www.bayesserver.com/docs/introduction/dynamic-bayesian-networks)
  * suggests starting with a non-temporal network analysis of dataset
  * BayesServer itself is closed source

### Necessities for *Sorghum bicolor* data

- Encode datetime as simple series of T = [t<sub>0</sub>, t<sub>1</sub>, ..., t<sub>n</sub>]
- Encode cultivars with simple integers in network code
- Winnow data to match MSU neural network team's input variables

### Considerations for generalization of network

- Elmendorf *et al.*, 2019: [Time to branch out? Application of hierarchical survival models in plant phenology](https://www.sciencedirect.com/science/article/pii/S0168192319303107?via%3Dihub)
