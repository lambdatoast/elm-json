# Elm Json Codec

Convenient and composable translation between JSON and Elm types.

The main things this library provides are: 

* Functions for creating composable and extensible JSON codecs
* Functions for delving into the parts of a JSON that you care about.

## Decoding example

```haskell
import JsonCodec.Decoder (..)
import JsonCodec.Process (fromString, pluggedTo)

testdata1 = "{\"name\":\"Jane\",\"age\":47}"
testdata2 = "{\"content\":\"hello world\",\"comments\":[{\"msg\":\"Hello\",\"author\":{\"name\":\"Jane\",\"age\":37,\"profession\":\"Aerospace Engineering\"}},{\"msg\":\"Hello\",\"author\":{\"name\":\"Tim\",\"age\":37,\"profession\":\"Wizard\"}}]}"
testdata3 = "[true,false]"

type Person = { name: String, age: Int, profession: String }
type Comment = { msg: String, author: Person }
type BlogPost = { content: String, comments: [Comment] }

person : Decoder Person
person = decode3 ("name" := string) ("age" := int) ("profession" := string) Person

comment : Decoder Comment
comment = decode2 ("msg" := string) ("author" := person) Comment

blogpost : Decoder BlogPost
blogpost = decode2 ("content" := string) ("comments" := listOf comment) BlogPost

print : Decoder a -> String -> Element
print decoder s = fromString s `pluggedTo` decoder |> asText

main = flow down [ print person  testdata1    
                 , print blogpost testdata2
                 , print (listOf bool) testdata3 ]
```

This outputs these messages:

* `Error ("Could not decode: \'profession\'")`
* `Success { comments = [{ author = { age = 37, name = "Tim", profession = "Wizard" }, msg = "Hello" },{ author = { age = 37, name = "Jane", profession = "Aerospace Engineering" }, msg = "Hello" }], content = "hello world" }`
* `Success [False,True]`
