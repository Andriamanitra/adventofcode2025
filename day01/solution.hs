parseLine :: String -> Int
parseLine ('L':s) = -read s
parseLine ('R':s) = read s

rotate (x:xs) r
    | r < 0 = [x+r .. x] <> xs
    | r >= 0 = [x+r, x+r-1 .. x] <> xs

mod100 x = mod x 100
countZeros = length . filter (== 0) . map mod100

main = do
    rots <- map parseLine <$> lines <$> getContents
    putStrLn "Part 1:"
    print $ countZeros $ scanl (+) 50 rots
    putStrLn "Part 2:"
    print $ countZeros $ foldl rotate [50] rots
