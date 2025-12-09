import sys
import turtle

if len(sys.argv) < 2:
    lines = sys.stdin.read().split()
else:
    input_file = sys.argv[1]
    with open(input_file) as f:
        lines = f.read().split()

points = [tuple(int(n) for n in line.split(",")) for line in lines]

xs = set()
ys = set()
for x, y in points:
    xs.add(x)
    ys.add(y)

def squeeze(xs: list[int]) -> dict[int, int]:
    prevx = 0
    curr = 0
    r = {}
    for x in sorted(xs):
        if x == prevx + 1:
            curr += 1
        else:
            curr += 5
        r[x] = curr
    return r

xm = squeeze(xs)
ym = squeeze(ys)

x0 = min(xm.values()) - 20
x1 = max(xm.values()) + 20
y0 = min(ym.values()) - 20
y1 = max(ym.values()) + 20
x, y = points[0]
turtle.setup(width=500, height=500, startx=-768, starty=None)
turtle.setworldcoordinates(x0, y0, x1, y1)
turtle.penup()
turtle.goto(xm[x], ym[y])
turtle.pendown()

points.append(points[0])
for x, y in points:
    turtle.goto(xm[x], ym[y])

turtle.mainloop()
