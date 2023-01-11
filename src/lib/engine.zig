const std = @import("std");
const Renderer = @import("./renderer.zig").Renderer;

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const EngineError = error{
    InitializeError,
    WindowCreateError,
    RendererCreateError,
    TextureCreateError,
};

pub const Engine = struct {
    renderer: Renderer,
    /// Only means it can keep rendering. Call `.start` to actually start rendering
    running: bool,

    // engine internals
    sdl_window: *c.SDL_Window,
    sdl_renderer: *c.SDL_Renderer,
    sdl_texture: *c.SDL_Texture,
    last_render_time: i32 = 0,

    const Self = @This();

    pub fn init(renderer: Renderer) !Self {
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

        const sdl_texture = c.SDL_CreateTexture(
            sdl_renderer,
            c.SDL_PIXELFORMAT_ABGR8888,
            renderer.x,
            renderer.y,
        ) orelse {
            return EngineError.TextureCreateError;
        };

        return Renderer{
            .renderer = renderer,
            .running = true,
            .sdl_window = window,
            .sdl_renderer = sdl_renderer,
            .sdl_texture = sdl_texture,
        };
    }

    pub fn deinit(self: *Self) void {
        c.SDL_DestroyTexture(self.sdl_texture);
        c.SDL_DestroyRenderer(self.sdl_renderer);
        c.SDL_DestroyWindow(self.sdl_window);
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
        var render_interval = 1000 / self.renderer.fps;
        var target_render_time = self.last_render_time + render_interval;

        if (time_elapsed < target_render_time) {
            c.SDL_Delay(target_render_time - time_elapsed);
        }

        self.processInput();
        self.renderer.render();

        self.last_render_time = c.SDL_GetTicks();
        self.loop();
    }

    fn processInput(_: *Self) void {}
};
