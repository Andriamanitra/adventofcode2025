def max_joltage(s: str, n: int = 2) -> int:
    digit_positions = [[] for _ in range(10)]
    for i, digit in enumerate(s):
        digit_positions[int(digit)].append(i)
    indices_by_priority = [i for dpos in reversed(digit_positions) for i in dpos]
    prev = -1
    result = 0
    for required_digits in reversed(range(n)):
        i = next(i for i in indices_by_priority if i > prev and i + required_digits < len(s))
        prev = i
        result *= 10
        result += int(s[i])
    return result

lines = open(0).read().split()
part1 = sum(max_joltage(line, 2) for line in lines)
part2 = sum(max_joltage(line, 12) for line in lines)
print(part1, part2)
