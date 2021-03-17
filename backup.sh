#!/bin/bash

uniq_string=""

function compress_backup(){
case $BACKUP_TYPE in

  zip)
    zip "backup_$uniq_string.zip" "./backup_$uniq_string/"*
    rm -rf "./backup_$uniq_string"
    ;;
  rar)
    rar a "backup_$uniq_string.zip" "./backup_$uniq_string/"*
    rm -rf "./backup_$uniq_string"
    ;;
  *)
    echo "Unknown Compress Type"
    exit 1
esac
}

function create_backup_directory(){
 uniq_string=`tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''` 
 mkdir "backup_$uniq_string"
 return 
}

function find_files(){
create_backup_directory
find "." -name "${FILE_NAME}" -type $FILE_TYPE ! -path "./backup_*/*" -printf "%k KB %p\n" | sort -nr |  while read -r i; do
  substr=$(echo $i | cut -d' ' -f 3)
  cp $substr "./backup_$uniq_string/$(echo $substr | cut -d'/' -f 2)"
done
}

function usage(){
printf "Usage: $0 [options [-file_name \"tugce.*\" -file_type f -backup_type zip]]\n"
printf "Options:\n
-file_name, File Name
-backup_type, Compress Type
	zip -> must be installed in the system
	rar -> must be installed in the system
-file_type , File Type\n"
printf "	b -> block\n
	c -> character\n
	d -> directory\n
	f -> regular file\n
	p -> named pipe\n
	l -> symbolic link\n
	s -> socket\n"

}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -file_name|--a)
    FILE_NAME="$2"
    shift 
    shift 
    ;;
    -file_type|--b)
    FILE_TYPE="$2"
    shift
    shift 
    ;;
    -backup_type|--c)
    BACKUP_TYPE="$2"
    shift 
    shift 
    ;;
    *)  
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

if [[ -z "$FILE_NAME" || -z "$FILE_TYPE" || -z "$BACKUP_TYPE" ]]
then
	echo "One or more variables are undefined.Please check your initialization values."
	usage
	exit 1
else
	find_files
	compress_backup
fi
