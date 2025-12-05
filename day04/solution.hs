eachCons3 (x:xs) = case xs of
    (y:z:_) -> (x, y, z) : eachCons3 xs
    _ -> []

removeAccessible grid = [rowFrom rowTrio | rowTrio <- eachCons3 $ pad grid]
  where
    rowFrom (r1@(a:b:c:_), r2@(d:x:e:_), r3@(f:g:h:_)) =
      let
        removed = x == 1 && a + b + c + d + e + f + g + h < 4
        v = if removed then 0 else x
      in
        v : rowFrom (drop 1 r1, drop 1 r2, drop 1 r3)
    rowFrom _ = []

pad grid = zeros <> map padRow grid <> zeros
  where
    padRow r = [0] <> r <> [0]
    zeros = [repeat 0]

countRolls = sum . map sum

firstDup (x:y:ys) = if x == y then x else firstDup (y:ys)

main = do
  grid <- map (map (fromEnum . (== '@'))) <$> lines <$> getContents
  let paper = countRolls grid
  let paperAfter = countRolls $ removeAccessible grid
  putStr "Part 1: "
  print $ paper - paperAfter
  let paperAfter2 = countRolls $ firstDup $ iterate removeAccessible grid
  putStr "Part 2: "
  print $ paper - paperAfter2
