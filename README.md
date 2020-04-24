
# AWS Security Group Report

```
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ 
█       ▀█▄▀▄▀██████ ▀█▄▀▄▀██████ 
          ▀█▄█▄███▀    ▀█▄█▄███
```
----
## Infrastructure

Ran on server via crontab every Sunday at midnight and pushed to bucket for review

 > 0 0 * * 0 /opt/phishlabs/scripts/aws_sg_report.sh 2&>1 /dev/null > report.txt && aws s3 cp report.txt s3://bucket_name


##### s3 bucket policy

```json
{
    "Version": "2012-10-17",
    "Id": "Policy1512590315712",
    "Statement": [
        {
            "Sid": "Stmt1512590314407",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::bucket_name",
                "arn:aws:s3:::bucket_name/*"
            ],
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "ip_1/32",
                        "ip_2/32",
                        "ip_3/32"
                    ]
                }
            }
        }
    ]
}

```

----
## Notes
1. The script pulls all 0.0.0.0 security groups from an AWS account
2. It pulls data from every US region and generates a report for ec2, rds and elb security groups that are open to the world.
3. It is understood that you are running this from a server that has the proper EC2 and S3 roles to perform these functions

----
 ★ ❀ ヅ ❤ ♫
