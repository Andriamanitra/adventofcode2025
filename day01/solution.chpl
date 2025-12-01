use IO;
use List;

proc readInput(input: fileReader(locking=true)): list(int) {
    var s: string;
    var rots: list(int);
    while input.read(s) {
        if s[0] == "L" {
            s = s.strip("L");
            rots.pushBack(-s:int);
        } else {
            s = s.strip("R");
            rots.pushBack(s:int);
        }
    }
    return rots;
}

proc solvePart1(rots: list(int), in dial: int = 50): int {
    var zeroCount: int = 0;
    for rot in rots {
        dial = mod(dial + rot, 100);
        if dial == 0 then zeroCount += 1;
    }
    return zeroCount;
}

proc solvePart2(rots: list(int), in dial: int = 50): int {
    var zeroCount: int = 0;
    for rot in rots {
        if dial == 0 && rot < 0 {
            dial = 100;
        }
        dial += rot;
        while dial > 100 {
            dial -= 100;
            zeroCount += 1;
        }
        while dial < 0 {
            dial += 100;
            zeroCount += 1;
        }
        if dial == 0 || dial == 100 {
            dial = 0;
            zeroCount += 1;
        }
    }
    return zeroCount;
}

proc test_part2() throws {
    use UnitTest;
    var test = new Test();
    test.assertEqual(solvePart2([-150]:list(?)), 2);
    test.assertEqual(solvePart2([-50]:list(?)), 1);
    test.assertEqual(solvePart2([50]:list(?)), 1);
    test.assertEqual(solvePart2([150]:list(?)), 2);
    test.assertEqual(solvePart2([40, 20, -20]:list(?)), 2);
    test.assertEqual(solvePart2([40, 20, -20, 10]:list(?)), 3);
    test.assertEqual(solvePart2([50, 1]:list(?)), 1);
    test.assertEqual(solvePart2([50, -1]:list(?)), 1);
    test.assertEqual(solvePart2([50, -1, 2, -1]:list(?)), 3);
}

proc main(args: [] string) {
    var reader = if args.size > 1
                 then open(args[1], ioMode.r).reader(locking=true)
                 else stdin;

    var input = readInput(reader);
    writeln("Part 1: ", solvePart1(input));
    writeln("Part 2: ", solvePart2(input));
}
