#!/usr/bin/evn bats

setup(){
  . "./koboVoc.sh" "sample/KoboReader.sqlite"
  echo "a"
}

@test "readWords" {
    words=$(selectWords)
    echo "current words: $words" >&1
    [[ " ${words[@]} " =~ "inconclusive" ]] #contains at least 'inconclusive'
}

@test "quoting" {
    quote=$(quoteBook "inconclusive")
    echo "current quote: $quote" >&1
    [[ "$quote" = *"inconclusive."* ]]
}

@test "bookMeta" {
    book=$(bookOfWord "inconclusive")
    desc=$(bookDesc "$book")
    echo "current description: '${desc}'" >&1
    [ "$desc" = "Bonhoeffer, Eric Metaxas" ]
}
