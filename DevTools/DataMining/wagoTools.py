import httpx
import os
import luadata
import csv

dataDirectoryPrefix = "../_Data/"
resultDirectoryPrefix = "Result/"
latestDirectoryPrefix = "Latest/"

# just a utility to make it easier to wait ;D
def updateProgressBar(progress, total, label=""):
    percent = 100 * (progress / float(total))
    bar = '█' * int(percent) + '-' * (100 - int(percent))
    print(f"\r|{bar}| {percent:.2f}% {label}", end='                                                     \r')

def getBuildDirectoryPrefix(buildVersion=None):
    if buildVersion:
        return f"{buildVersion}/"
    return latestDirectoryPrefix

def downloadWagoTablesCSV(wagoTables, buildVersion=None):
    count = 0
    total = len(wagoTables)
    for table in wagoTables:
        count = count + 1
        filename = f"{dataDirectoryPrefix}{getBuildDirectoryPrefix(buildVersion)}{table}.csv"
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        if os.path.isfile(filename):
            print("File already exists, skipping download: " + filename)
            continue
        updateProgressBar(count, total, table)
        buildParameter = f"?build={buildVersion}"
        if buildVersion == None:
            buildParameter = ""
        download = httpx.get(f"https://wago.tools/db2/{table}/csv{buildParameter}")
        decoded_content = download.content.decode('utf-8')
        with open(filename, 'w', errors="replace") as f:
            f.writelines(decoded_content)

def loadCSVTables(wagoTables, buildVersion=None):
    csvTables = []
    for table in wagoTables:
        print(f"Loading {table}: ", end='')
        filename = f"{dataDirectoryPrefix}{getBuildDirectoryPrefix(buildVersion)}{table}.csv"
        with open(filename, mode='r') as file:
            csv_reader = csv.DictReader(file)
            data_table = []
            for row in csv_reader:
                data_table.append(row)
        csvTables.append(data_table)
        print(f"- Size: {str(len(data_table))}")
    return csvTables

def getWagoTables(wagoTables, download, buildVersion=None):
    if download:
        print("Downloading Tables")
        downloadWagoTablesCSV(wagoTables, buildVersion)
    print("Loading Tables")
    return loadCSVTables(wagoTables, buildVersion)

# searchTerms: {multiple: boolean, conditions: dict}
def searchTable(table, searchTerms):
    singleResult = ("singleResult" in searchTerms) and searchTerms["singleResult"]
    conditions = searchTerms["conditions"]

    results = []

    for row in table:
        match = True
        for key, value in conditions.items():
            if row[key] != value:
                match = False
        if match:
            results.append(row)
            if singleResult:
                return row
    
    if singleResult:
        return None
            
    return results

def copyResult(file, destination):
    shutil.copy(file, destination)

def writeLuaTable(dataTable, fileName, prefix, buildVersion=None, silent=False):
    if not silent: print(f"\nWriting Lua File: {fileName}")
    fileName = f"{resultDirectoryPrefix}{getBuildDirectoryPrefix(buildVersion)}{fileName}.lua"
    os.makedirs(os.path.dirname(fileName), exist_ok=True)
    luadata.write(fileName, dataTable, encoding="utf-8", indent="\t", prefix=prefix)