module JsonCodec.Process where
import Json

{-| A Process represents what's going on with a codec.

# Type and Constructors
@docs Process

# Working with Processes
@docs cata

-}

data Process a = Success a | Error String

{-| Run the first given function if success, otherwise, the second given function.

      isRightAnswer : Process Int -> Bool
      isRightAnswer p = cata (\n -> n == 42) (\_ -> False) p
-}
cata : (a -> b) -> (String -> b) -> Process a -> b
cata f g pa = case pa of
                Success a  -> f a
                Error s -> g s

{-| Run the first given function if success, otherwise, the second given function.

      isRightAnswer : Process Int -> Bool
      isRightAnswer p = cata (\n -> n == 42) (\_ -> False) p
-}
from : (a -> Process b) -> Process a -> Process b
from f = cata f Error

into : Process a -> (a -> Process b) -> Process b
into = flip from

(>>=) : Process a -> (a -> Process b) -> Process b
(>>=) = into

glue : (a -> Process b) -> (b -> Process c) -> (a -> Process c)
glue f g = (\a -> f a >>= g)

(>=>) : (a -> Process b) -> (b -> Process c) -> (a -> Process c)
(>=>) = glue

interpretedWith : (a -> Process b) -> (b -> c) -> (a -> Process c)
interpretedWith f g = (\a -> f a >>= (\b -> Success <| g b))

successes : [Process a] -> [a]
successes xs = foldl (\a b -> cata (\s -> b ++ [s]) (\_ -> b) a) [] xs

fromMaybe : Maybe a -> Process a
fromMaybe ma = case ma of
                 Just a  -> Success a
                 Nothing -> Error "Nothing"

fromString : String -> Process Json.Value
fromString s = fromMaybe (Json.fromString s)


