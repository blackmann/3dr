const std = @import("std");
const primitives = @import("./primitives.zig");

const Scene = @import("./scene.zig").Scene;
const Vector2D = primitives.Vector2D;

pub const Renderer = struct {
  scene: Scene,
  size: Vector2D,
  fps: i32,

  const Self = @This();

  pub fn render(_: *Self) void {
  }

  pub fn deinit(self: *Self) void {
    self.scene.deinit();
  }
};
