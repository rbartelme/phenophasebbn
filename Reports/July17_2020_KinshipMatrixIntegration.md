## Kinship Matrix Integration:
*by Ryan Bartelme, PhD - July 17, 2020*

---

### General Notes:

- Need to specify custom model with `bnlearn` for each node
- Custom models can be ordinal
- Alternative approach with VCF file ingestion
- Subnetworks
- Feasibility of graph database

---

### Problem Definition:

Kinship matrix output by `TASSEL5` is a symmetrical diagonal matrix,
this needs to connect to the cultivar node in the graph structure via ordinal
pair-wise relationships, where when `CultivarA|CultivarB = 0.0` the SNP data
are identical, and when `CultivarA|CultivarB = 1.0` the cultivar SNPs are
unlinked and evolutionarily divergent.

---

#### Custom Model on Node-By-Node Basis

It's likely that this is the best approach for this problem.
The TASSEL5 kinship matrix can be joined to the dataframe, however,
the dimensionality may be an issue. For example if `CultivarA` appears `x`
times in the dataframe, how would the join be determined from the decomposed
diagonal matrix to the tabular matrix with environmental and phenotypic data?

- Perhaps it's best to add these elements to the tall format?

- Or join an equal number of rows for the decomposed kinship matrix into these data?

All of these scenarios could utilize custom fit per node, which would allow
the specification that all data are oridinal without explicitly including the date/time.

---

#### Alternative Integrating Raw VCF file

This is computationally intensive, due to large file size, but may be easier to join to the network. Need to find a good VCF to tabular data parser.

- Would the directionality be from cultivar to chromosome to location to SNP? Or the reverse?

- This is probably something worth discussing with Bryan, David, and Tyson.

---

#### Subnetworks

`bnlearn` only uses subnetworks to extract explicit elements from a network, it's not possible to combine networks explicitly.


---

#### Graph Networks

This could be a larger group approach, where we use a knowledge graph to connect the VCF to the cultivars and use the model over the top of the database for specific queries. Intuitive UI/UX would be more difficult than setting up the database itself.
