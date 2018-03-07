#!/usr/local/bin/python3
# This script accepts environment name and a search pattern and finds all
# InstanceIds of each Auto Scaling Group member instance and all EBS volumes
# which are attached to each instance and prints the output to screen or writes
# it to a file.
# Script by Itai Ganot 2018
import boto3
import re
from contextlib import redirect_stdout
import time
import argparse

parser = argparse.ArgumentParser(description='Get InstanceIds and VolumeIds')
parser.add_argument('--environment')
parser.add_argument('--key', help='key to look for in asg names')
parser.add_argument('--file', action='store_true', help='save output to file in current working directory')
parser.add_argument('--region', help='specify region (us-west-2 is default)', default='us-west-2')
args = parser.parse_args()

if not args.environment or not args.key:
    print("Not enough arguments supplied!")
    exit(1)

aws_region = args.region
timestr = time.strftime("%d%m%Y_%H%M%S")
asg_search_pattern = args.key

as_client = boto3.client('autoscaling', aws_region)
ec2_client = boto3.client('ec2', aws_region)

as_response = as_client.describe_auto_scaling_groups()
ec2_response = ec2_client.describe_instances()

asg_list = []
ecinst_list = []
device_list = []
volume_list = []

for asg in as_response['AutoScalingGroups']:
    if args.environment == "ci" and args.environment in asg['AutoScalingGroupName']:
        if re.search("cinew", asg['AutoScalingGroupName']) is None and re.search(args.key, asg['AutoScalingGroupName']):
            asg_list.append(asg['AutoScalingGroupName'])
    else:
        if args.environment in asg['AutoScalingGroupName'] and re.search(args.key, asg['AutoScalingGroupName']):
            asg_list.append(asg['AutoScalingGroupName'])
file = args.environment + "_" + timestr + ".txt"

def get_instanceid_volumeid():
    for asg_name in asg_list:
        print("###############################################################################")
        print("AutoScalingGroupName: ",asg_name)
        asi_response = as_client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[
            asg_name,
        ],
        MaxRecords=20
        )
        for instance in asi_response['AutoScalingGroups'][0]['Instances']:
            eci_response = ec2_client.describe_instances(
                InstanceIds=[
                    instance['InstanceId'],
                ]
            )
            for device_name in eci_response['Reservations'][0]['Instances'][0]['BlockDeviceMappings']:
                device_list.append(device_name['DeviceName'])

            for volume in eci_response['Reservations'][0]['Instances'][0]['BlockDeviceMappings']:
                volume_list.append(volume['Ebs']['VolumeId'])

            newdict = dict(zip(device_list, volume_list))
            print('InstanceId: {0} | VolumeIds: {1}'.format(instance['InstanceId'], newdict))
    print("############################ END OF BLOCK ############################")

if args.file:
    with open(file, 'w+') as f:
        with redirect_stdout(f):
            get_instanceid_volumeid()
    print("Data saved to file {0}".format(file))
else:
    get_instanceid_volumeid()

