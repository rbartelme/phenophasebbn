# phenophasebbn
Phenophase Bayesian Belief Network in R

This project uses:

  - the [bnlearn](https://www.bnlearn.com/) R library
  - data from the TERRA-REF project

 To develop a probabilistic network predicting phenotype transitions in *Sorghum bicolor*

## Dynamic Bayesian Belief Network Examples

- [Using bnlearn](https://www.github.com/rbartelme/phenophasebbn)
- [Introduction to Dynamic Bayesian Networks](https://www.bayesserver.com/docs/introduction/dynamic-bayesian-networks)
  * suggests starting with a non-temporal network analysis of dataset
  * BayesServer itself is closed source

### Necessities for *Sorghum bicolor* data

- Encode datetime as simple series of T = [t<sub>0</sub>, t<sub>1</sub>, ..., t<sub>n</sub>]
- Encode cultivars with simple integers in network code

### Considerations for generalization of network

- Elmendorf *et al.*, 2019: [Time to branch out? Application of hierarchical survival models in plant phenology](https://www.sciencedirect.com/science/article/pii/S0168192319303107?via%3Dihub)
