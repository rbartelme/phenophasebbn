## Kinship Matrix Integration:
*by Ryan Bartelme, PhD - June 25th, 2020*

---

### General Notes:

- Need to specify custom model with `bnlearn` for each node
- Custom models can be ordinal

---

### Problem Definition:

Kinship matrix output by `TASSEL5` is a symmetrical diagonal matrix,
this needs to connect to the cultivar node in the graph structure via ordinal
pair-wise relationsips, where when `CultivarA|CultivarB = 0.0` the SNP data
are identical, and when `CultivarA|CultivarB = 1.0` the cultivar SNPs are
unlinked and evolutionarily divergent.

---
