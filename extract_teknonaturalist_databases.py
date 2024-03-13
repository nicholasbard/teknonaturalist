# ~ Extract all example database and assembly files in teknonaturalist directory (available in "Databases" and "Betula Assembly" components at https://osf.io/8g6we/). 
# ~ Note that the genbank.tar.gz and PLANits.tar.gz files are specific to Betula taxa in example study and may be replaced with plant taxon of interest. 

import os
import tarfile
import zipfile
import shutil

#### Extract taxon specific assemblies (saved as assembly.tar.gz). Can be used for Betula example.

def extract_and_save(file_path, output_directory):
    # Ensure the file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # Create target directory
    target_directory = os.path.join(output_directory, os.path.dirname(file_path))
    os.makedirs(target_directory, exist_ok=True)

    try:
        # Extract tar.gz file
        with tarfile.open(file_path, "r:gz") as tar:
            tar.extractall(target_directory)

        print(f"Extraction complete. Files from '{file_path}' are saved in '{target_directory}'.")
    except Exception as e:
        print(f"Error: {e}")

# Specify file path and output directory
file_to_extract = "./assembly.tar.gz"
output_directory = "."

# Extract file
extract_and_save(file_to_extract, output_directory)

##### Databases extraction, including host plant taxon-specific databases (saved as genbank.tar.gz, PLANits.tar.gz). Can be used for Betula example.

def extract_and_save(file_path, output_directory):
    # Ensure file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # Create target directory
    target_directory = os.path.join(output_directory, os.path.dirname(file_path))
    os.makedirs(target_directory, exist_ok=True)

    try:
        # Extract tar.gz file
        with tarfile.open(file_path, "r:gz") as tar:
            tar.extractall(target_directory)

        print(f"Extraction complete. Files from '{file_path}' are saved in '{target_directory}'.")
    except Exception as e:
        print(f"Error: {e}")

# Specify file paths and output directory
files_to_extract = [
    "./univec.tar.gz",
    "./genbank.tar.gz",
    "./PLANits.tar.gz",
    "./uchime_datasets.tar.gz",
    "./fungi.tar.gz"
]
output_directory = "./database"

# Extract each file
for file_path in files_to_extract:
    extract_and_save(file_path, output_directory)