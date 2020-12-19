#!/usr/bin/evn bats

setup(){
  . leoDict.sh
}

@test "leoEnglish" {
  en=$(search rigid)
  echo "en result for rigid: >>$en<<" >&2
  [[ "$en" == *"steif"* ]]
}

@test "leoFrench" {
  fr=$(search honteux fr)
  echo "fr result for rigid: >>$fr<<" >&2
  [[ "$fr" == *"schändlich"* ]]
}

@test "leoFrenchClean" {
  fr=$(cleanSearch honteux fr)
  echo "fr result for rigid: >>$fr<<" >&2
  [[ "$fr" == *"schändlich"* ]]
  [[ "$fr" != *"Fetched by"* ]]
}