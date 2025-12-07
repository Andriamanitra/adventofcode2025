use Set;

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

proc solvePart1(input: string): int {
    const lines = input.split("\n", ignoreEmpty=true);
    const width = lines[0].size;
    var start = lines[0].find("S"):int;
    var beams: set(int);
    beams.add(start);

    var splitCount = 0;
    for line in lines[1..] {
        var newBeams: set(int);
        for beam in beams {
            if line[beam:byteIndex] == "^" {
                splitCount += 1;
                if beam > 0 then newBeams.add(beam - 1);
                if beam + 1 < width then newBeams.add(beam + 1);
            } else {
                newBeams.add(beam);
            }
        }
        beams = newBeams;
    }

    return splitCount;
}

proc solvePart2(input: string): int {
    const lines = input.split("\n", ignoreEmpty=true);
    const width = lines[0].size;
    var start = lines[0].find("S"):int;
    var D: domain(1) = {0..<width};
    var beams: [D] int;
    beams[start] = 1;

    var splitCount = 0;
    for line in lines[1..] {
        var newBeams: [D] int;
        for beam in D {
            if beams[beam] == 0 then continue;
            if line[beam:byteIndex] == "^" {
                if beam > 0 then newBeams[beam - 1] += beams[beam];
                if beam + 1 < width then newBeams[beam + 1] += beams[beam];
            } else {
                newBeams[beam] += beams[beam];
            }
        }
        beams = newBeams;
    }

    return + reduce beams;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = ".......S.......\n...............\n.......^.......\n...............\n......^.^......\n...............\n.....^.^.^.....\n...............\n....^.^...^....\n...............\n...^.^...^.^...\n...............\n..^...^.....^..\n...............\n.^.^.^.^.^...^.\n...............";
        expect(solvePart1(example), name="Part 1: Example").to_eq(21);
        expect(solvePart2(example), name="Part 2: Example").to_eq(40);
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
