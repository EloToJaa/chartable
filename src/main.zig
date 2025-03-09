const std = @import("std");
const allocPrint = std.fmt.allocPrint;

const Character = struct {
    name: []const u8,
    description: []const u8,
    dec: u8,
    bin: []const u8,
    oct: []const u8,
    hex: []const u8,

    const ascii = @embedFile("ascii.json");

    pub fn readTable(allocator: std.mem.Allocator) ![]const Character {
        const parsed = try std.json.parseFromSlice([]const []const []const u8, allocator, ascii, .{});
        defer parsed.deinit();
        const values = parsed.value;

        const characters = try allocator.alloc(Character, values.len);
        for (values, 0..) |data, value| {
            const name = data[0];
            const description = data[1];
            const bin = try allocPrint(allocator, "{b:0>8}", .{value});
            const oct = try allocPrint(allocator, "{o:0>3}", .{value});
            const hex = try allocPrint(allocator, "{X:0>2}", .{value});
            characters[value] = Character{
                .name = name,
                .description = description,
                .dec = @intCast(value),
                .bin = bin,
                .oct = oct,
                .hex = hex,
            };
        }
        return characters;
    }

    pub fn stringifyTable(allocator: std.mem.Allocator, characters: []const Character) ![]const u8 {
        var string = std.ArrayList(u8).init(allocator);
        try std.json.stringify(characters, .{}, string.writer());
        return string.items;
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const asciiTable = try Character.readTable(allocator);
    const jsonString = try Character.stringifyTable(allocator, asciiTable);

    const stdout = std.io.getStdOut().writer();

    try stdout.print("{s}", .{jsonString});

    // for (asciiTable) |character| {
    //     std.debug.print("{s} {s} {d} {s} {s} {s}\n", .{
    //         character.name,
    //         character.description,
    //         character.dec,
    //         character.bin,
    //         character.oct,
    //         character.hex,
    //     });
    // }

    // std.debug.print("Hello, world!\n{s}", .{ascii});
}
