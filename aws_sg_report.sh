#!/bin/bash

#************************************************#
#              aws_sg_report.sh                  #
#          written by James Permenter            #
#              jmp@linuxmail.org                 #
#                May 06, 2019                    #
#                                                #
#           Generate report of open SG.          #
#************************************************#

title()
{
cat << "EOF"
#################################################################
#      ___      _____   ___  ___   ___                   _      #
#     /_\ \    / / __| / __|/ __| | _ \___ _ __  ___ _ _| |_    #
#    / _ \ \/\/ /\__ \ \__ \ (_ | |   / -_) '_ \/ _ \ '_|  _|   #
#   /_/ \_\_/\_/ |___/ |___/\___| |_|_\___| .__/\___/_|  \__|   #
# 				          |_|                   #
#################################################################
EOF
echo $(date)
}



ec2_title()
{
cat << "EOF"

 ______ _____ ___
|  ____/ ____|__ \
| |__ | |       ) |
|  __|| |      / /
| |___| |____ / /_
|______\_____|____|

###################

EOF
}

rds_title()
{
cat << "EOF"

 _____  _____   _____
|  __ \|  __ \ / ____|
| |__) | |  | | (___
|  _  /| |  | |\___ \
| | \ \| |__| |____) |
|_|  \_\_____/|_____/


######################

EOF
}

elb_title()
{
  cat << "EOF"

 ______ _      ____
|  ____| |    |  _ \
| |__  | |    | |_) |
|  __| | |    |  _ <
| |____| |____| |_) |
|______|______|____/


###################

EOF
}


ec2_open()
{
   for j in us-east-1 us-east-2 us-west-1 us-west-2; do echo $j;
       	for i in $(aws ec2 describe-security-groups --filters Name=ip-permission.from-port,Values=* Name=ip-permission.to-port,Values=* Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName}"  --region=$j | awk -F ':' '{print $2}' | tr -d '"'); do aws ec2 describe-instances --filters "Name=instance.group-name,Values=$i" --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table  --region=$j; echo "$i"; echo ""; done
done
}

rds_open()
{
    for j in us-east-1 us-east-2 us-west-1 us-west-2; do echo $j;
        for i in $(aws rds describe-db-instances  --region=$j | grep VpcSecurityGroupId | awk -F ':' '{print $2}' | tr -d '"' | sed 's/,$//'); do aws ec2 describe-security-groups --group-id $i --filters Name=ip-permission.from-port,Values=* Name=ip-permission.to-port,Values=* Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName}"  --region=$j | awk '{if (/\[\]/ && !seen) {seen = 1} else print }' | awk -F ':' '{print $2}' | tr -d '"'; done
done
}

elb_open()
{    for j in us-east-1 us-east-2 us-west-1 us-west-2; do echo $j;
        for i in $(aws elb describe-load-balancers  --region=$j | grep -i sg- | tr -d '"'); do aws ec2 describe-security-groups --group-id $i --filters Name=ip-permission.from-port,Values=* Name=ip-permission.to-port,Values=* Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName}"  --region=$j | awk '{if (/\[\]/ && !seen) {seen = 1} else print }' | awk -F ':' '{print $2}' | tr -d '"'; done
done
    for j in us-east-1 us-east-2 us-west-1 us-west-2; do echo $j;
       for i in $(aws elbv2 describe-load-balancers  --region=$j | grep -i sg- | tr -d '"' | sed 's/,$//'); do aws ec2 describe-security-groups --group-id $i --filters Name=ip-permission.from-port,Values=* Name=ip-permission.to-port,Values=* Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName}"  --region=$j | awk '{if (/\[\]/ && !seen) {seen = 1} else print }' | awk -F ':' '{print $2}' | tr -d '"'; done
done
}

main()
{
    title
    ec2_title
    ec2_open
    rds_title
    rds_open
    elb_title
    elb_open
    exit
}

main
