#!/bin/bash

DB=$1

function quoteBook()
{
  WORD=$1
  BOOK_QUERY="SELECT l.usage, b.title, b.authors FROM LOOKUPS l
JOIN BOOK_INFO b ON b.id = l.book_key
WHERE l.word_key == 'en:$WORD'"
  QUOTE=$(sqlite3 -separator ' | ' $DB "$BOOK_QUERY")
  grep --color $WORD <<< $QUOTE
}

function archive()
{
  WORD=$1
  ARCHIVE_SQL="UPDATE WORDS 
      SET category=100 
      WHERE word='$WORD';"
  sqlite3 $DB "$ARCHIVE_SQL"
}

function selectWords()
{
  CATEGORY=$1
  WORDLIST_QUERY="SELECT word 
    FROM words
    WHERE category$CATEGORY
    ORDER BY timestamp DESC"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}
