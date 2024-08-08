import httpx
import os
import luadata
import csv

dataDirectoryPrefix = "Data/"
resultDirectoryPrefix = "Result/"
latestDirectoryPrefix = "Latest/"

def getBuildDirectoryPrefix(buildVersion):
    if buildVersion:
        return f"{buildVersion}/"
    return latestDirectoryPrefix

def downloadWagoTablesCSV(wagoTables, buildVersion):
    for table in wagoTables:
        print(f"Downloading {table}.csv")
        filename = f"{dataDirectoryPrefix}{getBuildDirectoryPrefix(buildVersion)}{table}.csv"
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        buildParameter = f"?build={buildVersion}"
        if buildVersion == None:
            buildParameter = ""
        download = httpx.get(f"https://wago.tools/db2/{table}/csv{buildParameter}")
        decoded_content = download.content.decode('utf-8')
        with open(filename, 'w') as f:
            f.writelines(decoded_content)

def loadCSVTables(wagoTables, buildVersion):
    csvTables = []
    for table in wagoTables:
        print(f"Loading Table: {table}")
        with open(f"{dataDirectoryPrefix}{getBuildDirectoryPrefix(buildVersion)}{table}.csv", mode='r') as file:
            csv_reader = csv.DictReader(file)
            data_table = []
            for row in csv_reader:
                data_table.append(row)
        csvTables.append(data_table)
        print(f"- Size: {str(len(data_table))}")
    return csvTables

def getWagoTables(wagoTables, download, buildVersion):
    if download:
        downloadWagoTablesCSV(wagoTables, buildVersion)
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





def writeLuaTable(dataTable, fileName, prefix, buildVersion):
    print(f"Writing Lua File: {fileName}")
    fileName = f"{resultDirectoryPrefix}{getBuildDirectoryPrefix(buildVersion)}{fileName}.lua"
    os.makedirs(os.path.dirname(fileName), exist_ok=True)
    luadata.write(fileName, dataTable, encoding="utf-8", indent="\t", prefix=prefix)