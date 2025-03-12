const std = @import("std");
const allocPrint = std.fmt.allocPrint;

const ascii = @embedFile("ascii.json");

const Character = struct {
    name: []const u8,
    description: []const u8,
    dec: u8,
    bin: []const u8,
    oct: []const u8,
    hex: []const u8,

    pub fn init(allocator: std.mem.Allocator, name: []const u8, description: []const u8, dec: u8, pad: bool) !Character {
        const bin = if (pad) try allocPrint(allocator, "{b:0>8}", .{dec}) else try allocPrint(allocator, "{b}", .{dec});
        const oct = if (pad) try allocPrint(allocator, "{o:0>3}", .{dec}) else try allocPrint(allocator, "{o}", .{dec});
        const hex = if (pad) try allocPrint(allocator, "{X:0>2}", .{dec}) else try allocPrint(allocator, "{X}", .{dec});
        return Character{
            .name = name,
            .description = description,
            .dec = dec,
            .bin = bin,
            .oct = oct,
            .hex = hex,
        };
    }

    pub fn deinit(self: *const Character, allocator: std.mem.Allocator) void {
        allocator.free(self.bin);
        allocator.free(self.oct);
        allocator.free(self.hex);
    }

    pub fn readTable(allocator: std.mem.Allocator, pad: bool) ![]const Character {
        const parsed = try std.json.parseFromSlice([]const []const []const u8, allocator, ascii, .{});
        defer parsed.deinit();
        const values = parsed.value;

        const characters = try allocator.alloc(Character, values.len);
        for (values, 0..) |data, value| {
            characters[value] = try Character.init(allocator, data[0], data[1], @intCast(value), pad);
        }
        return characters;
    }
};
