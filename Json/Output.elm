module Json.Output  where

{-| Representation of output.

# Creation
@docs output

# Working with Output
@docs cata, successes, fromMaybe

-}

data Output a = Success a | Error String


{-| Create an `Output` from a pure value.
-}
output : a -> Output a
output = Success

{-| Create an error `Output` from a pure value.
-}
error : String -> Output a
error = Error

{-| Run the first given function if success, otherwise, the second given function.

      isRightAnswer : Output Int -> Bool
      isRightAnswer p = cata (\n -> n == 42) (\_ -> False) p
-}
cata : (a -> b) -> (String -> b) -> Output a -> b
cata f g pa = case pa of
                Success a  -> f a
                Error s -> g s

{-| Collect the successfully computed values.

      rightAnswers : [Output Int] -> [Int]
      rightAnswers xs = successes xs |> filter ((==) 42)
-}
successes : [Output a] -> [a]
successes xs = foldl (\a b -> cata (\s -> b ++ [s]) (\_ -> b) a) [] xs

{-| Construct an `Output` from a `Maybe`.

      isRightAnswer : Maybe Int -> Output Bool
      isRightAnswer m = fromMaybe m >>= (\n -> Success <| n == 42)
-}
fromMaybe : Maybe a -> Output a
fromMaybe ma = case ma of
                 Just a  -> Success a
                 Nothing -> Error "Nothing"

