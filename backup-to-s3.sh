#!/bin/bash

# Variables
FOLDER_TO_TAR="/home/ms/config"           # Specify the folder to tar
BUCKET_NAME="ms-docker-config"            # Specify S3 bucket name
TIMESTAMP=$(date +"%Y%m%d%H%M%S")         # Timestamp for unique naming
TAR_TEMP_PATH="/tmp/docker-config"        # Temporary path to store the tar file
TAR_FILENAME="backup_$TIMESTAMP.tar.gz"   # Name of the tar file
TAR_FILE="$TAR_TEMP_PATH/$TAR_FILENAME"   # Path to store the tar file

# Ensure the temp directory exists
mkdir -p $TAR_TEMP_PATH

# Delete files older than 1 month from TAR_TEMP_PATH
find $TAR_TEMP_PATH -type f -mtime +30 -exec rm {} \;

# Create a tarball and compress it with gzip
tar -czf $TAR_FILE -C $(dirname $FOLDER_TO_TAR) $(basename $FOLDER_TO_TAR)

# Upload the gzipped tar file to the S3 bucket under the "configs" key
aws s3 cp $TAR_FILE s3://$BUCKET_NAME/$TAR_FILENAME

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "Upload successful. Deleting the local gzipped tar file."
    # Delete the local gzipped tar file
    rm $TAR_FILE
else
    echo "Upload failed. Keeping the gzipped tar file for review."
fi
