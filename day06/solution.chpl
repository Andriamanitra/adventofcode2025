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
    const operators = lines.last.split();
    const height = lines.size - 1;
    const width = operators.size;
    const rs = 0..<height;
    const cs = 0..<width;
    const D: domain(2) = {rs, cs};
    var grid: [D] int;
    forall r in rs {
        for (c, num) in zip(0..<width, lines[r].split()) {
            grid[r, c] = num:int;
        }
    }

    proc calculateColumn(c): int {
        select operators[c] {
            when "+" do return + reduce [r in rs] grid[r, c];
            when "*" do return * reduce [r in rs] grid[r, c];
            otherwise do halt();
        }
    }

    return + reduce [c in cs] calculateColumn(c);
}

proc solvePart2(input: string): int {
    const lines = input.split("\n", ignoreEmpty=true);
    const operators = lines.last.split();
    const height = lines.size - 1;
    const width = lines[0].size;
    var c = 0;

    iter numsForOp() {
        while c < width {
            var num = 0;
            for r in 0..<height {
                const ch = lines[r][c:byteIndex];
                if ch != ' ' {
                    num *= 10;
                    num += ch:int;
                }
            }
            c += 1;
            if num == 0 then break;
            yield num;
        }
    }

    iter columnResults() {
        for op in operators {
            select op {
                when "+" do yield + reduce numsForOp();
                when "*" do yield * reduce numsForOp();
                otherwise do halt();
            }
        }
    }

    return + reduce columnResults();
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "123 328  51 64 \n 45 64  387 23 \n  6 98  215 314\n*   +   *   +  ";
        expect(solvePart1(example), name="Part 1: Example").to_eq(4277556);
        expect(solvePart2(example), name="Part 2: Example").to_eq(3263827);
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
