#!/bin/bash

set -e

## IDLE AUTOSTOP STEPS
## ----------------------------------------------------------------

## Setting the timeout (in seconds) for how long the SageMaker notebook can run idly before being auto-stopped
# -> e.g. 1800 s = 30 min since first deployment can take between 15 and 20 minutes which could then fail like so:
# "Error: error waiting for sagemaker notebook instance (aws-sm-notebook-instance) to create: unexpected state 'Failed', wanted target 'InService'. last error: %!s(<nil>)"
# Hint for solution under following link: https://yuyasugano.medium.com/machine-learning-infrastructure-terraforming-sagemaker-part-2-f2460a9a4663
IDLE_TIME=1800

# Getting the autostop.py script from GitHub
echo "Fetching the autostop script..."
wget https://raw.githubusercontent.com/andreasluckert/aws-sm-notebook-instance/main/scripts/autostop.py

# Using crontab to autostop the notebook when idle time is breached
echo "Starting the SageMaker autostop script in cron."
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python $PWD/autostop.py --time $IDLE_TIME --ignore-connections") | crontab -



## CUSTOM CONDA KERNEL USAGE STEPS
## ----------------------------------------------------------------

# Setting the proper user credentials
sudo -u ec2-user -i <<'EOF'
unset SUDO_UID

# Setting the source for the custom conda kernel
WORKING_DIR=/home/ec2-user/SageMaker/custom-miniconda
source "$WORKING_DIR/miniconda/bin/activate"

# Loading all the custom kernels
for env in $WORKING_DIR/miniconda/envs/*; do
    BASENAME=$(basename "$env")
    source activate "$BASENAME"
    python -m ipykernel install --user --name "$BASENAME" --display-name "Custom ($BASENAME)"
done