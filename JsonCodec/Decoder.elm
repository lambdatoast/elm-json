module JsonCodec.Decoder where
import Dict
import Json
import JsonCodec.Process (..)

type JsonProcessor = Json.Value -> Process Json.Value

reducejson : [JsonProcessor] -> Process Json.Value -> Process Json.Value
reducejson xs mv = foldl (\f b -> bind f b) mv xs 

-- Accessors

delve : [String] -> Json.Value -> Process Json.Value
delve xs mv = reducejson (map getProp xs) (Success mv)

getProp : String -> Json.Value -> Process Json.Value
getProp n json = case json of
                  Json.Object d -> case (Dict.getOrElse Json.Null n d) of
                                     Json.Null -> Error <| decodeError n
                                     v -> Success v
                  _ -> Error <| decodeError n
  
-- Generic decoders

type Decoder a = Json.Value -> Process a
type NamedDec a = (String, Decoder a)

decodeError n = "Could not decode: '" ++ n ++ "'"

decode : NamedDec a -> (a -> b) -> Json.Value -> Process b
decode (x,fa) g json = getProp x json >>= fa >>= (\a -> Success (g a))

decode2 : NamedDec a -> NamedDec b -> (a -> b -> c) -> Json.Value -> Process c
decode2 (x,fa) (y,fb) g json =
  getProp x json >>= fa >>= (\a -> getProp y json >>= fb >>= (\b -> Success (g a b)))

decode3 : NamedDec a -> NamedDec b -> NamedDec c -> (a -> b -> c -> d) -> Json.Value -> Process d
decode3 (x,fa) (y,fb) (z,fc) g json =
  getProp x json >>= fa >>= (\a -> getProp y json >>= fb >>= 
                                   (\b -> getProp z json >>= fc >>= (\c -> Success (g a b c))))

-- Built-in decoders for convenience

decodeStr : Decoder String
decodeStr v = case v of
                Json.String s -> Success s
                _ -> Error <| decodeError "{string}"

decodeFloat : Decoder Float
decodeFloat v = case v of
                  Json.Number n -> Success n
                  _ -> Error <| decodeError "{float}"

decodeList : (Json.Value -> Process a) -> Json.Value -> Process [Process a]
decodeList f v = case v of
                   Json.Array xs -> Success (map f xs)
                   _ -> Error <| decodeError "{list}"

