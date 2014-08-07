module JsonCodec.Process where
import Json

{-| A Process represents what's going on with a codec.

# Type and Constructors
@docs Process

# Working with Processes
@docs cata

-}

data Output a = Success a | Error String
type Process a b = a -> Output b

{-| Run the first given function if success, otherwise, the second given function.

      isRightAnswer : Output Int -> Bool
      isRightAnswer p = cata (\n -> n == 42) (\_ -> False) p
-}
cata : (a -> b) -> (String -> b) -> Output a -> b
cata f g pa = case pa of
                Success a  -> f a
                Error s -> g s

from : Process a b -> Output a -> Output b
from f = cata f Error

into : Output a -> Process a b -> Output b
into = flip from

(>>=) : Output a -> Process a b -> Output b
(>>=) = into

glue : Process a b -> Process b c -> Process a c
glue f g = (\a -> f a >>= g)

(>=>) : Process a b -> Process b c -> Process a c
(>=>) = glue

interpretedWith : Process a b -> (b -> c) -> Process a c
interpretedWith f g = (\a -> f a >>= (\b -> Success <| g b))

successes : [Output a] -> [a]
successes xs = foldl (\a b -> cata (\s -> b ++ [s]) (\_ -> b) a) [] xs

fromMaybe : Maybe a -> Output a
fromMaybe ma = case ma of
                 Just a  -> Success a
                 Nothing -> Error "Nothing"

fromString : String -> Output Json.Value
fromString s = fromMaybe (Json.fromString s)

