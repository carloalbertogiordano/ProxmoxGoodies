MODE="scsi"
VM=$1
DISKID=$2
SERIAL=$3

qm set $VM  -"$MODE"1 /dev/disk/by-id/$DISKID,serial=$SERIAL
