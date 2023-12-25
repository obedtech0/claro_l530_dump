#!/bin/bash
#
# To call this script, make sure make_f2fs is somewhere in PATH

function usage() {
cat<<EOT
Usage:
${0##*/} OUTPUT_FILE SIZE SRC_DIR
EOT
}

echo "in mkf2fsuserimg.sh PATH=$PATH"

if [ $# -lt 3 ]; then
  usage
  exit 1
fi

OUTPUT_FILE=$1
SIZE=$2
SRC_DIR=$3
shift; shift


if [ -z $SIZE ]; then
  echo "Need size of filesystem"
  exit 2
fi

shift
if [ ! -d $SRC_DIR ]; then
  echo "Can not find directory $SRC_DIR!"
  exit 2
fi

DU_SOURCE_FOLDER=$(du -sm ${SRC_DIR})
SOURCE_FOLDER_SIZE=$(echo ${DU_SOURCE_FOLDER} | cut -d " " -f 1)
SOURCE_IMAGE_SIZE=$(echo $(( ${SOURCE_FOLDER_SIZE} * 120 / 100 + 220)))
ALIGN_SOURCE_IMAGE_SIZE=$(echo $(( ${SOURCE_IMAGE_SIZE} / 4 * 4 + 4)))
NEW_SOURCE_IMAGE_SIZE=$(echo $(( ${ALIGN_SOURCE_IMAGE_SIZE} * 1024 * 1024)))
if [ ${NEW_SOURCE_IMAGE_SIZE} -lt ${SIZE} ]; then
  SIZE=${NEW_SOURCE_IMAGE_SIZE}
fi

MAKE_F2FS_CMD="make_f2fs -O encrypt -S  $SIZE $OUTPUT_FILE"
echo $MAKE_F2FS_CMD
$MAKE_F2FS_CMD
if [ $? -ne 0 ]; then
  exit 4
fi


OUTPUT_PATH=`dirname "${OUTPUT_FILE}"`
OUTPUT_FILE_NAME=`basename "${OUTPUT_FILE}"`

OUTPUT_FILE_HEADER=$OUTPUT_PATH/$OUTPUT_FILE_NAME.header
OUTPUT_FILE_MAGIC=$OUTPUT_PATH/$OUTPUT_FILE_NAME.magic

OUTPUT_UNSPARSE_FILE=$OUTPUT_PATH/$OUTPUT_FILE_NAME.unsparse

bin=`which "$0"`
bin=`dirname "${bin}"`

dd if=$OUTPUT_FILE of=$OUTPUT_FILE_HEADER bs=1 skip=0 count=4  >/dev/null 2>&1
echo -e -n "\x3a\xff\x26\xed" > $OUTPUT_FILE_MAGIC

cmp -s $OUTPUT_FILE_HEADER $OUTPUT_FILE_MAGIC
if [ $? -eq 0 ] ; then
	echo "[mkf2fsuserimg] $bin $OUTPUT_FILE"
	$bin/simg2img $OUTPUT_FILE $OUTPUT_UNSPARSE_FILE
	$bin/sload.f2fs -f  $SRC_DIR $OUTPUT_UNSPARSE_FILE
	$bin/img2simg $OUTPUT_UNSPARSE_FILE $OUTPUT_FILE
	rm -rf $OUTPUT_UNSPARSE_FILE
else
	$bin/sload.f2fs -f  $SRC_DIR $OUTPUT_FILE
fi
rm -rf $OUTPUT_FILE_HEADER $OUTPUT_FILE_MAGIC
