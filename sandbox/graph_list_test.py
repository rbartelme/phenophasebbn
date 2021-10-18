
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
