import os
import sys
import shutil
import importlib

import requests

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
    for folderName in dataScripts:
        print(f"🔄 Updating data script: {folderName} for build {buildVersion}")
        os.chdir(folderName)
        # Dynamically import the mapper module and call its main function
        mapper_module = importlib.import_module('mapper')
        if hasattr(mapper_module, 'main'):
            mapper_module.main(buildVersion)
        else:
            print(f"⚠️  No main() function found in {folderName}/mapper.py")
        os.chdir("..")

def is_new_build(buildVersion):
    if os.path.exists("LAST_BUILD"):
        with open("LAST_BUILD", "r") as f:
            last_build = f.read().strip()
        return last_build != buildVersion
    return True

if __name__ == '__main__':
    buildVersion = get_latest_build()

    # Compare builds if an update is necessary
    if not is_new_build(buildVersion):
        print(f"✅ Data scripts are already up to date with build {buildVersion}. No update needed.")
        sys.exit(0)

    print(f"🔄 Updating data scripts for build {buildVersion}...")

    update_data_scripts(buildVersion)

    # Save buildVersion to a file for reference
    with open("LAST_BUILD", "w") as f:
        f.write(buildVersion)

    # for folderName in dataScripts:
    #     print("Updating data script: " + folderName)
    #     os.chdir(folderName)
    #     exec(open('mapper.py').read())
    #     os.chdir("..")