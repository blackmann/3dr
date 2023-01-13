const std = @import("std");
const App = @import("./app.zig").App;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();
    var app = App.init(allocator);
    try app.start(false);
}
