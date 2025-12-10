import argparse
import pathlib
import sys

from collections import defaultdict
from itertools import pairwise
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
    def __init__(self, points: list[Point]):
        sorted_xs = sorted(set(p.x for p in points))
        sorted_ys = sorted(set(p.y for p in points))
        self._upscale_x   = sorted_xs
        self._upscale_y   = sorted_ys
        self._downscale_x = {x: i for i, x in enumerate(sorted_xs)}
        self._downscale_y = {y: i for i, y in enumerate(sorted_ys)}

    def downscaled_size(self) -> Size:
        return Size(width=len(self._downscale_x), height=len(self._downscale_y))

    def downscale_x(self, x: int) -> int:
        return self._downscale_x[x]

    def downscale_y(self, y: int) -> int:
        return self._downscale_y[y]

    def upscale_x(self, x: int) -> int:
        return self._upscale_x[x]

    def upscale_y(self, y: int) -> int:
        return self._upscale_y[y]

    def downscale_point(self, point: Point) -> Point:
        return Point(self._downscale_x[point.x], self._downscale_y[point.y])

    def upscale_point(self, point: Point) -> Point:
        return Point(self._upscale_x[point.x], self._upscale_y[point.y])


class CompactedImage(NamedTuple):
    size: tuple[int, int]
    corners: set[Point]
    tiles: set[Point]
    colored_tiles: set[Point]

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
    def from_points(points: list[Point]) -> CompactedImage:
        scaler = Scaler(points)
        downscaled = [scaler.downscale_point(p) for p in points]
        corners = set(downscaled)
        path = downscaled + [downscaled[0]]

        tiles = set()
        edge_left = set()

        for a, b in pairwise(path):
            if a.x == b.x:
                x = a.x
                y0, y1 = min(a.y, b.y), max(a.y, b.y)
                for y in range(y0, y1):
                    edge_left.add(Point(x, y))

        size = scaler.downscaled_size()
        for y in range(size.height):
            inside = False
            for x in range(size.width):
                if Point(x, y) in edge_left:
                    inside = not inside
                if inside:
                    tiles.add(Point(x, y))

        return CompactedImage(size, corners, tiles, set()), scaler

    def largest_rectangle(self, points: list[Point], calculate_area):
        points = set(points)
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
        best = None
        for y in range(self.size.height):
            for x in range(self.size.width):
                p = Point(x, y)
                if p not in self.tiles:
                    continue
                dx_max = horz[p]
                p0 = Point(x - dx_max, y - vert[p])
                p1 = Point(x+1, y+1)
                if calculate_area(p0, p1) < largest:
                    continue
                y0 = p0.y
                for x0 in range(x, x - dx_max - 1, -1):
                    y0 = max(y0, y - vert[x0, y])
                    p0 = Point(x0, y0)
                    if (
                        p0 in self.corners and p1 in self.corners
                        or
                        Point(p0.x, p1.y) in self.corners and Point(p1.x, p0.y) in self.corners
                    ):
                        a = calculate_area(p0, p1)
                        if a > largest:
                            best = p0, p1
                            largest = a
        (x0, y0), (x1, y1) = best
        for x in range(x0, x1):
            for y in range(y0, y1):
                self.colored_tiles.add(Point(x, y))

        return largest

    def draw_ppm(self, outputfile):
        xsize, ysize = self.size
        with outputfile as f:
            f.write(b"P6\n")
            f.write(f"{ysize} {xsize}\n".encode("utf-8"))
            f.write(b"255\n")
            for y in range(ysize):
                for x in range(xsize):
                    p = Point(x, y)
                    if p in self.colored_tiles:
                        px = (255, 0, 0)
                    elif p in self.tiles:
                        px = (100, 200, 100)
                    else:
                        px = (100, 100, 100)
                    f.write(bytes(px))


parser = argparse.ArgumentParser()
parser.add_argument("inputfile", nargs="?", type=argparse.FileType("r"), default=sys.stdin)
parser.add_argument("--draw-ppm", type=argparse.FileType("wb"), metavar="FNAME")
opts = parser.parse_args(sys.argv[1:])

lines = opts.inputfile.read().split()

points = [Point.parse(line) for line in lines]

largest_area_part1 = max(
    (abs(p0.x - p1.x) + 1) * (abs(p0.y - p1.y) + 1)
    for p0 in points
    for p1 in points
)
print("Part 1:", largest_area_part1)

pointset = set(points)
img, scaler = CompactedImage.from_points(points)

# calculate area from downscaled coords
def calculate_area(p0: Point, p1: Point) -> int:
    p_NW = scaler.upscale_point(p0)
    p_SE = scaler.upscale_point(p1)
    return (p_SE.x - p_NW.x + 1) * (p_SE.y - p_NW.y + 1)

largest_area = img.largest_rectangle(points, calculate_area)
print("Part 2:", largest_area)
if opts.draw_ppm is not None:
    img.draw_ppm(opts.draw_ppm)
