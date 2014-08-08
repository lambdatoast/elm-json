module JsonCodec.Accessor (delve, getProp) where

{-| An accesor is a `Process` that is used for moving through the Json 
structure. Accessors and decoders are both processes, so they automatically 
compose.

# Accessing JSON
@docs delve, getProp

-}

import Dict
import Json
import JsonCodec.Process (..)

type Accessor = Process Json.Value Json.Value

{-| Create an Error to communicate that a property of key `k` could 
not be accessed in the `Json.Value` `v`.
-}
accessorError : (String, Json.Value) -> Output Json.Value
accessorError (k,v) = Error <| "Could not access a '" ++ k ++ "' in '" ++ (show v) ++ "'"

type PropertyName = String

{-| Given a list of property names, traverse the `Json.Object`.

      isRightAnswer : Decoder Bool
      isRightAnswer = delve [ "x", "y", "z" ] `glue` int `glue` (Success . ((==) 42))
-}
delve : [PropertyName] -> Accessor
delve xs mv = collapsel (Success mv) (map getProp xs)

{-| Get the value of the property by the given name.
-}
getProp : PropertyName -> Accessor
getProp n json = case json of
                  Json.Object d -> case (Dict.getOrElse Json.Null n d) of
                                     Json.Null -> accessorError (n,json)
                                     v -> Success v
                  _ -> accessorError (n,json)
  
