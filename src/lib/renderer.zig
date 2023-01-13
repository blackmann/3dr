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

    pub fn render(self: *Self, color_buffer: []u32) void {
        self.clearBackground(color_buffer);
        self.renderScene(color_buffer);
    }

    fn clearBackground(self: *Self, color_buffer: []u32) void {
      var x: usize = 0; var y: usize = 0;
        while (y < self.size.y) {
          while (x < self.size.x) {
            var width = @intCast(usize, self.size.x);
            color_buffer[y * width + x] = self.backgroundColor;
            x += 1;
          }
          x = 0;
          y += 1;
        }
    }

    fn renderScene(self: *Self, color_buffer: []u32) void {
      for (self.scene.objects.items) |_| {
        color_buffer[0] = 0;
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

    var cells = renderer.size.x * renderer.size.y;
    var color_buffer: []u32 = try testing.allocator.alloc(u32, @intCast(u32, cells));
    defer testing.allocator.free(color_buffer);

    renderer.render(color_buffer);

    try testing.expectEqual(color_buffer[0], renderer.backgroundColor);
    try testing.expectEqual(color_buffer[3], renderer.backgroundColor);
}
