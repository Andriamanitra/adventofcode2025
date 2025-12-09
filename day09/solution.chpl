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

record Pos {
    var x: int;
    var y: int;
}

proc readInput(input: string): [] Pos {
    const lines = input.split("\n", ignoreEmpty=true);
    const n = lines.size;
    const D: domain(1) = {0..#n};
    var points: [D] Pos;
    forall idx in D {
        var (x, _, y) = lines[idx].partition(",");
        points[idx] = new Pos(x:int, y:int);
    }
    return points;
}

proc area(a: Pos, b: Pos): int {
    var dx: int = abs(a.x - b.x);
    var dy: int = abs(a.y - b.y);
    return (dx + 1) * (dy + 1);
}

proc solvePart1(input: string): int {
    const points = readInput(input);
    return max reduce [a in points] max reduce [b in points] area(a, b);
}

proc solvePart2(input: string): int {
    use List;
    const points = readInput(input);
    var lineSegments: [points.domain] (Pos, Pos);
    lineSegments[0] = (points.last, points.first);
    forall i in 1..<points.size do
        lineSegments[i] = (points[i-1], points[i]);

    // TODO: solve
    return 0;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "7,1\n11,1\n11,7\n9,7\n9,5\n2,5\n2,3\n7,3";
        expect(solvePart1(example), name="Part 1: Example").to_eq(50);
        expect(solvePart2(example), name="Part 2: Example").to_eq(24);
    } else {
        use IO;
        const input = if args.size > 1
                      then open(args[1], ioMode.r).reader().readAll(string)
                      else stdin.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
