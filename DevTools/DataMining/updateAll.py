import os
import sys
import shutil
import importlib
import wagoTools

import requests

# Debug
debugBuild = None
debugModule = None

dataScripts = ["ConcentrationCurveData", "EnchantData", "OptionalReagentData", "ReagentWeightData"] ## SpecializationData is a special case (manually)

# === AUTO-FETCH LATEST BUILD (this is the key new part) ===
def get_latest_build(product="wow"):  # "wow" = retail, change if you need classic etc.
    url = "https://wago.tools/api/builds/latest"
    data = requests.get(url).json()
    build_info = data.get(product)
    if not build_info:
        raise ValueError(f"Product {product} not found")
    version = build_info["version"]
    print(f"🚀 Using latest build: {version} ({build_info['created_at']})")
    return version

def update_data_scripts(buildVersion):
    mappers = getMappers()
    ## fetch wagoTables from mappers
    wagoTables = set()
    for mapper in mappers.values():
        if hasattr(mapper, "wagoTables"):
            wagoTables.update(mapper.wagoTables)

    print(f"📥 Fetching DB2 Tables: {', '.join(wagoTables)}")

    wagoTools.downloadWagoTablesCSV(wagoTables, buildVersion)
    
    for mapper in mappers.values():
        print(f"🔄 Updating: {mapper}")
        mapper.map(False, buildVersion)
        mapper.copy(buildVersion)

def is_new_build(buildVersion):
    if os.path.exists("LAST_BUILD"):
        with open("LAST_BUILD", "r") as f:
            last_build = f.read().strip()
        return last_build != buildVersion
    return True

def getMappers():
    mappers = {}
    dataScriptTables = dataScripts
    if debugModule:
        dataScriptTables = [debugModule]
    for folderName in dataScriptTables:
        mapper_path = os.path.join(folderName, "mapper.py")
        if os.path.exists(mapper_path):
            spec = importlib.util.spec_from_file_location(f"{folderName}.mapper", mapper_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            mappers[folderName] = module
        else:
            print(f"⚠️  Mapper not found for {folderName} at {mapper_path}")
    return mappers

if __name__ == '__main__':
    buildVersion = debugBuild or get_latest_build()

    # Compare builds if an update is necessary, dont compare if debugBuild is set
    if not debugBuild and not is_new_build(buildVersion):
        print(f"✅ DB2 Data up to date with Build: {buildVersion}. No update needed.")
        sys.exit(0)

    print(f"🔄 Updating DB2 Data for Build: {buildVersion}...")

    update_data_scripts(buildVersion)

    # Save buildVersion to a file for reference
    with open("LAST_BUILD", "w") as f:
        f.write(buildVersion)

    # for folderName in dataScripts:
    #     print("Updating data script: " + folderName)
    #     os.chdir(folderName)
    #     exec(open('mapper.py').read())
    #     os.chdir("..")