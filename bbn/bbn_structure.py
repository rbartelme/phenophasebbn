#!/usr/bin/env python

# import pandas and numpy
import pandas as pd
import numpy as np
import json
import torch
import re

# NOTE: codebase adapted from another project, still a WIP
# NEEDS: functional python programming
# silence warnings
import warnings
warnings.filterwarnings("ignore")

#print diagnostic function
print("Reading input data...")
# read in descritized data
data = pd.read_csv('/work/phenophasebbn/bbn/rgr_snp_joined.csv')
print("Encoding DAG from expert knowledge.")
# build initial DAG from expert knowledge
#create empty list for DAG 
wl = []
# genotype column string
gen = "genotype"

# get list of columnns matching regex for SORBI prepend
    # from input dataset
node_names = [col for col in data]
#use regular expressions library to find 
# SORBI gene annotations from the SNP abundance matrix
r = re.compile("SORBI*")
ng = list(filter(r.match, node_names))
#print("Debug sorghum gene names")
#print(ng)

# encode DAG with expert knowledge
for i in range(len(ng)):
    temp = [gen, ng[i]]
    wl.append(temp)

#append season and growth rate
wl.append(["season", "gr"])
#create list of tuples
wl_tup = list(map(tuple, wl))
#debug:
#print(wl_tup)
#create blacklist in similar fashion
bl = [["season", "genotype"]]

for x in range(len(ng)):
    temp2 = [ng[i], "season"]
    bl.append(temp2)
bl_tup = list(map(tuple, bl))
#debug
#print(bl_tup)
print(type(wl_tup))
print(all(isinstance(item, tuple) for item in wl_tup))


# import StructureModel 
from causalnex.structure import StructureModel
#instantiate structure model
sm = StructureModel(incoming_graph_data=wl_tup, origin="expert")

#print("Generating image of initial DAG...")
#output plot of learned graph
# no need to apply thresholding
from causalnex.plots import plot_structure
exp_viz = plot_structure(
    sm,
    graph_attributes={"scale": "0.5"}
)
exp_viz.draw("/work/phenophasebbn/bbn/init_graph.png")

# Prep data for structure learning algorithm
print("Processing input data...")
#dummy encode categoricals and create binary vars for sm
from sklearn.preprocessing import LabelEncoder
dum_df = data.copy()

# encode binary categorical variables as 0's or 1's
non_numeric_columns = list(dum_df.select_dtypes(exclude=[np.number]).columns)
le = LabelEncoder()
for col in non_numeric_columns:
  dum_df[col] = le.fit_transform(dum_df[col])

# create json map files for provenance of categorical encoding
# -------------------------------------------------------------
# only two categorical variables genotype and season
# -------------------------------------------------------------
#
# genotype map file from dataframe columns to dict
cultivar = [data['genotype'], dum_df['genotype']]
genotypes = pd.concat(cultivar, axis=1)
genotype_uniq = genotypes.drop_duplicates()
genotype_uniq.set_axis(['genotype', 'encoding'], axis=1, inplace=True)
genotype_map = dict(zip(genotype_uniq.genotype, genotype_uniq.encoding))

# hardcoded seasons as dict
season_map = dict({'season_4': 0, 'season_6': 1})

with open("/work/phenophasebbn/bbn/genotype_map.json", "w") as outfile:
    json.dump(genotype_map, outfile)
with open("/work/phenophasebbn/bbn/season_map.json", "w") as outfile:
    json.dump(season_map, outfile)
print("Finished writing metadata for encoding categoricals...")

print("Begin embedding expert knowledge into DAG...")


# learn structure with NOTEARS, over 1000 iterations,and keep edge weights > 0.95
#device = torch.cuda.is_available()
#print('GPU is available:', device)

#print("Appending NO TEARS DAG structure learning to expert encoded DAG...")
# from causalnex.structure.notears import from_pandas

# learned_sm = exp_sm.from_pandas(X=dum_df, max_iter=10, w_threshold=0.95)


#print("Finished structure learning...begin pickling structure model.")
##pickle the structure model
#import pickle
## make pickle file binary
#smp = open("/work/phenophasebbn/bbn/nt_sm", "wb")
# dump the pickle; syntax = (model, filename)
#pickle.dump(learned_sm, smp)
# close the pickle
#smp.close()

#print("Generating image of final DAG...")
#output plot of learned graph
# no need to apply thresholding, since this is taken care of in the sm with w_threshold
#from causalnex.plots import plot_structure
#viz = plot_structure(learned_sm)
#viz.draw("/work/phenophasebbn/bbn/final_graph.png")

