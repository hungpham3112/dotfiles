#!/bin/bash

# Specify the Miniconda version and platform
MINICONDA_VERSION="latest"
PLATFORM=$(uname -s)-$(uname -m)
ARCHIVE_EXT=".sh"

# Download the Miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-$PLATFORM$ARCHIVE_EXT

# Verify the integrity of the downloaded installer (optional)
# Uncomment the following line if you want to verify the integrity of the downloaded installer
# wget https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-$PLATFORM$ARCHIVE_EXT.sha256
# sha256sum -c Miniconda3-$MINICONDA_VERSION-$PLATFORM$ARCHIVE_EXT.sha256

# Make the installer executable
chmod +x Miniconda3-$MINICONDA_VERSION-$PLATFORM$ARCHIVE_EXT

# Run the Miniconda installer
./Miniconda3-$MINICONDA_VERSION-$PLATFORM$ARCHIVE_EXT

# Clean up the downloaded installer (optional)
# Uncomment the following line if you want to clean up the downloaded installer after installation
rm Miniconda3-$MINICONDA_VERSION-$PLATFORM$ARCHIVE_EXT -f

# Add Miniconda to PATH
# Note: This assumes that Miniconda is installed in the default location ($HOME/miniconda3)
dir="$HOME/miniconda3/bin"

# Check if the directory is already in PATH
if [[ ":$PATH:" != *":$dir:"* ]]; then
  # If not, append it to .bashrc
  echo 'export PATH="'$dir':$PATH"' >> ~/.bashrc
  echo "Directory added to PATH in .bashrc"
else
  # If already in PATH, display a message
  echo "Directory is already in PATH"
fi

source $HOME/.bashrc
