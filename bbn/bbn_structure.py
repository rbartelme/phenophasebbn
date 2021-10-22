#!/usr/bin/env python

# import pandas and numpy
import pandas as pd
import numpy as np
import json
import torch

# NOTE: codebase adapted from another project, still a WIP
# NEEDS: functional python programming
# silence warnings
import warnings
warnings.filterwarnings("ignore")

# import StructureModel 
from causalnex.structure import StructureModel
sm = StructureModel()
#print diagnostic function
print("Reading input data...")
# read in descritized data
data = pd.read_csv('/work/phenophasebbn/bbn/rgr_snp_joined.csv')
print("Processing input data...")
#dummy encode categoricals and create binary vars for sm
from sklearn.preprocessing import LabelEncoder
dum_df = data.copy()


# encode binary categorical variables as 0's or 1's
non_numeric_columns = list(dum_df.select_dtypes(exclude=[np.number]).columns)
le = LabelEncoder()
for col in non_numeric_columns:
  dum_df[col] = le.fit_transform(dum_df[col])

# create json map files for downstream fitting of categoricals
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

#create empty list for DAG
wl = []
#dummy string
gen = "genotype"

#dummy list of fake gene names
ng = ["gen1", "gen2", "gen3"]

for i in range(len(ng)):
    temp = [gen, ng[i]]
    wl.append(temp)

#append season and growth rate
wl.append(["season", "gr"])
#create list of tuples
wl_tup = list(map(tuple, wl))

print(wl_tup)
#create blacklist in similar fashion
bl = [["season", "genotype"]]

for x in range(len(ng)):
    temp2 = [ng[i], "season"]
    bl.append(temp2)
bl_tup = list(map(tuple, bl))
print(bl_tup)



# learn structure with NOTEARS, over 1000 iterations,and keep edge weights > 0.95
#device = torch.cuda.is_available()
#print('GPU is available:', device)

#print("Starting NO TEARS DAG structure learning...")
#from causalnex.structure.notears import from_pandas

#sm = from_pandas(X=dum_df, max_iter=10, w_threshold=0.95)


#print("Finished structure learning...begin pickling structure model.")
##pickle the structure model
#import pickle
## make pickle file binary
#smp = open("/work/phenophasebbn/bbn/nt_sm", "wb")
# dump the pickle; syntax = (model, filename)
#pickle.dump(sm, smp)
# close the pickle
#smp.close()

#print("Generating image of DAG...")
#output plot of learned graph
# no need to apply thresholding, since this is taken care of in the sm with w_threshold
#from causalnex.plots import plot_structure
#viz = plot_structure(sm)
#viz.draw("/work/phenophasebbn/bbn/sm_plot.png")

