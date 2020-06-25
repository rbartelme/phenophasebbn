## Network Learning Cross Validation:
*by Ryan Bartelme, PhD - June 23rd, 2020*

---

### Rationale:

* Optimize Cross Validation of Network Fitting/Structure

---

### Optimizing Cross-Validation of Networks

The [bnlearn examples](https://www.bnlearn.com/examples/xval/) suggest that `k=10` or 10-fold cross-validation is the standard with Bayesian Networks. However, there is some flexibility within this framework, `k=5` is also suggested. As well as giving the user the option to specify a custom means of folding the data.

The use cases are varied, and seem somewhat redundant when working through the network in a step wise fashion.

---

Ideally this network will implement:

#### Cross-Validation with BIC and BDE

Where `df` `:=` dataset, and `network_graph` `:=` graphs generated from learning algorithms. This uses `k = 10`, or 10-fold cross validation, `k = 5` was also suggested as an alternative.

```R
# BIC C-V
cv.bic = bn.cv(df, bn = network_graph, k = 10, algorithm.args = list(score = "bic"))

# BDe C-V
cv.bde = bn.cv(df, bn = network_graph, k = 10, algorithm.args = list(score = "bde", iss = 1))

# compare BIC and BDe scores with box plots
plot(cv.bic, cv.bde, xlab = c("BIC", "BDe"))

```

The model should be extended to try to compare multiple graphs learned from MAC Season 4 (S4) and Season 6 (S6) data.
