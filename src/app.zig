const std = @import("std");
const Scene = @import("./lib/scene.zig").Scene;
const Renderer = @import("./lib/renderer.zig").Renderer;
const objects = @import("./lib/objects.zig");
const primitives = @import("./lib/primitives.zig");
const Engine = @import("./lib/engine.zig").Engine;

const testing = std.testing;
const Vector2D = primitives.Vector2D;
const Object = primitives.Object;

pub const App = struct {
    allocator: std.mem.Allocator,
    renderer: Renderer,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        var scene = Scene.init("default", allocator);
        var renderer = Renderer{
            .scene = scene,
            .size = Vector2D{ .x = 640, .y = 400 },
            .fps = 8,
        };

        return App{
            .allocator = allocator,
            .renderer = renderer,
        };
    }

    pub fn deinit(self: *Self) void {
        self.renderer.deinit();
    }

    pub fn start(self: *Self, dryRun: bool) !void {
        var cube1 = try objects.cube("Cube.001", 150, 150, 1, self.allocator);
        try self.renderer.scene.add(&cube1);
        // cube1.rotation = .{ .x = 0, .y = 45, .z = 0 };
        // cube1.position = .{ .x = -75, .y = -75, .z = 2};

        var obj = try objects.flatFace("Face.001", 100, 100, self.allocator);
        try self.renderer.scene.add(&obj);

        obj.rotation = .{.x = 0, .y = 0, .z = 0};
        obj.position = .{.x = -150, .y = -50, .z = 2};

        var engine = try Engine.init(self.allocator, self.renderer);
        defer engine.deinit();

        var running = true;

        while (!dryRun and running) {
            var events = engine.pollEvents();
            cube1.rotation.x += 5;
            obj.rotation.y += 5;

            for (events.items) |event| {
                if (event == 768) {
                    running = false;
                }
            }

            engine.requestAnimationFrame();
        }
    }
};

test "app init" {
    var app = App.init(testing.allocator);
    defer app.deinit();

    try app.start(true);
    try testing.expectEqual(app.renderer.scene.objects.items.len, 1);
}
