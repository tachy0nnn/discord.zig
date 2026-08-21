const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    if (args.len < 2) {
        std.debug.print("usage: zig run .\\scripts\\py_to.zig -- <file.py>\n", .{});
        return;
    }

    const file_path = args[1];
    const input = try std.Io.Dir.cwd().readFileAlloc(init.io, file_path, arena, .unlimited);

    try convertPythonToZig(arena, input);
}

fn convertPythonToZig(allocator: std.mem.Allocator, input: []const u8) !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var in_struct = false;

    while (lines.next()) |raw_line| {
        const trimmed = std.mem.trim(u8, raw_line, " \t\r");

        if (trimmed.len == 0) {
            std.debug.print("\n", .{});
            continue;
        }

        // detect class header: class User(TypedDict):
        if (std.mem.startsWith(u8, trimmed, "class ") and std.mem.endsWith(u8, trimmed, ":")) {
            if (in_struct) {
                std.debug.print("}};\n\n", .{});
            }
            const class_decl = trimmed["class ".len .. trimmed.len - 1];
            const name_end = std.mem.indexOfAny(u8, class_decl, "(:") orelse class_decl.len;
            const class_name = std.mem.trim(u8, class_decl[0..name_end], " \t");

            std.debug.print("pub const {s} = struct {{\n", .{class_name});
            in_struct = true;
            continue;
        }

        // detect doc comments: #: ... or # ...
        if (std.mem.startsWith(u8, trimmed, "#:") or std.mem.startsWith(u8, trimmed, "#")) {
            const comment_text = if (std.mem.startsWith(u8, trimmed, "#:"))
                std.mem.trim(u8, trimmed[2..], " \t")
            else
                std.mem.trim(u8, trimmed[1..], " \t");

            if (in_struct) {
                std.debug.print("    /// {s}\n", .{comment_text});
            } else {
                std.debug.print("/// {s}\n", .{comment_text});
            }
            continue;
        }

        // detect fields: field_name: Type
        if (in_struct) {
            if (std.mem.indexOfScalar(u8, trimmed, ':')) |colon_idx| {
                const field_name = std.mem.trim(u8, trimmed[0..colon_idx], " \t");
                const py_type = std.mem.trim(u8, trimmed[colon_idx + 1 ..], " \t");

                if (field_name.len > 0 and py_type.len > 0) {
                    const parsed = try translateType(allocator, py_type);
                    const is_optional = parsed.is_optional or parsed.is_not_required;

                    if (is_optional) {
                        std.debug.print("    {s}: ?{s} = null,\n", .{ field_name, parsed.type_name });
                    } else {
                        std.debug.print("    {s}: {s},\n", .{ field_name, parsed.type_name });
                    }
                    continue;
                }
            }
        }
    }

    if (in_struct) {
        std.debug.print("}};\n", .{});
    }
}

const TranslatedType = struct {
    type_name: []const u8,
    is_optional: bool,
    is_not_required: bool,
};

fn translateType(allocator: std.mem.Allocator, py_type: []const u8) !TranslatedType {
    var raw = std.mem.trim(u8, py_type, " \t");
    var is_not_req = false;
    var is_opt = false;

    // NotRequired[...]
    if (std.mem.startsWith(u8, raw, "NotRequired[") and std.mem.endsWith(u8, raw, "]")) {
        is_not_req = true;
        raw = std.mem.trim(u8, raw["NotRequired[".len .. raw.len - 1], " \t");
    }

    // Optional[...]
    if (std.mem.startsWith(u8, raw, "Optional[") and std.mem.endsWith(u8, raw, "]")) {
        is_opt = true;
        raw = std.mem.trim(u8, raw["Optional[".len .. raw.len - 1], " \t");
    }

    // Union
    if (std.mem.indexOf(u8, raw, "|") != null) {
        var union_iter = std.mem.splitScalar(u8, raw, '|');
        var non_none_type: ?[]const u8 = null;

        while (union_iter.next()) |part| {
            const trimmed_part = std.mem.trim(u8, part, " \t");
            if (std.mem.eql(u8, trimmed_part, "None")) {
                is_opt = true;
            } else {
                non_none_type = trimmed_part;
            }
        }

        if (non_none_type) |nnt| {
            raw = nnt;
        }
    }

    const mapped_name = try mapBaseOrContainerType(allocator, raw);

    return TranslatedType{
        .type_name = mapped_name,
        .is_optional = is_opt,
        .is_not_required = is_not_req,
    };
}

fn mapBaseOrContainerType(allocator: std.mem.Allocator, raw: []const u8) ![]const u8 {
    const trimmed = std.mem.trim(u8, raw, " \t");

    // list containers list[T] or List[T]
    if ((std.mem.startsWith(u8, trimmed, "list[") or std.mem.startsWith(u8, trimmed, "List[")) and std.mem.endsWith(u8, trimmed, "]")) {
        const bracket_idx = std.mem.indexOfScalar(u8, trimmed, '[').?;
        const inner_type = trimmed[bracket_idx + 1 .. trimmed.len - 1];
        const inner_mapped = try mapBaseOrContainerType(allocator, inner_type);
        return std.fmt.allocPrint(allocator, "[]const {s}", .{inner_mapped});
    }

    // base primitive mappings
    if (std.mem.eql(u8, trimmed, "str")) return "[]const u8";
    if (std.mem.eql(u8, trimmed, "int") or std.mem.eql(u8, trimmed, "integer")) return "i64";
    if (std.mem.eql(u8, trimmed, "float")) return "f64";
    if (std.mem.eql(u8, trimmed, "bool")) return "bool";
    if (std.mem.eql(u8, trimmed, "Any")) return "std.json.Value";

    // custom identifier (Snowflake, Collectibles, DisplayNameStyle, etc)
    return trimmed;
}
