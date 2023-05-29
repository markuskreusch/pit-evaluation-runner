#!/usr/bin/python3

import pandas as pd
from scipy import stats

versions = ["3.10","3.11","3.12","3.12-1","3.12-2","3.12-3"]

# read data

data = pd.read_csv("results.csv", sep=";")
data = data[data["version"] != "3.9"]

# Incremental analysis

part = data[(data["scenario"] == "non-incremental") | (data["scenario"] == "normal")]
agg = part.groupby(["version","scenario"]).agg(
    Count=("run", "count"),
    MeanTime=("time", "mean"),
    StdTime=("time", "std"),
    Mutants=("mutants","mean"),
    Killed=("killed","mean"),
    Incremental=("incremental","mean")
)
agg = agg.round({"MeanTime":1,"StdTime":2,"Mutants":0,"Killed":1,"Incremental":1,"MeanCombTime":1,"Combined":1})
print("")
print("########################")
print("# Incremental analysis #")
print("########################")
print(agg.to_string())
for version in versions:
    v = part[part["version"] == version]
    print("Version ",version)
    welch = stats.ttest_ind(v[v["scenario"] == "non-incremental"]["time"], v[v["scenario"] == "normal"]["time"], equal_var = False)
    print(welch)

# Combined mutant analysis

part = data[(data["scenario"] == "combinedMutantAnalysis") | (data["scenario"] == "normal")]
agg = part.groupby(["version","scenario"]).agg(
    Count=("run", "count"),
    MeanTime=("time", "mean"),
    StdTime=("time", "std"),
    Mutants=("mutants","mean"),
    Killed=("killed","mean"),
    Incremental=("incremental","mean"),
    MeanCombTime=("combinedTime", "mean"),
    Combined=("combined","mean")
)
agg = agg.round({"MeanTime":1,"StdTime":2,"Mutants":0,"Killed":1,"Incremental":1,"MeanCombTime":1,"Combined":1})
print("############################")
print("# Combined Mutant Analysis #")
print("############################")
print(agg.to_string())
for version in versions:
    v = part[part["version"] == version]
    print("Version ",version)
    welch = stats.ttest_ind(v[v["scenario"] == "combinedMutantAnalysis"]["time"], v[v["scenario"] == "normal"]["time"], equal_var = False)
    print(welch)

# Test prioritisation

part = data[(data["scenario"] == "normal") | (data["scenario"] == "prioritiseKillingTests") | (data["scenario"] == "prioritiseKillingTestsRandom") | (data["scenario"] == "randomTestOrder")]
agg = part.groupby(["version","scenario"]).agg(
    Count=("run", "count"),
    MeanTime=("time", "mean"),
    StdTime=("time", "std"),
    Mutants=("mutants","mean"),
    Killed=("killed","mean"),
    Incremental=("incremental","mean")
)
agg = agg.round({"MeanTime":1,"StdTime":2,"Mutants":0,"Killed":1,"Incremental":1})
print("######################")
print("# Test priortisation #")
print("######################")
print(agg.to_string())
for version in versions:
    v = part[part["version"] == version]
    print("Version ",version,"standard")
    welch = stats.ttest_ind(v[v["scenario"] == "prioritiseKillingTests"]["time"], v[v["scenario"] == "normal"]["time"], equal_var = False)
    print(welch)
    print("Version ",version,"random")
    welch = stats.ttest_ind(v[v["scenario"] == "randomTestOrder"]["time"], v[v["scenario"] == "prioritiseKillingTestsRandom"]["time"], equal_var = False)
    print(welch)
