data Rot = L Int | R Int

parseLine :: String -> Rot
parseLine ('L':s) = L (read s)
parseLine ('R':s) = R (read s)

rotate :: Int -> Rot -> (Int, Int)
rotate dial rot =
  let
    newDial = case rot of
      L n -> if dial == 0 then 100 - n else dial - n
      R n -> dial + n
    wrap (dial, count)
      | dial < 0 = wrap (dial + 100, count + 1)
      | dial > 100 = wrap (dial - 100, count + 1)
      | dial == 0 || dial == 100 = (0, count + 1)
      | otherwise = (dial, count)
  in
    wrap (newDial, 0)

part1 :: Int -> [Rot] -> Int
part1 _ [] = 0
part1 dial (r:rs) = (if newDial == 0 then 1 else 0) + part1 newDial rs
  where (newDial, _) = rotate dial r

part2 :: Int -> [Rot] -> Int
part2 _ [] = 0
part2 dial (r:rs) = zeros + part2 newDial rs
  where (newDial, zeros) = rotate dial r

main = do
    rots <- map parseLine . lines <$> getContents
    putStrLn "Part 1:"
    print $ part1 50 rots
    putStrLn "Part 2:"
    print $ part2 50 rots
