use List;
use Sort;

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

record Rectangle {
    const x0: int;
    const y0: int;
    const x1: int;
    const y1: int;

    proc init(in x0: int, in y0: int, in x1: int, in y1: int) {
        if x0 > x1 then x0 <=> x1;
        if y0 > y1 then y0 <=> y1;
        this.x0 = x0;
        this.y0 = y0;
        this.x1 = x1;
        this.y1 = y1;
    }

    proc area(): int {
        return (this.x1 - this.x0 + 1) * (this.y1 - this.y0 + 1);
    }
}

record VSeg {
    const x: int;
    const y0: int;
    const y1: int;

    proc init(in x: int, in y0: int, in y1: int) {
        if y0 > y1 then y0 <=> y1;
        this.x = x;
        this.y0 = y0;
        this.y1 = y1;
    }

    proc intersects_rect(rect: Rectangle) {
        return rect.x0 < x && x < rect.x1 && y1 > rect.y0 && y0 < rect.y1;
    }
}

record HSeg {
    const y: int;
    const x0: int;
    const x1: int;

    proc init(in y: int, in x0: int, in x1: int) {
        if x0 > x1 then x0 <=> x1;
        this.y = y;
        this.x0 = x0;
        this.x1 = x1;
    }

    proc intersects_rect(rect: Rectangle) {
        return rect.y0 < y && y < rect.y1 && x1 > rect.x0 && x0 < rect.x1;
    }
}

iter rectangles(points: [] Pos): Rectangle {
    for i in 0 ..< points.size-1 {
        const a = points[i];
        for j in i+1 ..< points.size {
            const b = points[j];
            yield new Rectangle(a.x, a.y, b.x, b.y);
        }
    }
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

proc solvePart1(input: string): int {
    const points = readInput(input);
    return max reduce [rect in rectangles(points)] rect.area();
}

proc solvePart2(input: string): int {
    const points = readInput(input);
    var lineSegments: [points.domain] (Pos, Pos);
    lineSegments[0] = (points.last, points.first);
    forall i in 1..<points.size do
        lineSegments[i] = (points[i-1], points[i]);

    var vSegments: list(VSeg);
    var hSegments: list(HSeg);
    for (p1, p2) in lineSegments {
        if p1.x == p2.x
        then vSegments.pushBack(new VSeg(p1.x, p1.y, p2.y));
        else hSegments.pushBack(new HSeg(p1.y, p1.x, p2.x));
    }

    var largestValid = 0;
    for rect in rectangles(points) {
        var a = rect.area();
        if a > largestValid {
            if || reduce [hseg in hSegments] hseg.intersects_rect(rect) then continue;
            if || reduce [vseg in vSegments] vseg.intersects_rect(rect) then continue;
            largestValid = a;
        }
    }
    return largestValid;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "7,1\n11,1\n11,7\n9,7\n9,5\n2,5\n2,3\n7,3";
        const c_shape = "1,1\n1,10\n10,10\n10,6\n8,6\n8,4\n10,4\n10,1\n8,1";
        const adjacent_lines = "0,0\n0,1\n2,1\n2,2\n0,2\n0,3\n3,3\n3,0";
        expect(solvePart1(example), name="Part 1: Example").to_eq(50);
        expect(solvePart1(c_shape), name="Part 1: C-shape").to_eq(100);
        expect(solvePart1(adjacent_lines), name="Part 1: Adjacent lines").to_eq(16);
        expect(solvePart2(example), name="Part 2: Example").to_eq(24);
        expect(solvePart2(c_shape), name="Part 2: C-shape").to_eq(80);
        // this doesn't pass but fortunately there is no such case in real input
        expect(solvePart2(adjacent_lines), name="Part 2: Adjacent lines").to_eq(16);
    } else {
        use IO;
        const input = if args.size > 1
                      then open(args[1], ioMode.r).reader().readAll(string)
                      else stdin.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
