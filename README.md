# 3dr - SDL2 3D Renderer in zig ⚡️

This is an attempt to use my experience in Blender and the basics I've learned from [pikuma.com/3d-graphics-programming](https://pikuma.com/courses/learn-3d-computer-graphics-programming) to develop a 3d renderer (a very basic one) with some few interactions.

As at this moment, I'm only 25% into the course and just know how to draw lines/triangles (with perspective) and project them into a [color] buffer. Also the course is taught in C which has some code structuring that I'm uncomfortable with.

I've tried to come up with my [API] design and apply the main principles.

## Testing

When testing a module, do

```sh
zig test src/lib/engine.zig -lSDL2 -I/opt/homebrew/include -L/opt/homebrew/lib
```