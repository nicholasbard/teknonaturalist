import os
import glob

#~ This Python script may be run to verify that the current directory is [...]/teknonaturalist/, that files are present within the assembly, database, data directories, 
#~ that Snakefile and environment.yaml files are present, and the conda environment 'teknonaturalist' is activated.

def check_conditions():
    base_directory = "database"

    # files in database/genbank?
    genbank_directory = os.path.join(base_directory, "genbank")
    genbank_files = glob.glob(os.path.join(genbank_directory, "*.*.Genbank.nucl.fasta*"))
    if not genbank_files:
        print("Error: No files matching the pattern '*.Genbank.nucl.fasta*' found in 'database/genbank'.")
        return False

    # files in database/PLANiTS?
    planits_directory = os.path.join(base_directory, "PLANiTS")
    planits_files = glob.glob(os.path.join(planits_directory, "*.fasta*"))
    if not planits_files:
        print("Error: No files matching the pattern '*.fasta*' found in 'database/PLANiTS'.")
        return False

    # files in database/uchime_datasets?
    uchime_directory = os.path.join(base_directory, "uchime_datasets")
    uchime_files = glob.glob(os.path.join(uchime_directory, "*fasta*"))
    if len(uchime_files) < 2:
        print("Error: Less than 2 files matching the pattern '*fasta*' found in 'database/uchime_datasets'.")
        return False

    # files in database/fungi?
    fungi_directory = os.path.join(base_directory, "fungi")
    fungi_files = glob.glob(os.path.join(fungi_directory, "*k2d*"))
    if len(fungi_files) < 3:
        print("Error: Less than 3 files matching the pattern '*k2d*' found in 'database/fungi'.")
        return False

    # is current directory 'teknonaturalist'?
    current_directory = os.getcwd()
    if os.path.basename(current_directory) != 'teknonaturalist':
        print("Error: Please make sure you are inside the 'teknonaturalist' directory.")
        return False

    # is there a file that begins with 'Snakefile'?
    snakefile_found = any(filename.startswith('Snakefile') for filename in os.listdir(current_directory))
    if not snakefile_found:
        print("Error: No file starting with 'Snakefile' found.")
        return False

    # is there a file called 'environment.yaml'?
    environment_yaml_path = os.path.join(current_directory, 'environment.yaml')
    if not os.path.exists(environment_yaml_path):
        print("Error: 'environment.yaml' file not found.")
        return False

    # non-empty required directories?
    required_directories = ['assembly', 'data', 'database']
    for directory_name in required_directories:
        directory_path = os.path.join(current_directory, directory_name)
        if not os.path.exists(directory_path) or not os.listdir(directory_path):
            print(f"Error: Directory '{directory_name}' does not exist or is empty.")
            return False

    # is conda environment 'teknonaturalist' activated?
    conda_env = os.getenv('CONDA_DEFAULT_ENV')
    if conda_env != 'teknonaturalist':
        print("Error: Conda/Mamba environment 'teknonaturalist' is not activated.")
        return False

    print("All conditions are met.")
    return True

# check_conditions function
check_conditions()