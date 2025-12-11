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

class Graph {
    const Keys: domain(string);
    const edges: [Keys] list(string);
    const topoOrder: list(string);

    proc countPaths(from: string, to: string): int {
        var count: [this.Keys] int;
        count[from] = 1;
        for k in this.topoOrder {
            if k == to then return count[k];
            if count[k] == 0 then continue;
            for dest in this.edges[k] do count[dest] += count[k];
        }
        return count[to];
    }
}

proc readGraph(input: string) {
    const lines = input.split("\n", ignoreEmpty=true);
    var Keys: domain(string);
    var graph: [Keys] list(string);
    for line in lines {
        const (key, _, rest) = line.partition(": ");
        const dests  = rest.split(" ");
        Keys.add(key);
        for d in dests do Keys.add(d);
        graph[key] = new list(dests);
    }

    proc toposort(const g) {
        var visited: [g.domain] bool;
        var result: [1..g.size] string;
        var i = g.size;

        proc visit(k) {
            if visited[k] then return;
            for dest in g[k] do visit(dest);
            visited[k] = true;
            result[i] = k;
            i -= 1;
        }

        for k in g.domain do visit(k);
        return new list(result);
    }

    const topoOrder = toposort(graph);
    return new Graph(Keys, graph, topoOrder);
}


proc solvePart1(input: string): int {
    return readGraph(input).countPaths("you", "out");
}

proc solvePart2(input: string): int {
    const g = readGraph(input);
    return g.countPaths("svr", "dac") * g.countPaths("dac", "fft") * g.countPaths("fft", "out")
         + g.countPaths("svr", "fft") * g.countPaths("fft", "dac") * g.countPaths("dac", "out");
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example1 = "aaa: you hhh\nyou: bbb ccc\nbbb: ddd eee\nccc: ddd eee fff\nddd: ggg\neee: out\nfff: out\nggg: out\nhhh: ccc fff iii\niii: out";
        const example2 = "svr: aaa bbb\naaa: fft\nfft: ccc\nbbb: tty\ntty: ccc\nccc: ddd eee\nddd: hub\nhub: fff\neee: dac\ndac: fff\nfff: ggg hhh\nggg: out\nhhh: out";
        expect(solvePart1(example1), name="Part 1: Example").to_eq(5);
        expect(solvePart2(example2), name="Part 2: Example").to_eq(2);
    } else {
        use IO;
        const input = if args.size > 1
                      then open(args[1], ioMode.r).reader().readAll(string)
                      else stdin.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
