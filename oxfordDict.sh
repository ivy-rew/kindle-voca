#!/bin/bash

OXFORD_TXT="oxford.txt"

if ! [ -f "$OXFORD_TXT" ]; then
  wget -O "$OXFORD_TXT" "https://raw.githubusercontent.com/sujithps/Dictionary/master/Oxford%20English%20Dictionary.txt"
fi

function oxford()
{
  WORD=$1
  # case insensiti3ve search
  grep -i -E "^${WORD}" $OXFORD_TXT
}
