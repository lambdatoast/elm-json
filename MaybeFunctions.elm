module MaybeFunctions where

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



