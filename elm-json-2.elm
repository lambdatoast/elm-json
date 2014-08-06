import WebSocket
import Mouse
import Json
import Dict

-- User land

unconfirmed : Signal String
unconfirmed = WebSocket.connect "ws://ws.blockchain.info/inv" (constant "{\"op\":\"unconfirmed_sub\"}")

clean : String -> Element
clean t = 
  (Json.fromString t)     >>= 
  -- (delve [ "x", "hash" ]) >>=
  -- decodeStr               |>
  -- getOrElse ""            |> 
  (delve [ "x", "inputs" ]) >>=
  decodeList (delve [ "prev_out", "addr" ] >=> decodeStr) |>
  cata justs [] |>
  asText

main = lift clean unconfirmed

-- Library land

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

-- Maybe functions

cata : (a -> b) -> b -> Maybe a -> b
cata f b ma = case ma of
                Just a  -> f a
                Nothing -> b

getOrElse : a -> Maybe a -> a
getOrElse b = cata id b
                 
compute : (a -> Maybe b) -> Maybe a -> Maybe b
compute f = cata f Nothing

(>>=) : Maybe a -> (a -> Maybe b) -> Maybe b
(>>=) = flip compute

pipe : (a -> Maybe b) -> (b -> Maybe c) -> (a -> Maybe c)
pipe f g = (\a -> f a >>= g)

(>=>) : (a -> Maybe b) -> (b -> Maybe c) -> (a -> Maybe c)
(>=>) = pipe
                   
mmap : (a -> b) -> Maybe a -> Maybe b
mmap f = compute (\a -> Just (f a))

