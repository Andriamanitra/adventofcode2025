use List;

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

const ShapeDomain = {0..2, 0..2};
record Shape {
    const area: int;
    const image: [ShapeDomain] bool;

    proc init(s: string) {
        var image: [ShapeDomain] bool;
        var area = 0;
        for (line, i) in zip(s.split("\n"), 0..) {
            for (ch, j) in zip(line, 0..) {
                var isFilled = ch == '#';
                image[i, j] = isFilled;
                area += isFilled;
            }
        }
        this.area = area;
        this.image = image;
    }
}

record Region {
    const width: int;
    const height: int;
    const shapeCounts: [0..5] int;

    proc init(line: string) {
        const (w_x_h, _, rest) = line.partition(": ");
        const (w, _, h) = w_x_h.partition("x");
        const nums = rest.split();
        this.width = w:int;
        this.height = h:int;
        this.shapeCounts = [i in 0..5] nums[i]:int;
    }

    proc area(): int {
        return this.width * this.height;
    }
}

class PuzzleInput {
    const shapes: [0..5] Shape;
    const regions: list(Region);
}

proc readInput(input: string): PuzzleInput {
    const parts = input.split("\n\n");
    const shapes = [i in 0..5] new Shape(parts[i][3..]);
    var regions: list(Region);
    for line in parts.last.split("\n", ignoreEmpty=true) {
        const region = new Region(line);
        regions.pushBack(region);
    }
    return new PuzzleInput(shapes, regions);
}

proc solvePart1(input: string): int {
    const puzzle = readInput(input);
    var solvableCount = 0;
    for r in puzzle.regions {
        const requiredArea = + reduce [(n, shape) in zip(r.shapeCounts, puzzle.shapes)] n * shape.area;
        // let's assume we need 20% extra space for the gaps
        if r.area() > requiredArea * 1.20 then solvableCount += 1;
    }
    return solvableCount;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "0:\n###\n##.\n##.\n\n1:\n###\n##.\n.##\n\n2:\n.##\n###\n##.\n\n3:\n##.\n###\n##.\n\n4:\n###\n#..\n###\n\n5:\n###\n.#.\n###\n\n4x4: 0 0 0 0 2 0\n12x5: 1 0 1 0 2 2\n12x5: 1 0 1 0 3 2";
        expect(solvePart1(example), name="Part 1: Example").to_eq(2);
    } else {
        use IO;
        const input = if args.size > 1
                      then open(args[1], ioMode.r).reader().readAll(string)
                      else stdin.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
    }
}
