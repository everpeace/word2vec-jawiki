# word2vec-jawiki
Tool to build word embeddings with word2vec from japanese wikipedia dump data.  For more correct tokenization, [mecab-ipdic-neologd](https://github.com/neologd/mecab-ipadic-neologd) dictionary is used.

# How to use
This ships docker image [everpeace/word2vec-jawiki](https://hub.docker.com/r/everpeace/word2vec-jawiki/) .  So, you can do it by hitting simply:

```
docker run -v <output_directory>:/var/jawiki everpeace/word2vec-jawiki
```

__CAUTION: This takes really long time (maybe 10~12 hours)__

This will perform:
- download japanese wikipedia dump data (xml format)
  - latest data will be downloaded in default
- convert downloaded data to plain text
- prepare tokenized plain text by mecab and mecab-ipadic-neologd
- train word embedding with word2vec
  - skip-gram model will be used in default

If all went good, you can see several files generated in your `<output_directory>`

* `vector_jawiki.bin`:  vector representations for each word in binary format
* `vector_jawiki.txt`:  vector representations for each word in text format
* `vector_jawiki.meta`: the file contains options used in word2vec and mecab
* `vector_jawiki.tgz`:  the tarball containing above three files

# How to configure
All options should be specified via environment variables:
* `OUTPUT_DIR`:       output directory
* `JAWIKI_URL`:       url to download japanese wikipedia dump data
* `JAWIKI_FILENAME`:  local filename for japanese wikipedia dump data
* `WP2TXT_OPTIONS`:   options passed to wp2txt
* `MECAB_REPROCESS`:  switch to reprocess mecab(tokenization)  (1: yes, 0: no)
* `MECAB_OPTIONS`:    options passed to mecab
* `WORD2VEC_OPTIONS`: options passed to word2vec

See [Dockerfile](Dockerfile) for default values.

# Tips
`everpeace:word2vec-jawiki` docker image contains word2vec tools.  So you can try `distance` or `worde-analyze` on your word embedding like below once you build them.

```
$ docker run -it -v <output_directory>:/var/jawiki everpeace/word2vec-jawiki word-analogy /var/jawiki/vector_jawiki.bin

$ docker run -it -v <output_directory>:/var/jawiki everpeace/word2vec-jawiki distance /var/jawiki/vector_jawiki.bin
```
