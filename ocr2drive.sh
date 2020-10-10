#!/bin/bash
ocrPath="/home/martinbreu/.google-drive/toOCR"
documentsPath="/home/martinbreu/.google-drive/Dokumente"
ocrCommand="docker run --rm -v $ocrPath:$ocrPath -i jbarlow83/ocrmypdf:v11.1.1 -l eng+deu --rotate-pages-threshold 2.5 --image-dpi 300 --force-ocr --jbig2-lossy --optimize 2"

rclone move --retries 1 gdrive:/toOCR/ $ocrPath/
test "$(find $ocrPath -type f)" || exit 0

find $ocrPath -name "*.*" -exec echo "{}" \; -exec $ocrCommand --rotate-pages "{}" "{}" \;
find $ocrPath -name "*.*" -exec echo "{}" \; -exec $ocrCommand --deskew "{}" "{}.pdf" \; -exec rm "{}" \;
cp -r $ocrPath/. $documentsPath
rclone move --retries 1 $ocrPath/Maddie/ gdriveMaddie:/Dokumente/
rclone move --retries 1 $ocrPath/ gdrive:/Dokumente/
