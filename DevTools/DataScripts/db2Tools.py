import httpx
import os
import luadata
import csv

dataDirectoryPrefix = "Data/"
resultDirectoryPrefix = "Result/"

def downloadWagoTablesCSV(db2Tables):
    for table in db2Tables:
        print(f"Downloading {table}.csv")
        filename = f"{dataDirectoryPrefix}{table}.csv"
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        download = httpx.get(f"https://wago.tools/db2/{table}/csv")
        decoded_content = download.content.decode('utf-8')
        with open(filename, 'w') as f:
            f.writelines(decoded_content)

def loadCSVTables(db2Tables):
    csvTables = []
    for table in db2Tables:
        print(f"Loading Table: {table}")
        with open(f"{dataDirectoryPrefix}{table}.csv", mode='r') as file:
            csv_reader = csv.DictReader(file)
            data_table = []
            for row in csv_reader:
                data_table.append(row)
        csvTables.append(data_table)
        print(f"- Size: {str(len(data_table))}")
    return csvTables

def getWagoTables(db2Tables, download):
    if download:
        downloadWagoTablesCSV(db2Tables)
    return loadCSVTables(db2Tables)


def writeLuaTable(dataTable, fileName, prefix):
    print(f"Writing Lua File: {fileName}")
    fileName = f"{resultDirectoryPrefix}{fileName}.lua"
    os.makedirs(os.path.dirname(fileName), exist_ok=True)
    luadata.write(fileName, dataTable, encoding="utf-8", indent="\t", prefix=prefix)