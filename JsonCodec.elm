module JsonCodec where
import Json
import MaybeFunctions (compute)
import Dict

type JsonProcessor = Json.Value -> Maybe Json.Value

delve : [String] -> Json.Value -> Maybe Json.Value
delve xs mv = reducejson (map getProp xs) (Just mv)

reducejson : [JsonProcessor] -> Maybe Json.Value -> Maybe Json.Value
reducejson xs mv = foldl (\f b -> compute f b) mv xs 

getProp : String -> Json.Value -> Maybe Json.Value
getProp n json = case json of
                  Json.Object d -> case (Dict.getOrElse Json.Null n d) of
                                     Json.Null -> Nothing
                                     v -> Just v
                  _ -> Nothing

decodeStr : Json.Value -> Maybe String
decodeStr v = case v of
                Json.String s -> Just s
                _ -> Nothing

decodeList : (Json.Value -> Maybe a) -> Json.Value -> Maybe [Maybe a]
decodeList f v = case v of
                   Json.Array xs -> Just (map f xs)
                   _ -> Nothing

