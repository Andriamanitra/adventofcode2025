config param test = false;

module MiniSpec {
    proc notEq(a, b) {
        if isArray(a)
        then return a.shape != b.shape || || reduce (a != b);
        else return a != b;
    }
    class Expectation {
        var name;
        var subject;
        proc to_eq(expected) throws {
            use IO;
            if this.subject.type != expected.type || notEq(this.subject, expected) {
                stderr.writef(
                    "%s \x1b[1;31mFAILED\x1b[0m\n\x1b[2m  Expected: \x1b[22m\x1b[1;32m%?\x1b[0m\n\x1b[2m   but got: \x1b[22m\x1b[1;31m%?\x1b[0m\n",
                    this.name, expected, this.subject
                );
            } else {
                stderr.writeln(this.name, " \x1b[1;32mPASSED\x1b[0m");
            }
        }
    }
    proc expect(subject, name = "Test") {
        return new Expectation(name, subject);
    }
}

proc parseGrid(input: string): [] int {
    const rows = input.split("\n", ignoreEmpty=true);
    const height = rows.size;
    const width = rows[0].size;
    const D: domain(2) = {0..<height, 0..<width};
    var grid: [D] int;
    forall (r, c) in D {
        grid[r, c] = rows[r][c:byteIndex] == '@';
    }
    return grid;
}

proc solvePart1(input: string): int {
    var grid = parseGrid(input);
    var (h, w) = grid.shape;

    proc isAccessibleRollOfPaper(r: int, c: int): bool {
        if grid[r, c] == 0 then return false;
        var rs = max(0, r-1) .. min(h-1, r+1);
        var cs = max(0, c-1) .. min(w-1, c+1);
        return 4 >= + reduce grid[rs, cs];
    }

    return + reduce [(r, c) in grid.domain] isAccessibleRollOfPaper(r, c);
}

proc solvePart2(input: string): int {
    var grid = parseGrid(input);
    var (h, w) = grid.shape;

    proc isAccessibleRollOfPaper(r: int, c: int): bool {
        if grid[r, c] == 0 then return false;
        var rs = max(0, r-1) .. min(h-1, r+1);
        var cs = max(0, c-1) .. min(w-1, c+1);
        return 4 >= + reduce grid[rs, cs];
    }

    var removedCount = 0;
    var oldCount = -1;
    while oldCount < removedCount {
        oldCount = removedCount;
        for (r, c) in grid.domain {
            if isAccessibleRollOfPaper(r, c) {
                grid[r, c] = 0;
                removedCount += 1;
            }
        }
    }
    return removedCount;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example =
            "..@@.@@@@.\n" +
            "@@@.@.@.@@\n" +
            "@@@@@.@.@@\n" +
            "@.@@@@..@.\n" +
            "@@.@@@@.@@\n" +
            ".@@@@@@@.@\n" +
            ".@.@.@.@@@\n" +
            "@.@@@.@@@@\n" +
            ".@@@@@@@@.\n" +
            "@.@.@@@.@.\n";
        expect(parseGrid("@@@\n...\n"), name="Test parseGrid").to_eq([1, 1, 1 ; 0, 0, 0]);
        expect(solvePart1(example), name="Part 1: Example").to_eq(13);
        expect(solvePart2(example), name="Part 2: Example").to_eq(43);
    } else {
        use IO;
        var reader = if args.size > 1
                     then open(args[1], ioMode.r).reader(locking=true)
                     else stdin;
        const input = reader.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
