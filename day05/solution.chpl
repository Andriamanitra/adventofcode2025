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

record rangeKeyComparator : keyComparator { }
proc rangeKeyComparator.key(r) {
    return (r.low, r.high);
}

record Database {
    var Dr: domain(1);
    var Di: domain(1);
    var ranges: [Dr] range(uint);
    var ids: [Di] uint;

    proc init(ranges: [?Dr] range(uint), ids: [?Di] uint) {
        this.Dr = Dr;
        this.Di = Di;
        this.ranges = ranges;
        this.ids = ids;
    }

    proc optimizeRanges(): Database {
        var optimized: [this.Dr] range(uint);
        var i = -1;
        var prev = 0..0:uint;
        var rangeComparator: rangeKeyComparator;
        for r in sorted(this.ranges, comparator=rangeComparator) {
            if prev.high >= r.low {
                prev = prev.low .. max(prev.high, r.high);
                optimized[i] = prev;
            } else {
                i += 1;
                optimized[i] = r;
                prev = r;
            }
        }
        return new Database(optimized[0..i], this.ids);
    }
}

proc parseRange(line: string): range(uint) {
    const (a, _, b) = line.partition("-");
    return a:uint .. b:uint;
}

proc parseDb(input: string): Database {
    const (top, _, bottom) = input.partition("\n\n");
    const ranges = [line in top.split("\n")] parseRange(line);
    const ids = [line in bottom.strip().split("\n")] line:uint;
    return new Database(ranges, ids);
}

proc solvePart1(input: string): int {
    const db = parseDb(input).optimizeRanges();

    proc bsearch(lo: int, hi: int, id: uint): bool {
        if lo > hi then return false;
        const mid = (hi + lo) / 2;
        const r = db.ranges[mid];
        if r.high < id then
            return bsearch(mid + 1, hi, id);
        if r.low > id then
            return bsearch(lo, mid - 1, id);
        return true;
    }

    return + reduce [id in db.ids] bsearch(0, db.ranges.size - 1, id);
}

proc solvePart2(input: string): int {
    const db = parseDb(input).optimizeRanges();
    return + reduce [r in db.ranges] r.size;
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "3-5\n10-14\n16-20\n12-18\n\n1\n5\n8\n11\n17\n32\n";
        const parsed = parseDb(example);
        expect(parsed.ranges, name="Parse ranges").to_eq([3..5:uint, 10..14:uint, 16..20:uint, 12..18:uint]);
        expect(parsed.ids, name="Parse ids").to_eq([1:uint, 5, 8, 11, 17, 32]);
        expect(parsed.optimizeRanges().ranges, name="Optimize ranges").to_eq([3..5:uint, 10..20:uint]);
        expect(solvePart1(example), name="Part 1: Example").to_eq(3);
        expect(solvePart2(example), name="Part 2: Example").to_eq(14);
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
