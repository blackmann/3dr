const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;

const math = std.math;

/// this is a type alias for units to be used for calculations.
/// this is so that we can quickly switch between types just from one place
pub const scalar_type = i32;

pub const Vector2D = struct { x: scalar_type, y: scalar_type };

pub const Vector3D = struct {
    x: scalar_type = 0,
    y: scalar_type = 0,
    z: scalar_type = 0,

    const Self = @This();

    pub fn project2D(self: Self) Vector2D {
        var z = if (self.z == 0) 1 else self.z;

        return Vector2D{
            .x = @divFloor(self.x, z),
            .y = @divFloor(self.y, z),
        };
    }

    pub fn scale(self: Self, factor: i32) Vector3D {
        var x = self.x * factor;
        var y = self.y * factor;
        var z = self.z * factor;

        return Vector3D{ .x = x, .y = y, .z = z };
    }

    pub fn translate(self: Self, vector: Vector3D) Vector3D {
        var x = self.x + vector.x;
        var y = self.y + vector.y;
        var z = self.z + vector.z;

        return Vector3D{ .x = x, .y = y, .z = z };
    }

    pub fn rotate(self: Self, vector: Vector3D) Vector3D {
        var res = Vector3D{ .x = self.x, .y = self.y, .z = self.z };

        {
            // x
            var angle = @intToFloat(f64, vector.x);
            var y = @intToFloat(f64, res.y) * math.cos(angle) + @intToFloat(f64, res.z) * math.sin(angle);
            var z = @intToFloat(f64, res.y) * -math.sin(angle) + @intToFloat(f64, res.z) * math.cos(angle);

            res.y = @floatToInt(i32, y);
            res.z = @floatToInt(i32, z);
        }

        {
            // y
            var angle = @intToFloat(f64, vector.y);
            var x = @intToFloat(f64, res.x) * math.cos(angle) - @intToFloat(f64, res.z) * math.sin(angle);
            var z = @intToFloat(f64, res.x) * math.sin(angle) + @intToFloat(f64, res.z) * math.cos(angle);

            res.x = @floatToInt(i32, x);
            res.z = @floatToInt(i32, z);
        }

        {
            // z
            var angle = @intToFloat(f64, vector.z);
            var x = @intToFloat(f64, res.x) * math.cos(angle) + @intToFloat(f64, res.y) * math.sin(angle);
            var y = @intToFloat(f64, res.x) * -math.sin(angle) + @intToFloat(f64, res.y) * math.cos(angle);

            res.x = @floatToInt(i32, x);
            res.y = @floatToInt(i32, y);
        }

        return res;
    }
};

pub const Object = struct {
    name: []const u8,
    vertices: ArrayList(Vector3D),
    faces: ArrayList(ArrayList(usize)),
    position: Vector3D = .{ .x = 0, .y = 0, .z = 0 },
    scale: Vector3D = .{ .x = 1, .y = 1, .z = 1 },
    rotation: Vector3D = .{ .x = 0, .y = 0, .z = 0 },

    const Self = @This();

    pub fn deinit(self: *Self) void {
        for (self.faces.items) |*face| {
            face.deinit();
        }

        self.faces.deinit();
        self.vertices.deinit();
    }
};
