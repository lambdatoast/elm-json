module Json.Process where

{-| A Process represents a passing from some input to a special `Output`.

# Type and Constructors
@docs Process

# Composing Processes
@docs from, into, (>>=), glue, (>>>), mappedTo

-}

import Json
import Json.Output (..)

type Process a b = a -> Output b

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
      isRightAnswer = map ((==) 42) (\n -> Success n)
-}
map : (b -> c) -> Process a b -> Process a c
map f p = (\a -> p a >>= (\b -> Success (f b)))

{-| Same as `map`, but with the arguments interchanged.

      isRightAnswer : Process Int Bool
      isRightAnswer = (\n -> Success n) `mappedTo` ((==) 42)
-}
mappedTo : Process a b -> (b -> c) -> Process a c
mappedTo = flip map

{-| Collapse a list of endo-Processes, from the left.

      isRightAnswer : Output Bool
      isRightAnswer = let o = collapsel (Success 0) [ (\_ -> Success 21)
                                                    , (\n -> Success <| n + 21)]
                      in o `into` (\n -> Success <| n == 42)
-}
collapsel : Output a -> [Process a a] -> Output a
collapsel ob xs = foldl (\p o -> o >>= p) ob xs 

