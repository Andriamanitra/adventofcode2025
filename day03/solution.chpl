config param test = false;

module MiniSpec {
    class Expectation {
        var name;
        var subject;
        proc to_eq(expected) throws {
            use IO;
            if this.subject.type != expected.type || this.subject != expected {
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

proc maxJoltage(line: string, n: int = 2): int {
    var result = 0;
    var start = 0;

    for digitIndex in 0..<n {
        var max = "0";
        var maxIndex = 0;
        for i in start .. line.numBytes - (n - digitIndex) {
            if line[i:byteIndex] > max {
                maxIndex = i;
                max = line[i:byteIndex];
            }
        }
        start = maxIndex + 1;
        result *= 10;
        result += max:int;
    }
    return result;
}

proc solvePart1(input: string): int {
    return + reduce [line in input.split("\n", ignoreEmpty=true)] maxJoltage(line);
}

proc solvePart2(input: string): int {
    return + reduce [line in input.split("\n", ignoreEmpty=true)] maxJoltage(line, n = 12);
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "987654321111111\n811111111111119\n234234234234278\n818181911112111";
        expect(solvePart1(example), name="Part 1: Example").to_eq(357);
        expect(solvePart2(example), name="Part 2: Example").to_eq(3121910778619);
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
