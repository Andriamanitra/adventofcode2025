import heapq
import math
import sys
from collections.abc import Generator
from typing import NamedTuple, Self


class Point(NamedTuple):
    x: int
    y: int
    z: int

    @classmethod
    def parse(cls, s: str) -> Self:
        x, y, z = s.strip().split(",")
        return cls(int(x), int(y), int(z))


class DisjointSetForest:
    def __init__(self, *, size: int) -> None:
        self.distinct_set_count = size
        self.parent = list(range(size))
        self.sizes = [1] * size

    def merge(self, i: int, j: int) -> bool:
        while self.parent[i] != i:
            i = self.parent[i]
        while self.parent[j] != j:
            j = self.parent[j]
        if i == j:
            return False
        if self.sizes[i] < self.sizes[j]:
            i, j = j, i
        self.parent[j] = i
        self.sizes[i] += self.sizes[j]
        self.distinct_set_count -= 1
        return True

    def each_set_size(self) -> Generator[int]:
        return (self.sizes[i] for i, parent in enumerate(self.parent) if i == parent)


if len(sys.argv) < 2:
    points = [Point.parse(line) for line in sys.stdin]
else:
    input_file = sys.argv[1]
    with open(input_file) as f:
        points = [Point.parse(line) for line in f]

N = len(points)
distances = []
for i, a in enumerate(points):
    for j, b in enumerate(points[i + 1 :], i + 1):
        d = math.dist(a, b)
        distances.append((d, i, j))

heapq.heapify(distances)
dsf = DisjointSetForest(size=N)
for wire_count in range(1, N * N):
    d, i, j = heapq.heappop(distances)
    dsf.merge(i, j)
    if wire_count == 1000:
        sizes = heapq.nlargest(3, dsf.each_set_size())
        print("Part 1:", math.prod(sizes))
    if dsf.distinct_set_count == 1:
        print("Part 2:", points[i].x * points[j].x)
        break
