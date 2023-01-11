const Renderer = @import("./renderer.zig").Renderer;

pub const Engine = struct {
  renderer: Renderer,
  /// Only means it can keep rendering. Call `.start` to actually start rendering
  running: bool,

  const Self = @This();

  pub fn init(renderer: Renderer) !Self {
    // initialize all the SDL stuff here

    return Renderer{
      .renderer = renderer,
      .running = true
    };
  }

  pub fn start(self: *Self) void {
    while (self.running) {

    }
  }
};
