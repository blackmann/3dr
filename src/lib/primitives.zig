const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;

/// this is a type alias for units to be used for calculations.
/// this is so that we can quickly switch between types just from one place
pub const scalar_type = i32;

pub const Vector2D = struct { x: scalar_type, y: scalar_type };

pub const Vector3D = struct { x: scalar_type, y: scalar_type, z: scalar_type };

pub const Object = struct {
    name: []const u8,
    vertices: ArrayList(Vector3D),
    faces: ArrayList(ArrayList(usize)),
    position: Vector3D = .{.x = 0, .y = 0, .z = 0},
    scale: Vector3D = .{.x = 1, .y = 1, .z = 1},
    rotation: Vector3D = .{.x = 0, .y = 0, .z = 0},

    const Self = @This();

    pub fn deinit(self: *Self) void {
        for (self.faces.items) |*face| {
            face.deinit();
        }

        self.faces.deinit();
        self.vertices.deinit();
    }
};