import os
import sys
import shutil
import runpy
import importlib
import wagoTools
import requests

# Debug
debugBuild = "12.0.1.66384"
debugModule = "ToolEnchantData"

dataScripts = ["ToolEnchantData", "ConcentrationCurveData", "EnchantData", "OptionalReagentData", "ReagentWeightData", "SpecializationData"]

def getLatestBuildVersion(product="wow"):  # "wow" = retail
    url = "https://wago.tools/api/builds/latest"
    data = requests.get(url).json()
    build_info = data.get(product)
    if not build_info:
        raise ValueError(f"Product {product} not found")
    version = build_info["version"]
    print(f"🚀 Using latest build: {version} ({build_info['created_at']})")
    return version

def updateWagoTables(mappers, buildVersion):
    ## fetch wagoTables from mappers and save into _Data/{buildVersion}
    wagoTables = set()
    for mapper in mappers.values():
        if mapper != "SpecializationData":
            if hasattr(mapper, "wagoTables"):
                wagoTables.update(mapper.wagoTables)

    print(f"📥 Fetching DB2 Tables: {', '.join(wagoTables)}")

    wagoTools.downloadWagoTablesCSV(wagoTables, buildVersion)

    if "SpecializationData" in mappers:
        updateProfessionTraitsTable(buildVersion)

    

def updateDB2Data(buildVersion):
    mappers = getMappers()
    updateWagoTables(mappers, buildVersion)
    
    for mapper in mappers.values():
        print(f"🔄 Updating: {mapper}")
        mapper.map(buildVersion)
        mapper.copy(buildVersion)

def updateProfessionTraitsTable(buildVersion):
    sys.argv = [sys.argv[0], buildVersion]  # Pass buildVersion as an argument
    runpy.run_path("SpecializationData/wow-profession-tree/generate_database.py", run_name="__main__")
    runpy.run_path("SpecializationData/wow-profession-tree/profession_traits/get_csv_output.py", run_name="__main__")
    shutil.copy("SpecializationData/wow-profession-tree/output/csv_profession_traits.csv", f"_Data/{buildVersion}/csv_profession_traits.csv")
    os.remove("SpecializationData/wow-profession-tree/output/csv_profession_traits.csv")
    for file in os.listdir("SpecializationData/wow-profession-tree/data_source/"):
        os.remove(os.path.join("SpecializationData/wow-profession-tree/data_source/", file))


def isNewBuild(buildVersion):
    if os.path.exists("LAST_BUILD"):
        with open("LAST_BUILD", "r") as f:
            last_build = f.read().strip()
        return last_build != buildVersion
    return True

def getModuleFromPath(path):
    spec = importlib.util.spec_from_file_location("mapper", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

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
    buildVersion = debugBuild or getLatestBuildVersion()

    # Compare builds if an update is necessary, dont compare if debugBuild is set
    if not debugBuild and not isNewBuild(buildVersion):
        print(f"✅ DB2 Data up to date with Build: {buildVersion}. No update needed.")
        sys.exit(0)

    print(f"🔄 Updating DB2 Data for Build: {buildVersion}...")

    updateDB2Data(buildVersion)

    # Save buildVersion to a file for reference
    with open("LAST_BUILD", "w") as f:
        f.write(buildVersion)