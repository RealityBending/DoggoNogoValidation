import json

import numpy as np
import pandas as pd

import requests

# Load useful functions
exec(
    requests.get(
        "https://raw.githubusercontent.com/RealityBending/scripts/main/data_OSF.py"
    ).text
)

# Connect to OSF and get files --------------------------------------------
token = "zYboMoukFI8HKabenQ35DH6tESHJo6oZll5BvOPma6Dppjqc2jnIB6sPCERCuaqO0UrHAa"  # Paste OSF token here to access private repositories
files = osf_listfiles(  # Function in the data_OSF.py script loaded above
    token=token,
    data_subproject="wk3yz",  # Data subproject ID
    after_date="21/07/2024",
)

# Loop through files ======================================================
# Initialize empty dataframes
data_doggo = pd.DataFrame()

for i, file in enumerate(files):
    print(f"File N°{i+1}/{len(files)}")  # Print progress

    # Skip if participant already in the dataset
    if (
        "Participant" in data_doggo.columns
        and file["name"] in data_doggo["Participant"].values
    ):
        continue

    data = osf_download(file)  # Function in the data_OSF.py script loaded above
    data["metadata"]
    data["trials"][0]
    