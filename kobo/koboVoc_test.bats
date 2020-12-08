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
    [[ "$quote" = *"Oh my ears and whiskers,"* ]]
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