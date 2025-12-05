#!/usr/bin/env -S uv run --with scipy
import numpy as np
from scipy.signal import convolve2d

grid = np.array([[int(c == '@') for c in line] for line in open(0).read().split()])
removed = convolve2d(grid, [[1,1,1], [1,-4,1], [1,1,1]]) < 0
print("Part 1:", removed.sum())
total_paper = grid.sum()
while removed.any():
    removed = convolve2d(grid, [[1,1,1], [1,-4,1], [1,1,1]], mode="same") < 0
    grid -= removed
print("Part 2:", total_paper - grid.sum())
