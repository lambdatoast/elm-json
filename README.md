# Elm JSON


Convenient and composable translation between JSON and Elm types.

The main things this library provides are: 

* Functions for creating composable and extensible JSON codecs
* Functions for delving into the parts of a JSON that you care about.

## Examples

```haskell
import JsonCodec.Decoder (..)
import JsonCodec.Process (fromString, (>>=), into)

testdata1 = "{\"name\":\"Jane\",\"age\":47}"
testdata2 = "{\"msg\":\"Hello\",\"author\":{\"name\":\"Jane\",\"age\":37,\"profession\":\"Aerospace Engineering\"}}"

type Person = { name: String, age: Int, profession: String }
type Message = { msg: String, author: Person }

decodePerson : Decoder Person
decodePerson = decode3 ("name", decodeStr) ("age", decodeFloat `into` floor) ("profession", decodeStr) Person

decodeMessage : Decoder Message
decodeMessage = decode2 ("msg", decodeStr) ("author", decodePerson) Message

print : Decoder a -> String -> Element
print decoder s = 
  fromString s >>= decoder |> asText

main = flow down [ print decodePerson  testdata1    
                 , print decodeMessage testdata2 ]
```

This outputs the following:

    Error ("Could not decode: \'profession\'")
    Success { author = { age = 37, name = "Jane", profession = "Aerospace Engineering" }, msg = "Hello" }
