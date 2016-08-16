#! /bin/bash
set -eu

help=$(cat <<EOS
Script to build word embeddings with word2vec
used by japanese wikipedia dump data.

Usage: ./build-embedding-jawiki.sh

All options should be specified via enviroment variables:
 OUTPUT_DIR:       output directtory
 JAWIKI_URL:       url to download japanese wikipedia dump data
 JAWIKI_FILENAME:  local filename for japanese wikipedia dump data
 WP2TXT_OPTIONS:   options passed to wp2txt
 MECAB_REPROCESS:  switch to reprocess mecab(tokenization)  (1: yes, 0: no)
 MECAB_OPTIONS:    options passed to mecab
 WORD2VEC_OPTIONS: options passed to word2vec

This script generates three files below in OUTPUT_DIR:
  vector_jawiki.bin:  vector representations for each word in binary format
  vector_jawiki.txt:  vector representations for each word in text format
  vector_jawiki.meta: the file contains options used in word2vec and mecab
  vector_jawiki.tgz:  the tarball containing above three files
EOS
)

if [ $# -gt 0 ]; then
  echo "${help}"
  exit 1
fi

cd ${OUTPUT_DIR}

echo "Downloading japanese wikipedia dump data from ${JAWIKI_URL} to ${OUTPUT_DIR}${JAWIKI_FILENAME}."
if [ ! -e ${JAWIKI_FILENAME} ]; then
  curl -SL -o ${JAWIKI_FILENAME} ${JAWIKI_URL}
else
  echo "${OUTPUT_DIR}${JAWIKI_FILENAME} has already been downloaded.  Skipped."
fi

echo ""
echo "Converting wikipedia dump data to plain txt."
if [ ! -e jawiki.txt ]; then
  wp2txt -i ${JAWIKI_FILENAME} ${WP2TXT_OPTIONS}
  cat *.xml-* > jawiki.txt
  rm *.xml-*
else
  echo "jawiki.txt already exits.  Skipped."
fi

echo ""
echo "Tokeninzing(wakatigaki) wikipedia dump data with mecab and mecab-ipadic-NEologd."
if [ $MECAB_REPROCESS -eq 1 ]; then
  if [ -e jawikisep.txt ]; then
    echo "jawikisep.txt already exists. Backup(jawikisep.txt.old) is taken."
    mv jawikisep.txt jawikisep.txt.old
  fi
  echo "Reprocessing tokinization because MECAB_REPROCESS is on."
  mecab -Owakati \
    ${MECAB_OPTIONS} \
    jawiki.txt > jawikisep.txt
else
  if [ -e jawikisep.txt ]; then
    echo "jawikisep.txt already exists.  Skipped."
  else
    mecab -Owakati \
      ${MECAB_OPTIONS} \
      jawiki.txt > jawikisep.txt
  fi
fi

echo ""
echo "Start building vector representations with word2vec for jawikisep.txt"
word2vec -train jawikisep.txt \
  -output vector_jawiki.bin \
  -binary 1 \
  ${WORD2VEC_OPTIONS}
convertvec bin2txt \
  vector_jawiki.bin vector_jawiki.txt
echo "word2vec options: ${WORD2VEC_OPTIONS}" > vector_jawiki.meta
echo "mecab options: ${MECAB_OPTIONS}" >> vector_jawiki.meta

echo ""
echo "Archiving word2vec outputs."
tar zcvf vector_jawiki.tgz vector_jawiki.*

echo "Finished!!!"
cat <<EOS
Files generated:
  $(pwd)/vector_jawiki.bin:  vector representations in binary format
  $(pwd)/vector_jawiki.txt:  vector representations in text format
  $(pwd)/vector_jawiki.meta: the file contains options used in word2vec and mecab
  $(pwd)/vector_jawiki.tgz:  the tarball containing above three files
EOS
