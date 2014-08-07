module JsonCodec.Process where
import Json

data Process a = Error String | Success a

cata : (a -> b) -> (String -> b) -> Process a -> b
cata f g pa = case pa of
                Success a  -> f a
                Error s -> g s

bind : (a -> Process b) -> Process a -> Process b
bind f = cata f Error

pluggedTo : Process a -> (a -> Process b) -> Process b
pluggedTo = flip bind

(>>=) : Process a -> (a -> Process b) -> Process b
(>>=) = pluggedTo

glue : (a -> Process b) -> (b -> Process c) -> (a -> Process c)
glue f g = (\a -> f a >>= g)

(>=>) : (a -> Process b) -> (b -> Process c) -> (a -> Process c)
(>=>) = glue

interpretedWith : (a -> Process b) -> (b -> c) -> (a -> Process c)
interpretedWith f g = (\a -> f a >>= (\b -> Success <| g b))

fromMaybe : Maybe a -> Process a
fromMaybe ma = case ma of
                 Just a  -> Success a
                 Nothing -> Error "Nothing"

fromString : String -> Process Json.Value
fromString s = fromMaybe (Json.fromString s)


