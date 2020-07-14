#!/bin/bash

set -e

# OVERVIEW
# This script stops a SageMaker notebook once it's idle for more than 1 hour (default time)
# You can change the idle time for stop using the environment variable below.
# If you want the notebook the stop only if no browsers are open, remove the --ignore-connections flag
#
# Note that this script will fail if either condition is not met
#   1. Ensure the Notebook Instance has internet connectivity to fetch the example config
#   2. Ensure the Notebook Instance execution role permissions to SageMaker:StopNotebookInstance to stop the notebook 
#       and SageMaker:DescribeNotebookInstance to describe the notebook.
#

# PARAMETERS
IDLE_TIME=7200

echo "Fetching the autostop script"
wget https://raw.githubusercontent.com/DataSentics/DTL_SageMaker_AutoStop/master/autostop.py

echo "Starting the SageMaker autostop script in cron"

(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python $PWD/autostop.py --time $IDLE_TIME --ignore-connections") | crontab -

# OVERVIEW
# This script installs a single pip package in all SageMaker conda environments, apart from the JupyterSystemEnv which
# is a system environment reserved for Jupyter.
# Note this may timeout if the package installations in all environments take longer than 5 mins, consider using
# "nohup" to run this as a background process in that case.

sudo -u ec2-user -i <<'EOF'
source /home/ec2-user/anaconda3/bin/activate $(basename "python3")
pip install --upgrade -r /home/ec2-user/SageMaker/requirements.txt

source /home/ec2-user/anaconda3/bin/deactivate
EOF
