# Elm JSON


Convenient and composable translation between JSON and Elm types.

The main things this library provides are: 

* Functions for creating composable and extensible JSON codecs
* Functions for delving into the parts of a JSON that you care about.

## Examples

```haskell
import JsonCodec.Decoder (..)
import JsonCodec.Process (fromString, pluggedTo, interpretedWith)

testdata1 = "{\"name\":\"Jane\",\"age\":47}"
testdata2 = "{\"msg\":\"Hello\",\"author\":{\"name\":\"Jane\",\"age\":37,\"profession\":\"Aerospace Engineering\"}}"

type Person = { name: String, age: Int, profession: String }
type Message = { msg: String, author: Person }

person : Decoder Person
person = decode3 ("name" := string) ("age" := int) ("profession" := string) Person

message : Decoder Message
message = decode2 ("msg" := string) ("author" := person) Message

print : Decoder a -> String -> Element
print decoder s = fromString s `pluggedTo` decoder |> asText

main = flow down [ print person  testdata1    
                 , print message testdata2 ]
```

This outputs these two texts:

* `Error ("Could not decode: \'profession\'")`
* `Success { author = { age = 37, name = "Jane", profession = "Aerospace Engineering" }, msg = "Hello" }`
