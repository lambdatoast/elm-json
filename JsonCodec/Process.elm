module JsonCodec.Process where

{-| A Process represents what's going on with a codec.

# Type and Constructors
@docs Process

# Working with Output
@docs cata, successes, fromMaybe

# Composing Processes
@docs from, into, (>>=), glue, (>>>), interpretedWith

-}

import Json

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

{-| Get an `Output b` from passing an `Output a` through a `Process a b`.

      isRightAnswer : Output Int -> Output Bool
      isRightAnswer o = (\n -> Success <| n == 42) `from` o
-}
from : Process a b -> Output a -> Output b
from f = cata f Error

{-| Same as `from`, but with the arguments interchanged.

      isRightAnswer : Output Int -> Output Bool
      isRightAnswer o = o `into` (\n -> Success <| n == 42)
-}
into : Output a -> Process a b -> Output b
into = flip from

{-| Alias for `into`.

      isRightAnswer : Output Int -> Output Bool
      isRightAnswer o = o >>= (\n -> Success <| n == 42)
-}
(>>=) : Output a -> Process a b -> Output b
(>>=) = into

{-| Compose two Processes.

      isRightAnswer : Process [a] Bool
      isRightAnswer = (\xs -> Success <| length xs) `glue` (\n -> Success <| n == 42)
-}
glue : Process a b -> Process b c -> Process a c
glue f g = (\a -> f a >>= g)

{-| Alias for `glue`.

      isRightAnswer : Process [a] Bool
      isRightAnswer = (\xs -> Success <| length xs) >>> (\n -> Success <| n == 42)
-}
(>>>) : Process a b -> Process b c -> Process a c
(>>>) = glue

{-| Adds a pure transformation to the output of a Process.

      isRightAnswer : Process Int Bool
      isRightAnswer = (\n -> Success n) `interpretedWith` ((==) 42)
-}
interpretedWith : Process a b -> (b -> c) -> Process a c
interpretedWith f g = (\a -> f a >>= (\b -> Success <| g b))

{-| Collect the successfully computed values.

      rightAnswers : [Output Int] -> [Int]
      rightAnswers xs = successes xs |> filter ((==) 42)
-}
successes : [Output a] -> [a]
successes xs = foldl (\a b -> cata (\s -> b ++ [s]) (\_ -> b) a) [] xs

{-| Collapse a list of endo-Processes, from the left.

      isRightAnswer : Output Bool
      isRightAnswer = let o = collapsel (Success 0) [ (\_ -> Success 21)
                                                    , (\n -> Success <| n + 21)]
                      in o `into` (\n -> Success <| n == 42)
-}
collapsel : Output a -> [Process a a] -> Output a
collapsel ob xs = foldl (\p o -> o >>= p) ob xs 

{-| Construct an `Output` from a `Maybe`.

      isRightAnswer : Maybe Int -> Output Bool
      isRightAnswer m = fromMaybe m >>= (\n -> Success <| n == 42)
-}
fromMaybe : Maybe a -> Output a
fromMaybe ma = case ma of
                 Just a  -> Success a
                 Nothing -> Error "Nothing"

