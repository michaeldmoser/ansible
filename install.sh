#! /bin/bash
#
# This script is intended to be run on a fresh install of a Debian or Darwin based system. Since 
# both OSX and Debian have python3 installed by default we work based off of that. However, Debian
# does funky stuff with python3 so using pip doesn't work as expected. This script will install
# python3-venv if it's not already installed and then create a virtual environment to install ansible
# into. This is done to avoid polluting the system python3 environment especially as it's all going 
# to be overwritten by ansible anyway when python is installed with asdf.
#
mkdir -p /tmp/computer-setup
cd /tmp/computer-setup

# These likely worn't work on a fresh install of Debian because of how python3 is installed
python3 -m pip install --upgrade pip  &> /dev/null
python3 -m pip install virtualenv  &> /dev/null

PYENV_PATH="venv"
PYENV_BIN="$PYENV_PATH/bin"
python3 -m venv "$PYENV_PATH" &> /dev/null
if ! [[ -f "$PYENV_PATH"/activate ]]; then
  # If we're here then we're likely on a recent Debian based system which doesn't have venv installed
  sudo apt-get update &> /dev/null && sudo apt-get install -y python3-venv &> /dev/null
  python3 -m venv "$PYENV_PATH" 
fi
source "$PYENV_BIN/activate"

# This should work on both Debian and Darwin based systems
python3 -m pip install pipx
python3 -m pipx install --include-deps ansible

export PATH="~/.local/bin:$PATH"

# Download the repository
# Leave commented out while testing
# git clone https://github.com/michaeldmoser/ansible.git
# cd ansible
cd /ansible

# Install the ansible-galaxy roles
ansible-galaxy install -r requirements.yml

# Run the playbook
ansible-playbook -i inventory --ask-vault-pass base.yml

deactivate
