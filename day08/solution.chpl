use Map;
use Heap;
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
    var z: int;

    proc dist(other: Pos): real(64) {
        const dx = this.x - other.x;
        const dy = this.y - other.y;
        const dz = this.z - other.z;
        return sqrt(dx*dx + dy*dy + dz*dz);
    }
}

record UnionFind {
    const size: int;
    var roots: [0..<size] int = 0..<size;

    proc ref rootOf(in i: int): int {
        while this.roots[i] != i do
            i = this.roots[i];
        return i;
    }

    proc ref unite(i: int, j: int): bool {
        const ri = rootOf(i);
        const rj = rootOf(j);
        if ri == rj {
            return false;
        }
        this.roots[rj] = ri;
        this.roots[i] = ri;
        this.roots[j] = ri;
        return true;
    }

    proc ref groupSizes() {
        var sizes: map(int, int);
        for i in this.roots do
            sizes[this.rootOf(i)] += 1;
        return sizes.values();
    }
}

proc readInput(input: string): [] Pos {
    const lines = input.split("\n", ignoreEmpty=true);
    const n = lines.size;
    const D: domain(1) = {0..<n};
    var points: [D] Pos;
    forall idx in D {
        var line = lines[idx].split(",");
        points[idx] = new Pos(line[0]:int, line[1]:int, line[2]:int);
    }
    return points;
}

proc createDistanceHeap(positions: [] Pos) {
    const n = positions.size;
    const nDistances: int = n * (n - 1) / 2;
    var distances: [{0..<nDistances}] (real(64), int, int);

    forall i in 0 .. n-2 {
        const i0 = i * n - (i + 1) * i / 2 - i - 1;
        for j in i+1 .. n-1 {
            const d = positions[i].dist(positions[j]);
            distances[i0+j] = (-d, i, j);
        }
    }

    return createHeap(distances);
}

proc solvePart1(input: string, nConnections: int = 1000): int {
    const positions = readInput(input);
    var uf = new UnionFind(positions.size);
    var distHeap = createDistanceHeap(positions);
    for _c in 1..nConnections {
        const (_, i, j) = distHeap.pop();
        uf.unite(i, j);
    }

    var groupSizes = uf.groupSizes();
    sort(groupSizes);

    return * reduce groupSizes[groupSizes.size - 3 ..];
}

proc solvePart2(input: string): int {
    const positions = readInput(input);
    var uf = new UnionFind(positions.size);
    var distHeap = createDistanceHeap(positions);
    var result: int;
    var nConnected = 1;
    while nConnected < positions.size {
        const (_, i, j) = distHeap.pop();
        if uf.unite(i, j) {
            nConnected += 1;
            result = positions[i].x * positions[j].x;
        }
    }
    return result;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "162,817,812\n57,618,57\n906,360,560\n592,479,940\n352,342,300\n466,668,158\n542,29,236\n431,825,988\n739,650,466\n52,470,668\n216,146,977\n819,987,18\n117,168,530\n805,96,715\n346,949,466\n970,615,88\n941,993,340\n862,61,35\n984,92,344\n425,690,689";
        expect(solvePart1(example, 10), name="Part 1: Example").to_eq(40);
        expect(solvePart2(example), name="Part 2: Example").to_eq(25272);
    } else {
        use IO;
        const input = if args.size > 1
                      then open(args[1], ioMode.r).reader().readAll(string)
                      else stdin.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
