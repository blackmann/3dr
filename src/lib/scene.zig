const std = @import("std");
const testing = std.testing;
const primitives = @import("./primitives.zig");
const objects = @import("./objects.zig");

const ArrayList = std.ArrayList;
const Object = primitives.Object;

pub const Scene = struct {
  name: []const u8,
  objects: ArrayList(Object),

  const Self = @This();

  pub fn init(name: []const u8, allocator: std.mem.Allocator) Self {
    return Scene{ .name = name, .objects = ArrayList(Object).init(allocator)};
  }

  pub fn deinit(self: *Self) void {
    for (self.objects.items) |*object| {
      object.deinit();
    }

    self.objects.deinit();
  }

  pub fn add(self: *Self, obj: Object) !void {
    try self.objects.append(obj);
  }
};

test "create scene" {
  var scene = Scene.init("default", testing.allocator);
  var cube = try objects.cube("Cube.001", 1, 1, 1, testing.allocator);
  try scene.add(cube);

  defer scene.deinit();

  try testing.expectEqual(scene.name, "default");
  try testing.expectEqual(scene.objects.items.len, 1);
}
