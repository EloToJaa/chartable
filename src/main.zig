const std = @import("std");
const cli = @import("cli");
const lib = @import("lib/lib.zig");

const Config = struct {
    pad: bool,
    format: []const u8,
};

fn parseArgs(config: *Config) cli.AppRunner.Error!cli.ExecFn {
    var r = try cli.AppRunner.init(std.heap.page_allocator);

    const app = cli.App{
        .option_envvar_prefix = "CHARTABLE_", // Prefix for environment variables.
        .author = "EloToJaa",
        .version = "0.0.0",
        .command = cli.Command{
            .name = "chartable",
            .description = cli.Description{
                .one_line = "Prints a table of ASCII characters.",
                .detailed = "Prints a table of ASCII characters. Multi line",
            },
            .options = try r.allocOptions(.{
                cli.Option{
                    .long_name = "pad",
                    .help = "Pad the output with zeros.",
                    .short_alias = 'p',
                    .value_ref = r.mkRef(config.pad),
                },
                cli.Option{
                    .long_name = "format",
                    .help = "Output format.",
                    .short_alias = 'f',
                    .value_ref = r.mkRef(config.format),
                },
            }),
            .target = cli.CommandTarget{
                .subcommands = try r.allocCommands(&.{}),
            },
        },
    };

    return r.getAction(&app);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var config = Config{};
    const action = try parseArgs(&config);
    const r = action();

    allocator.free(config.format);
    if (gpa.deinit() == .leak) {
        @panic("config leaked");
    }

    return r;

    // const allocator = std.heap.page_allocator;
    //
    // const asciiTable = try lib.Character.readTable(allocator, true);
    // defer for (asciiTable) |character| character.deinit(allocator);
    //
    // const jsonString = try lib.json.stringifyObject(allocator, asciiTable);
    // defer allocator.free(jsonString);
    //
    // const stdout = std.io.getStdOut().writer();
    //
    // try stdout.print("{s}", .{jsonString});

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
}
