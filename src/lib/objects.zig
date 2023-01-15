const std = @import("std");
const primitives = @import("./primitives.zig");

const ArrayList = std.ArrayList;
const Object = primitives.Object;
const Vector3D = primitives.Vector3D;
const scalar_type = primitives.scalar_type;
const testing = std.testing;

pub fn flatFace(name: []const u8, w: i32, h: i32, allocator: std.mem.Allocator) !Object {
    var vertices = try ArrayList(Vector3D).initCapacity(allocator, 3);

    // this is a unit cube, each component will be scaled by the respective
    // w, h, d
    var raw_vertices: [3][3]scalar_type = .{
        .{ 0, 1, 0 }, // 0
        .{ 1, 1, 0 }, // 1
        .{ 1, 0, 0 }, // 2
    };

    for (raw_vertices) |vertex| {
        try vertices.append(.{ .x = vertex[0] * w, .y = vertex[1] * h, .z = vertex[2] });
    }

    const faces_count = 6 * 2; // each face has 2 triangles
    var faces = try ArrayList(ArrayList(usize)).initCapacity(allocator, faces_count);

    var face = try ArrayList(usize).initCapacity(allocator, 3);
    try face.append(0);
    try face.append(1);
    try face.append(2);

    try faces.append(face);

    var obj = Object{
        .name = name,
        .vertices = vertices,
        .faces = faces,
    };

    return obj;
}

pub fn cube(name: []const u8, w: i32, h: i32, d: i32, allocator: std.mem.Allocator) !Object {
    var vertices = try ArrayList(Vector3D).initCapacity(allocator, 8);

    // this is a unit cube, each component will be scaled by the respective
    // w, h, d
    var raw_vertices: [8][3]scalar_type = .{
        .{ 0, 0, 0 }, // 0
        .{ 0, 0, 1 }, // 1
        .{ 0, 1, 1 }, // 2
        .{ 1, 0, 0 }, // 3
        .{ 1, 1, 0 }, // 4
        .{ 1, 1, 1 }, // 5
        .{ 0, 1, 0 }, // 6
        .{ 1, 0, 1 }, // 7
    };

    for (raw_vertices) |vertex| {
        try vertices.append(.{ .x = vertex[0] * w, .y = vertex[1] * h, .z = vertex[2] * d });
    }

    const faces_count = 6 * 2; // each face has 2 triangles
    var faces = try ArrayList(ArrayList(usize)).initCapacity(allocator, faces_count);

    // vertex indices
    var raw_faces: [faces_count][3]usize = .{
        .{ 0, 1, 2 },
        .{ 0, 2, 6 },
        .{ 1, 5, 7 },
        .{ 1, 2, 5 },
        .{ 3, 4, 7 },
        .{ 4, 5, 7 },
        .{ 0, 3, 6 },
        .{ 3, 4, 6 },
        .{ 2, 4, 6 },
        .{ 2, 4, 5 },
        .{ 0, 1, 3 },
        .{ 1, 3, 7 },
    };

    for (raw_faces) |face_vertices| {
        var face = try ArrayList(usize).initCapacity(allocator, 3);
        for (face_vertices) |vertex| {
            try face.append(vertex);
        }

        try faces.append(face);
    }

    var obj = Object{
        .name = name,
        .vertices = vertices,
        .faces = faces,
    };

    return obj;
}

test "object" {
    var cube1 = try cube("Cube.001", 2, 2, 2, testing.allocator);
    cube1.position = .{ .x = 10, .y = 0, .z = 5 };
    defer cube1.deinit();

    try testing.expectEqual(cube1.name, "Cube.001");
    try testing.expectEqual(cube1.position.x, 10);
}
