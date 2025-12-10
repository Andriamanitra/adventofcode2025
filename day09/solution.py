import sys

from collections import defaultdict
from itertools import pairwise, combinations
from typing import NamedTuple


class Point(NamedTuple):
    x: int
    y: int

    @classmethod
    def parse(cls, s: str) -> Point:
        x, y = s.split(",")
        return Point(int(x), int(y))


class Size(NamedTuple):
    width: int
    height: int


class Scaler:
    def __init__(self, points: list[Point]) -> None:
        sorted_xs = sorted({p.x for p in points})
        sorted_ys = sorted({p.y for p in points})
        self._upscale_x = sorted_xs
        self._upscale_y = sorted_ys
        self._downscale_x = {x: i for i, x in enumerate(sorted_xs)}
        self._downscale_y = {y: i for i, y in enumerate(sorted_ys)}

    def downscaled_size(self) -> Size:
        return Size(width=len(self._downscale_x), height=len(self._downscale_y))

    def downscale_point(self, point: Point) -> Point:
        return Point(self._downscale_x[point.x], self._downscale_y[point.y])

    def calculate_area(self, x0: int, y0: int, x1: int, y1: int) -> int:
        if x0 > x1:
            x0, x1 = x1, x0
        if y0 > y1:
            y0, y1 = y1, y0
        dy = self._upscale_y[y1] - self._upscale_y[y0]
        dx = self._upscale_x[x1] - self._upscale_x[x0]
        return (dx + 1) * (dy + 1)


class CompactedImage(NamedTuple):
    size: Size
    corners: list[Point]
    tiles: set[Point]

    #       X ->
    #       0     1     2     3     4
    #  Y  0 +-----+-----+-----+-----+
    #  |    | 0,0 | 0,1 | 0,2 | 0,3 |
    #  V  1 +-----+-----+-----+-----+
    #       | 1,0 | 1,1 | 1,2 | 1,3 |
    #     2 +-----+-----+-----+-----+
    #       | 2,0 | 2,1 | 2,2 | 2,3 |
    #     3 +-----+-----+-----+-----+

    @staticmethod
    def from_points(points: list[Point], scaler: Scaler) -> CompactedImage:
        downscaled = [scaler.downscale_point(p) for p in points]
        path = [*downscaled, downscaled[0]]

        tiles = set()
        edge_left: set[Point] = set()

        for a, b in pairwise(path):
            if a.x == b.x:
                x = a.x
                y0, y1 = min(a.y, b.y), max(a.y, b.y)
                edge_left.update(Point(x, y) for y in range(y0, y1))

        size = scaler.downscaled_size()
        for y in range(size.height):
            inside = False
            for x in range(size.width):
                if Point(x, y) in edge_left:
                    inside = not inside
                if inside:
                    tiles.add(Point(x, y))

        return CompactedImage(size, downscaled, tiles)

    def largest_rectangle_area(self, calculate_area: Callable) -> int:
        horz = defaultdict(int)
        for y in range(self.size.height):
            acc = 0
            for x in range(self.size.width):
                if Point(x, y) in self.tiles:
                    horz[x, y] = acc
                    acc += 1
                else:
                    acc = 0
        vert = defaultdict(int)
        for x in range(self.size.width):
            acc = 0
            for y in range(self.size.height):
                if Point(x, y) in self.tiles:
                    vert[x, y] = acc
                    acc += 1
                else:
                    acc = 0

        largest = 0
        for a, b in combinations(self.corners, 2):
            area = calculate_area(*a, *b)
            if area <= largest:
                continue
            if a.x < b.x:
                x0, x1 = a.x, b.x - 1
            else:
                x0, x1 = b.x, a.x - 1
            if a.y < b.y:
                y0, y1 = a.y, b.y - 1
            else:
                y0, y1 = b.y, a.y - 1
            dx = x1 - x0
            dy = y1 - y0
            topright = Point(x1, y0)
            bottomright = Point(x1, y1)
            bottomleft = Point(x0, y1)
            if (
                horz[topright] >= dx and horz[bottomright] >= dx
                and vert[bottomright] >= dy and vert[bottomleft] >= dy
            ):
                largest = area
        return largest


if len(sys.argv) > 1:
    with open(sys.argv[1]) as f:
        lines = f.read().split()
else:
    lines = sys.stdin.read().split()

points = [Point.parse(line) for line in lines]

largest_area_part1 = max(
    (abs(a.x - b.x) + 1) * (abs(a.y - b.y) + 1)
    for a, b in combinations(points, 2)
)
print("Part 1:", largest_area_part1)

scaler = Scaler(points)
img = CompactedImage.from_points(points, scaler)
print("Part 2:", img.largest_rectangle_area(scaler.calculate_area))
