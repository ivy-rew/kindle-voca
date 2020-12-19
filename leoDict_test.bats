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

@test "leoFrenchAccent" {
  fr=$(search 'mouillée' fr)
  echo "fr result: >>${fr}<<" &>2
  [[ "$fr" == *"nass"* ]]
}

@test "leoEncode" {
  fr="$(urlEncode mouillée)"
  echo "url encoded: ${fr}"
  [[ "$fr" == "mouill%C3%A9e" ]]
}
