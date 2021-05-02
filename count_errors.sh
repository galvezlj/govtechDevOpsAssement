#!/bin/bash

threshold=${THRESHOLD:=100}
subject="<Alert> Too Many Errors"
from=${FROM:-"andy.galvez@gmail.com"}
to=${TO:-"andy.galvez@shopback.com"}

echo $threshold
echo $from
echo $to

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    echo "Usage: ${0} <logfilename>"
    exit
fi

# Use time stamps for easy access of the logs in the future
timeStamp=`date '+%F_%T%Z'`
fileName=${1}.${timeStamp}

if [ ! -f ${1} ]; then
    echo "${1} file not found!"
    exit
fi

# Rename to time stamped filename to freeze data and prevent further updates
mv ${1} ${fileName}

# Count using grep for simplest approach (practical approach if no breakdown is required)
errCount=`grep 'HTTP.*\" [45][0-9][0-9]' ${fileName} | wc -l`
# If breakdown on 4xx and 5xx are required, use readline loop

echo $errCount

if [ ${errCount} -gt ${threshold} ]
then
  body="${timeStamp}: There are ${errCount} errors found!"
  echo -e "Subject:${subject}\n\n${body}" | sendmail -f "${from}" -t "${to}"
fi

# Enable to compress
# tar -czvf ${fileName}.tar.gz ${fileName}
# Enable to delete after compression
# rm ${fileName}
# Enable to move compressed copy to S3
# bucket=s3://somelogbucket
# aws s3 cp ${fileName}.tar.gz ${bucket}/${fileName}.tar.gz

# Securing the proper mail account will be handled outside of this code.
# object life cycle configured for s3 bucket to enable auto deletion after 7 years