const std = @import("std");
const Scene = @import("./lib/scene.zig").Scene;
const Renderer = @import("./lib/renderer.zig").Renderer;
const objects = @import("./lib/objects.zig");
const primitives = @import("./lib/primitives.zig");
const Engine = @import("./lib/engine.zig").Engine;

const testing = std.testing;
const Vector2D = primitives.Vector2D;

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
        var cube1 = try objects.cube("Cube.001", 1, 1, 1, self.allocator);
        try self.renderer.scene.add(cube1);

        var engine = try Engine.init(self.allocator, self.renderer);
        defer engine.deinit();

        var running = true;
        var frame_count: u16 = 0;

        while (!dryRun and running and frame_count < 80) {
            _ = engine.pollEvents();

            engine.requestAnimationFrame();
            frame_count += 1;
        }
    }
};

test "app init" {
    var app = App.init(testing.allocator);
    defer app.deinit();

    try app.start(true);
    try testing.expectEqual(app.renderer.scene.objects.items.len, 1);
}
