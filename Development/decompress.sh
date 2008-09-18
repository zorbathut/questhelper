#!/bin/bash

# Will find all the archives in the current directory, extract the nested lua/archive files from them, and
# then delete the archives. At least, that's what it's supposed to do. No promises.

SOURCE_FOLDER=LocalInput
TEMP_FOLDER=./Temp

if [ -e "${TEMP_FOLDER}" ]; then
  rm -rf "${TEMP_FOLDER}"
fi

mkdir -p "${TEMP_FOLDER}"

function doFile {
  if [ -e ${1} ]; then
    if [ -d ${1} ]; then
      find "${1}" | while read FILE; do
        if [ "${FILE}" != "${1}" ]; then
          doFile ${FILE}
        fi
      done
      rmdir ${1}
    else
      chmod -x "${1}"
      
      HASH=`sha1sum -b "${1}" | sed -e 's/ .*//' -`
      
      if [ $? != 0 ]; then
        echo "Error calculating hash for ${DFILENAME}."
        exit 1
      fi
      
      TYPE=`file -b "${1}"`
      
      case "${TYPE}" in
        *\ text*)        mv -f "${1}" "${SOURCE_FOLDER}/${HASH}.lua" ;;
        Zip\ archive*)   mv -f "${1}" "${SOURCE_FOLDER}/${HASH}.zip" ;;
        RAR\ archive*)   mv -f "${1}" "${SOURCE_FOLDER}/${HASH}.rar" ;;
        7-zip\ archive*) mv -f "${1}" "${SOURCE_FOLDER}/${HASH}.7z" ;;
        *)              echo "Ignoring '${1}'" ; rm "${1}" ;;
      esac
    fi
  fi
}

find "${SOURCE_FOLDER}" | sort | while read FILENAME; do
  if [ "${FILENAME}" == "${SOURCE_FOLDER}" ]; then
    continue
  fi
  
  echo "Scanning ${FILENAME}..."
  
  # Can figure out text far faster, but doesn't give us the archive info. We do this first, and if it's not text, we try again in detail.
  # Why does this script even exist? Why don't we do this during download? Why don't we have an "uncompressed" staging area?
  TYPE=`file -b -e soft "${FILENAME}"`
  
  case "${TYPE}" in
      UTF-8\ Unicode\ text) continue ;;
      UTF-8\ Unicode\ English\ text) continue ;;
      UTF-8\ Unicode\ text,\ with\ CRLF\ line\ terminators) continue ;;
      UTF-8\ Unicode\ English\ text,\ with\ CRLF\ line\ terminators) continue ;;
      ASCII\ English\ text) continue ;;
      ASCII\ English\ text,\ with\ CRLF\ line\ terminators) continue ;;
  esac
  
  TYPE=`file -b "${FILENAME}"`
  
  case "${TYPE}" in
      Zip\ archive*)   unzip "${FILENAME}" -d "${TEMP_FOLDER}" ;;
      RAR\ archive*)   unrar e -o- "${FILENAME}" "${TEMP_FOLDER}/" ;;
      7-zip\ archive*) 7z e "-o${TEMP_FOLDER}" "${FILENAME}" ;;
      *) continue ;;
  esac
  
  if [ $? != 0 ]; then
    echo "${FILENAME} is not an archive."
    continue
  fi
  
  echo "Processing ${FILENAME}..."
  
  find "${TEMP_FOLDER}" | while read DFILENAME; do
    if [ "${DFILENAME}" != "${TEMP_FOLDER}" ]; then
      doFile "${DFILENAME}"
    fi
  done
  
  rm "${FILENAME}"
done

rm -rf "${TEMP_FOLDER}"

echo "Finished."
sleep 5
exit 0