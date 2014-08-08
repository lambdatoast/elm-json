module JsonCodec.Decoder where

{-| Tools for translating JSON to Elm types.

# Type and Constructors
@docs Decoder, fromString

-}

import Dict
import Json
import JsonCodec.Process (..)

{-| This Process is used for moving through the Json structure. Accessors 
and decoders are both processes, so they automatically compose.
-}
type Accessor = Process Json.Value Json.Value

{-| Create an Error to communicate that a property of key `k` could 
not be accessed in the `Json.Value` `v`.
-}
accessorError : (String, Json.Value) -> Output Json.Value
accessorError (k,v) = Error <| "Could not access a '" ++ k ++ "' in '" ++ (show v) ++ "'"

delve : [String] -> Accessor
delve xs mv = collapsel (Success mv) (map getProp xs)

getProp : String -> Accessor
getProp n json = case json of
                  Json.Object d -> case (Dict.getOrElse Json.Null n d) of
                                     Json.Null -> accessorError (n,json)
                                     v -> Success v
                  _ -> accessorError (n,json)
  
{-| A Decoder is a Process that takes a Json.Value and produces some 
value `a`.
-}
type Decoder a = Process Json.Value a

{-| A Decoder tagged with a property name, expected to be found in 
a Json.Value.
-}
type PropertyName = String
data NamedDec a = NDec PropertyName (Decoder a)

{-| Constructor of decoders with a name.
-}
(:=) : PropertyName -> Decoder a -> NamedDec a
(:=) k d = NDec k d

infixr 0 :=

-- Built-in decoders for convenience

string : Decoder String
string v = case v of
                Json.String s -> Success s
                _ -> Error <| decodeError "{string}"

float : Decoder Float
float v = case v of
                  Json.Number n -> Success n
                  _ -> Error <| decodeError "{float}"

int : Decoder Int
int = float `interpretedWith` floor

bool : Decoder Bool
bool v = case v of
                  Json.Boolean b -> Success b
                  _ -> Error <| decodeError "{bool}"

listOf : Decoder a -> Decoder [a]
listOf f v = case v of
                   Json.Array xs -> Success <| successes (map f xs)
                   _ -> Error <| decodeError "{list}"

{-| A Process from String to Json.Value for convenience.

      isRightAnswer : String -> Output Bool
      isRightAnswer s = fromString s >>= int >>= (\n -> Success <| n == 42)
-}
fromString : Process String Json.Value
fromString = (\s -> fromMaybe (Json.fromString s))

-- Generic decoders

decodeError n = "Could not decode: '" ++ n ++ "'"

decode : NamedDec a -> (a -> b) -> Decoder b
decode (NDec x fa) g json = getProp x json >>= fa >>= (\a -> Success (g a))

decode2 : NamedDec a -> NamedDec b -> (a -> b -> c) -> Decoder c
decode2 (NDec x fa) (NDec y fb) g json =
  getProp x json >>= fa >>= (\a -> getProp y json >>= fb >>= (\b -> Success (g a b)))

decode3 : NamedDec a -> NamedDec b -> NamedDec c -> (a -> b -> c -> d) -> Decoder d
decode3 (NDec x fa) (NDec y fb) (NDec z fc) g json =
  getProp x json >>= fa >>= (\a -> getProp y json >>= fb >>= 
                                   (\b -> getProp z json >>= fc >>= (\c -> Success (g a b c))))

