## Fitting Parameters Report:
*by Ryan Bartelme, PhD - June 5th, 2020*

---
### Rationale:

* After drawing/specifying a DAG the data must be fit to the network
* Data are currently a mix of discrete and continuous

---

### Parameter fitting to nodes

* two methods available: Maximum likelihood estimate *or* Bayesian
- MLE will work with continuous data
- Bayes will only work with discrete data

* may need to make continuous data discrete?
* *OR*
* MLE can be utilized

* Will likely need to treat network as "Conditional Linear Gaussian Bayesian Network"
- Good example of implementation in climate science with Shiny app by [Vitolo *et al.*, 2018](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2017EA000326)

---

#### `bn.fit` Function Arguments and Rules

```R

# Basic Fit Function
bn.fit(x, data, cluster = NULL, method = "mle", ..., keep.fitted = TRUE,
  debug = FALSE)

# Custom Fitting
custom.fit(x, dist, ordinal, debug = FALSE)
```
* Custom fit may be unnecessary, but Vitolo *et al.*, 2018 did a great job fitting heterogenous data with:
- an empty graph (to eliminate bias)
- hill-climbing to learn the network graph structure
- maximum likelihood estimate for parameter fitting

---

### Conclusions:

* Vitolo *et al.*, 2018 offers a good start, but need to further investigate how they implemented the network with ordinal data

* It is good to try to hard code the graph with what we know from the Terra-ref data

* It is likely best to compare the domain informed graph vs. the learned graph
