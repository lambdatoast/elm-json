import Json
import JsonCodec (..)

jsonex1 : String
jsonex1 = "{\"name\":\"Jane\",\"msg\":\"Hello\"}"

-- User land

ex1 : String -> Element
ex1 s = 
  (Json.fromString s)     >>= 
  -- (delve [ "x", "hash" ]) >>=
  -- decodeStr               |>
  -- getOrElse ""            |> 
  (delve [ "x", "inputs" ]) >>=
  decodeList (delve [ "prev_out", "addr" ] >=> decodeStr) |>
  cata justs [] |>
  asText

main = ex1 jsonex1
