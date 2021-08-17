#!/usr/bin/env python

# import pandas and numpy
import pandas as pd
import numpy as np

# NOTE: codebase adapted from another project, still a WIP
# NEEDS: functional python programming
# silence warnings
import warnings
warnings.filterwarnings("ignore")

# import StructureModel 
from causalnex.structure import StructureModel
sm = StructureModel()

# read in descritized data
data = pd.read_csv('~/work/phenophasebbn/bbn/rgr_snp_joined.csv')

#dummy encode categoricals and create binary vars for sm
from sklearn.preprocessing import LabelEncoder
dum_df = data.copy()


# encode binary categorical variables as 0's or 1's
non_numeric_columns = list(dum_df.select_dtypes(exclude=[np.number]).columns)
le = LabelEncoder()
for col in non_numeric_columns:
  dum_df[col] = le.fit_transform(dum_df[col])

# learn structure with NOTEARS, over 1000 iterations,and keep edge weights > 0.95
from causalnex.structure.notears import from_pandas
sm = from_pandas(X=dum_df, max_iter=1000, w_threshold=0.95)
#pickle the structure model
import pickle
# make pickle file binary
smp = open("nt_sm_a_halleri", "wb")
# dump the pickle; syntax = (model, filename)
pickle.dump(sm, smp)
# close the pickle
smp.close()

#output plot of learned graph
# no need to apply thresholding, since this is taken care of in the sm with w_threshold
from causalnex.plots import plot_structure
viz = plot_structure(sm)
viz.draw("sm_plot.png")

