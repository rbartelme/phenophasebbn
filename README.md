# *Sorghum bicolor bicolor* Phenophase Bayesian Belief Network in R & Python

This project uses:

  - [Rocker Group](https://github.com/rocker-org)'s Tidyverse R 4.0 Ubuntu 18 LTS docker container image
  - data from the [TERRA-REF project](https://www.terraref.org/) accessed through the [traits](https://docs.ropensci.org/traits/) R package
  - [jags](https://mcmc-jags.sourceforge.io/) for Gibbs Sampled MCMC modeling
  - [causalnex](https://causalnex.readthedocs.io/en/latest/) to implement the `NO TEARS` directed acyclic graph structure learning algorithm as described [here](https://github.com/xunzheng/notears)
  - Under the hood, `causalnex` also uses `pandas`, `sklearn`, and `igraph`

To develop a causal Bayesian network, also known as a Bayesian Belief Network,  predicting growth rate as a phenotype from the  *Sorghum bicolor* biomass accumulation panel.

This analysis produces a casual inference Bayesian Belief Network similar to Judea Pearle's [work](https://escholarship.org/content/qt53n4f34m/qt53n4f34m.pdf), where the nodes (vertices) of the network represent variables and the edges (arcs) represent linked dependencies supported by [conditional probailities](https://en.wikipedia.org/wiki/Conditional_probability#:~:text=In%20probability%20theory%2C%20conditional%20probability,or%20evidence%20has%20already%20occurred).


---

### Docker Container Setup

For reproducibility and scalability, we have containerized the dependencies into an Ubuntu 18 LTS RStudio Server docker environment, which allows users to run the R code without installing or troubleshooting dependencies.

Additionally, a command-line container for CausalNex was created to streamline graph structure learning while also maintaining the same standard of reproduction as the R code.

---

#### Docker Container Image Availability

The Docker container for these R analyses is hosted on the [CyVerse VICE DockerHub page](https://hub.docker.com/repository/docker/cyversevice/rstudio-bayes-cpu). This is hosted in [CyVerse VICE](https://de2.cyverse.org/). 

The JupyterLab container to examine the python codebase is also integrated into CyVerse VICE.
