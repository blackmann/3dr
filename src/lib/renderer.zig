const std = @import("std");
const primitives = @import("./primitives.zig");

const testing = std.testing;
const math = std.math;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Scene = @import("./scene.zig").Scene;
const Vector2D = primitives.Vector2D;
const Vector3D = primitives.Vector3D;
const Object = primitives.Object;

pub const Renderer = struct {
    scene: Scene,
    size: Vector2D,
    fps: i32,
    backgroundColor: u32 = 0xff000000,
    color: u32 = 0xff00ff00,

    const Self = @This();

    pub fn render(self: *Self, color_buffer: []u32) void {
        self.clearCanvas(color_buffer);
        self.renderScene(color_buffer);
    }

    fn clearCanvas(self: *Self, color_buffer: []u32) void {
        var x: usize = 0;
        var y: usize = 0;
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
        for (self.scene.objects.items) |obj| {
            for (obj.faces.items) |face| {
                self.drawFace(obj.*, face, color_buffer);
            }
        }
    }

    fn drawFace(self: *Self, obj: Object, face: ArrayList(usize), color_buffer: []u32) void {
        var i: usize = 0;
        var vertices = obj.vertices.items;

        while (i < face.items.len - 1) {
            var v1 = vertices[face.items[i]];
            var v2 = vertices[face.items[i + 1]];

            var v1_transformed = applyTransformation(v1, obj);
            var v2_transformed = applyTransformation(v2, obj);

            self.drawLine(v1_transformed, v2_transformed, color_buffer);

            i += 1;
        }

        self.drawLine(
            applyTransformation(vertices[face.items[i]], obj),
            applyTransformation(vertices[face.items[0]], obj),
            color_buffer,
        );
    }

    /// https://en.wikipedia.org/wiki/Digital_differential_analyzer_(graphics_algorithm)
    fn drawLine(self: *Self, v1: Vector3D, v2: Vector3D, color_buffer: []u32) void {
        var v1_projected = v1.project2D();
        var v2_projected = v2.project2D();

        var dx = v2_projected.x - v1_projected.x;
        var dy = v2_projected.y - v1_projected.y;

        var steps = math.max(math.absInt(dx) catch 1, math.absInt(dy) catch 1);
        var xi: f64 = @intToFloat(f64, dx) / @intToFloat(f64, steps);
        var yi: f64 = @intToFloat(f64, dy) / @intToFloat(f64, steps);

        var x = @intToFloat(f64, v1_projected.x);
        var y = @intToFloat(f64, v1_projected.y);
        var i: u32 = 0;

        while (i <= steps) {
            self.drawVertex(@floatToInt(i32, x), @floatToInt(i32, y), color_buffer);
            x += xi;
            y += yi;
            i += 1;
        }
    }

    fn drawVertex(self: *Self, x: i32, y: i32, color_buffer: []u32) void {
        var x_offset: i32 = @divFloor(self.size.x, 2);
        var y_offset: i32 = @divFloor(self.size.y, 2);

        var plot_x: i32 = x + x_offset;
        var plot_y: i32 = y + y_offset;

        var render_width = self.size.x;
        var render_height = self.size.y;

        if ((plot_y < 0) or (plot_y >= render_height) or (plot_x < 0) or (plot_x >= render_width)) {
            return;
        }

        var i = @intCast(usize, plot_y * render_width + plot_x);
        color_buffer[i] = self.color;
    }

    pub fn deinit(self: *Self) void {
        self.scene.deinit();
    }
};

fn applyTransformation(vector: Vector3D, obj: Object) Vector3D {
    var res = vector.rotate(obj.rotation).translate(obj.position);
    return res;
}

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
