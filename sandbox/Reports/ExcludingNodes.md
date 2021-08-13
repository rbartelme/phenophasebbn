## Excluding Node Arcs

---

### `bnlean` Arc Exclusion Syntax

* `bnlean` uses "Whitelisting" to input data nodes that we know *a priori* must be connected

* "blacklisting" input data nodes exlcudes the connections from being made

* both must be input as matrices with the column names `from` and `to`

* Added the following code block to `bnlearn_test.R`:

```R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Start building blacklist matrix for derived data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# wind weather data
wind_mat<-t(combn(grep("*wind_*", colnames(s4_bnIN), value = TRUE), m = 2))

# relative humidity
hum_mat <- t(combn(grep("rh_*", colnames(s4_bnIN), value = TRUE), m = 2))

# air temperature
air_mat <- t(combn(grep("*air_*", colnames(s4_bnIN), value = TRUE), m = 2))

#blacklist derived data in matrix
bl <- rbind(wind_mat, hum_mat, air_mat)
#add colnames recognized by bnlearn
colnames(bl) <- c("from", "to")

```

---

### Working with VCF files

* Need to convert to tabular format

* Important to white list:

  * cultivar &#8594; chromosome &#8594; position &#8594; mutation

* How do we cope with the dimensionality of these data? i.e. more mutations than environmental and phenotypic data? 
