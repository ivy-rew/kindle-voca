#!/usr/bin/evn bats

setup(){
  . "./koboVoc.sh" "sample/KoboReader.sqlite"
  installDeps
}

@test "readWords" {
    words=$(selectWords)
    echo "current words: $words" >&1
    [[ " ${words[@]} " =~ "whiskers" ]] #contains at least 'inconclusive'
}

@test "quoting" {
    quote=$(quoteBook "whiskers")
    echo "current quote: $quote" >&1
    [[ "$quote" = "There was not a moment to be lost: away went Alice like the wind, and was just in time to hear it say, as it turned a corner, “Oh my ears and whiskers, how late it’s getting!"* ]]
}

@test "bookMeta" {
    book=$(bookOfWord "whiskers")
    desc=$(bookDesc "$book")
    echo "current description: '${desc}'" >&1
    [ "$desc" = "Alice's Adventures in Wonderland, Lewis Carroll" ]
}

@test "bookOfWord" {
    book=$(bookOfWord "whiskers")
    echo "current book: ${book}" >&1
    [[ "$book" = *"Alice"* ]]
}