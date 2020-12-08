#!/bin/bash

DB=$1
KDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function installDeps()
{
  if ! [ -x "$(command -v epub2txt)" ]; then
    echo 'installing epub2txt'
    if ! [ -d "epub2txt2" ]; then
      git clone https://github.com/kevinboone/epub2txt2
    fi
    cd epub2txt2
    make
    sudo make install
    cd $KDIR
  fi
}

function quoteBook()
{
  word=$1
  book=$(bookOfWord $word)
  match=$(epub2txt --noansi --raw "$book" | grep -m 1 "$word")
  quote=$(sentence "$match" "$word")
  echo "$quote"
  bookDesc "$book"
}

function sentence()
{ # enforce newlines after punctuation: and not by epub magic!
  quote="$1"; word="$2"
  echo "$quote" | sed -e "s#\([\.|\?|\!]\) #\1\n#g" | grep "$word"
}

function bookOfWord()
{
  epubPath=$(selectBook $1)
  book=$(basename "$epubPath") 
  # copy locally or read from remote
  echo "$KDIR/sample/$book"
}

function bookDesc()
{
  book=$1
  meta=$(epub2txt -m --notext "$book")
  author=$(metaValue "$meta" "Creator: ")
  title=$(metaValue "$meta" "Title: ")
  echo "${title}, ${author}"
}

function metaValue()
{
  meta=$1; field=$2
  echo "$meta" | grep "$field" | awk 'BEGIN{FS=":"}{print $2}' | awk '{$1=$1; print}'
}

function archive()
{
  echo 'unsupported on kobo'
}

function selectBook()
{
  WORD=$1
  WORDLIST_QUERY="SELECT VolumeId 
    FROM WordList
    WHERE text='$WORD'
    LIMIT 1;"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}

function selectWords()
{
  # 'DictSuffix to limit lang'
  WORDLIST_QUERY="SELECT DISTINCT text 
    FROM WordList
    ORDER BY DateCreated DESC"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}
