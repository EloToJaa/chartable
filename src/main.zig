const std = @import("std");
const cli = @import("cli");
const lib = @import("lib/lib.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const asciiTable = try lib.Character.readTable(allocator, true);
    defer for (asciiTable) |character| character.deinit(allocator);

    const jsonString = try lib.json.stringifyObject(allocator, asciiTable);
    defer allocator.free(jsonString);

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

    var r = try cli.AppRunner.init(allocator);

    const app = cli.App{
        .option_envvar_prefix = "CHARTABLE_", // Prefix for environment variables.
        .author = "EloToJaa",
        .version = "0.0.0",
        .command = cli.Command{},
    };

    return r.run(&app);
}
