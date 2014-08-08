module JsonCodec.Accessor (delve, getVal) where

{-| An accesor is a `Process` that is used for moving through the Json 
structure. Accessors and decoders are both processes, so they automatically 
compose.

# Accessing JSON
@docs delve, getVal

-}

import Dict
import Json
import JsonCodec.Process (..)
import JsonCodec.Output (..)

{-| An accesor is an endo-`Process` that is used for moving through the Json 
structure.
Everything an accessor does occur in the context of a `Json.Value`.
-}
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
delve xs mv = collapsel (Success mv) (map getVal xs)

{-| Get the value of the property by the given name.
-}
getVal : PropertyName -> Accessor
getVal n json = case json of
                  Json.Object d -> case (Dict.getOrElse Json.Null n d) of
                                     Json.Null -> accessorError (n,json)
                                     v -> Success v
                  _ -> accessorError (n,json)
  
