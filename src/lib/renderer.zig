const std = @import("std");
const primitives = @import("./primitives.zig");

const testing = std.testing;
const Scene = @import("./scene.zig").Scene;
const Vector2D = primitives.Vector2D;

pub const Renderer = struct {
    scene: Scene,
    size: Vector2D,
    fps: i32,
    backgroundColor: u32 = 0xff000000,
    color: u32 = 0xffffffff,

    const Self = @This();

    pub fn render(self: *Self, color_buffer: [*]u32) void {
        self.clearBackground(color_buffer);
    }

    fn clearBackground(self: *Self, color_buffer: [*]u32) void {
      var x: usize = 0; var y: usize = 0;
        while (y < self.size.y) {
          while (x < self.size.x) {
            var width = @intCast(usize, self.size.y);
            color_buffer[y * width + x] = self.backgroundColor;
            x += 1;
          }
          x = 0;
          y += 1;
        }
    }

    pub fn deinit(self: *Self) void {
        self.scene.deinit();
    }
};

test "renderer" {
    var renderer = Renderer{
        .scene = Scene.init("default", testing.allocator),
        .size = Vector2D{ .x = 2, .y = 2 },
        .fps = 12,
        .backgroundColor = 0xff0000ff,
    };

    defer renderer.deinit();

    var color_buffer: [4]u32 = .{0} ** 4;
    renderer.render(&color_buffer);

    try testing.expectEqual(color_buffer[0], renderer.backgroundColor);
    try testing.expectEqual(color_buffer[3], renderer.backgroundColor);
}
