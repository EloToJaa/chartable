const std = @import("std");

pub fn stringifyObject(allocator: std.mem.Allocator, object: anytype) ![]const u8 {
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();
    try std.json.stringify(object, .{}, string.writer());

    const stringified = try string.toOwnedSlice();
    return stringified;
}
