# ~ Extract ITS reference databases for fungal classification with DNAbarcoder (available as ITS.refs.tar.gz at https://osf.io/j57fs/). 

import os
import tarfile
import zipfile
import shutil

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
file_to_extract = "./ITS.refs.dnabarcoder.tar.gz"
output_directory = "./dnabarcoder"

# Extract file
extract_and_save(file_to_extract, output_directory)
