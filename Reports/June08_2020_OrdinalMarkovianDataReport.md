## Ordinal and Markovian Data Report:
*by Ryan Bartelme, PhD - June 8th, 2020*

---
### Rationale:

* Plant growth is an ordinal output
* Analyses do not account for time
* Markovian timeseries may be necessary; ex. T = [t<sub>0</sub>, t<sub>1</sub>, ..., t<sub>n</sub>]

---

### Data Discretization

* `bnlearn` implements the following for discretization and deduplication of highly correlated variables

```R
# discretize continuous data into factors.
discretize(data, method, breaks = 3, ordered = FALSE, ..., debug = FALSE)

# screen continuous data for highly correlated pairs of variables.
dedup(data, threshold, debug = FALSE)
```

* `method = ` options are:
  * `"interval"` for interval discretization
  * `"quantile"` *default*, for quantile discretization
  * `"hartemink"` for Hartemink's pairwaise mutual information discretization

Note from `bnlearn` manual on Hartemink's methods:

```
Hartemink's algorithm has been designed to deal with sets of homogeneous, continuous variables; this is the reason why they are initially transformed into discrete variables, all with the same number of levels (given by the ibreaks argument). Which of the other algorithms is used is specified by the idisc argument (quantile is the default). The implementation in bnlearn also handles sets of discrete variables with the same number of levels, which are treated as adjacent interval identifiers. This allows the user to perform the initial discretization with the algorithm of their choice, as long as all variables have the same number of levels in the end.
```
---

### Conditional Independence testing

* `bnlearn` implements a Jonckheere-Terpstra test for ordinal data with the function `ci.test()` where:
  * Inputs are ``
  * For *Discrete Bayesian Networks*
    * `test = "jt"` is the asymptomatic normal test
    * `test = "mc-jt"`is the Monte Carlo permutation test
    * `test = smc-jt` is the sequential Monte Carlo permutation test
  * For *Mixed Discrete and Normal, or Hybrid Networks*
    * `test = "mi-cg"` is the asymptomatic chi-square test of mutual information (an information theoretical distance)
  * `B = n` where `n` is an integer corresponding to the number of permutations
