use List;
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

type u16 = uint(16);

class Machine {
    const size: int;
    const lights: u16;
    const buttons: list(u16);
    const joltages: [0..#size] u16;

    proc init(line: string) {
        const parts = line.split(" ");
        var lightsStr = parts[0].strip("[]");
        var lights = + reduce [(c, i) in zip(lightsStr, 0..)]
                       if c == "#" then 1:u16 << i else 0;
        var buttons: list(u16);
        for p in parts[1..parts.size-2] {
            const button: u16 = | reduce [idx in  p.strip("()").split(",")] 1:u16 << idx:u16;
            buttons.pushBack(button);
        }
        var joltages: [0..#lightsStr.size] u16;
        for (joltage, i) in zip(parts.last.strip("{}").split(","), 0..) {
            joltages[i] = joltage:u16;
        }

        this.size = lightsStr.size;
        this.lights = lights;
        this.buttons = buttons;
        this.joltages = joltages;
    }

    proc minimumPresses(): int {
        var found = new set(u16);
        found.add(0);
        for n in 0..this.size {
            if found.contains(this.lights) then return n;
            var newFound = new set(u16);
            for x in found {
                for b in this.buttons do newFound.add(x ^ b);
            }
            found |= newFound;
        }
        return -1;
    }

    proc solve(): int {
        // TODO
        return 0;
    }
}

proc readMachines(input: string): [] owned Machine {
    return [line in input.split("\n", ignoreEmpty=true)] new Machine(line);
}

proc solvePart1(input: string): int {
    const machines = readMachines(input);
    return + reduce [m in machines] m.minimumPresses();
}

proc solvePart2(input: string): int {
    const machines = readMachines(input);
    return + reduce [m in machines] m.solve();
}

proc main(args: []string) {
    if test {
        use MiniSpec;
        const example = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}\n[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}\n[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}";
        expect(solvePart1(example), name="Part 1: Example").to_eq(7);
        expect(solvePart2(example), name="Part 2: Example").to_eq(33);
    } else {
        use IO;
        const input = if args.size > 1
                      then open(args[1], ioMode.r).reader().readAll(string)
                      else stdin.readAll(string);
        writeln("Part 1:"); writeln(solvePart1(input));
        writeln("Part 2:"); writeln(solvePart2(input));
    }
}
