const std = @import("std");
const Renderer = @import("./renderer.zig").Renderer;
const Scene = @import("./scene.zig").Scene;
const primitives = @import("./primitives.zig");
const testing = std.testing;

const Vector2D = primitives.Vector2D;

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const EngineError = error{
    InitializeError,
    WindowCreateError,
    RendererCreateError,
    TextureCreateError,
};

pub const Delegate = struct {
    updateFn: *const fn (*Delegate) void,

    const Self = @This();
    pub fn update(self: *Self) void {
        self.updateFn(self);
    }
};

pub const Engine = struct {
    allocator: std.mem.Allocator,
    renderer: Renderer,
    delegate: *Delegate,
    /// Only means it can keep rendering. Call `.start` to actually start rendering
    running: bool,

    // engine internals
    sdl_window: *c.SDL_Window,
    sdl_renderer: *c.SDL_Renderer,
    sdl_texture: *c.SDL_Texture,
    last_render_time: u32 = 0,
    color_buffer: []u32,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, renderer: Renderer, delegate: *Delegate) !Self {
        if (c.SDL_Init(c.SDL_INIT_EVERYTHING) != 0) {
            return EngineError.InitializeError;
        }

        const window = c.SDL_CreateWindow(
            null,
            c.SDL_WINDOWPOS_CENTERED,
            c.SDL_WINDOWPOS_CENTERED,
            renderer.size.x,
            renderer.size.y,
            c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_BORDERLESS,
        ) orelse {
            return EngineError.WindowCreateError;
        };

        errdefer c.SDL_DestroyWindow(window);

        const sdl_renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
            return EngineError.RendererCreateError;
        };

        errdefer c.SDL_DestroyRenderer(sdl_renderer);

        var width = renderer.size.x; var height = renderer.size.y;

        const sdl_texture = c.SDL_CreateTexture(
            sdl_renderer,
            c.SDL_PIXELFORMAT_ABGR8888,
            c.SDL_TEXTUREACCESS_STREAMING,
            width,
            height,
        ) orelse {
            return EngineError.TextureCreateError;
        };

        var cells = @intCast(usize, width) * @intCast(usize, height);
        var color_buffer: []u32 = try allocator.alloc(u32, cells);

        return Engine{
            .allocator = allocator,
            .renderer = renderer,
            .running = true,
            .delegate = delegate,
            .sdl_window = window,
            .sdl_renderer = sdl_renderer,
            .sdl_texture = sdl_texture,
            .color_buffer = color_buffer,
        };
    }

    pub fn deinit(self: *Self) void {
        c.SDL_DestroyTexture(self.sdl_texture);
        c.SDL_DestroyRenderer(self.sdl_renderer);
        c.SDL_DestroyWindow(self.sdl_window);

        self.allocator.free(self.color_buffer);
    }

    pub fn start(self: *Self) void {
        self.loop();
    }

    pub fn stop(self: *Self) void {
        self.running = false;
    }

    fn loop(self: *Self) void {
        if (self.running) {
            self.requestAnimationFrame();
        }
    }

    fn requestAnimationFrame(self: *Self) void {
        var time_elapsed = c.SDL_GetTicks();
        var render_interval = @divFloor(1000, self.renderer.fps);
        var target_render_time: u32 = self.last_render_time + @intCast(u32, render_interval);

        if (time_elapsed < target_render_time) {
            c.SDL_Delay(target_render_time - time_elapsed);
        }

        self.prepare();
        self.renderer.render(self.color_buffer);

        self.last_render_time = c.SDL_GetTicks();

        self.loop();
    }

    fn prepare(self: *Self) void {
        self.delegate.update();
    }
};


const A = struct {
    name: u8,
    delegate: Delegate,

    fn init() A {
        return A {
            .name = 10,
            .delegate = Delegate{.updateFn = update},
        };
    }

    pub fn update(delegate: *Delegate) void {
        const self = @fieldParentPtr(A, "delegate", delegate);
        self.name = 15;
    }
};

test "engine" {
    var renderer = Renderer{
        .scene = Scene.init("default", testing.allocator),
        .size = Vector2D{.x = 100, .y = 100},
        .fps = 12,
    };

    var a = A.init();

    var engine = try Engine.init(testing.allocator, renderer, &a.delegate);
    defer engine.deinit();

    try testing.expectEqual(engine.renderer.scene.name, "default");
    engine.prepare();

    try testing.expectEqual(a.name, 15);
}
