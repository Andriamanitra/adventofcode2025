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

proc solve(input: string, isInvalid): int {
    var total = 0;
    for id_range in input.split(",") {
        const (a, _, b) = id_range.partition("-");
        total += + reduce [id in a:int .. b:int] if isInvalid(id) then id;
    }
    return total;
}

proc solvePart1(input: string): int {
    proc isInvalid(id: int): bool {
        const s = id:string;
        const half = s.numBytes / 2;
        return s[..<half] == s[half..];
    }

    return solve(input, isInvalid);
}

proc solvePart2(input: string): int {
    proc isInvalid(id: int): bool {
        const s = id:string;
        const half = s.numBytes / 2;
        for len in 1..half {
            if s.numBytes % len == 0 && s[..<len] * (s.numBytes / len) == s {
                return true;
            }
        }
        return false;
    }

    return solve(input, isInvalid);
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
        expect(solvePart1("34-43"), name="Part 1: 34-43").to_eq(0);
        expect(solvePart1("11-22"), name="Part 1: 11-22").to_eq(33);
        expect(solvePart1(example), name="Part 1: Example").to_eq(1227775554);
        expect(solvePart2("95-115"), name="Part 2: 95-115").to_eq(210);
        expect(solvePart2(example), name="Part 2: Example").to_eq(4174379265);
    } else {
        use IO;
        var reader = if args.size > 1
                     then open(args[1], ioMode.r).reader(locking=true)
                     else stdin;
        const input = reader.read(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
