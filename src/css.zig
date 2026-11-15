// CSS parser - converts CSS source into a stylesheet

const std = @import("std");

pub const Color = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,

    pub fn fromHex(hex: []const u8) Color {
        if (hex.len >= 7 and hex[0] == '#') {
            const r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
            const g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
            const b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;
            return .{ .r = r, .g = g, .b = b };
        }
        return .{};
    }

    pub fn white() Color { return .{ .r = 255, .g = 255, .b = 255 }; }
    pub fn black() Color { return .{ .r = 0, .g = 0, .b = 0 }; }
};

pub const Declaration = struct {
    property: []const u8,
    value: []const u8,
};

pub const Rule = struct {
    selector: []const u8,
    declarations: std.ArrayList(Declaration),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, selector: []const u8) !Rule {
        return .{
            .selector = try allocator.dupe(u8, selector),
            .declarations = std.ArrayList(Declaration).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Rule) void {
        self.declarations.deinit();
        self.allocator.free(self.selector);
    }

    pub fn addDeclaration(self: *Rule, property: []const u8, value: []const u8) !void {
        try self.declarations.append(.{
            .property = try self.allocator.dupe(u8, property),
            .value = try self.allocator.dupe(u8, value),
        });
    }
};

pub const Stylesheet = struct {
    rules: std.ArrayList(Rule),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Stylesheet {
        return .{
            .rules = std.ArrayList(Rule).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Stylesheet) void {
        for (self.rules.items) |*rule| {
            rule.deinit();
        }
        self.rules.deinit();
    }
};

pub fn parse(allocator: std.mem.Allocator, source: []const u8) !Stylesheet {
    var sheet = Stylesheet.init(allocator);
    var i: usize = 0;

    while (i < source.len) {
        // skip whitespace and comments
        while (i < source.len and (source[i] == ' ' or source[i] == '\n' or source[i] == '\t' or source[i] == '\r')) {
            i += 1;
        }
        if (i >= source.len) break;

        // check for comment
        if (i + 1 < source.len and source[i] == '/' and source[i + 1] == '*') {
            const end = std.mem.indexOf(u8, source[i..], "*/") orelse break;
            i += end + 2;
            continue;
        }

        // find selector (everything up to {)
        const brace = std.mem.indexOfScalar(u8, source[i..], '{') orelse break;
        const selector = std.mem.trim(u8, source[i .. i + brace], " \t\n\r");
        i += brace + 1;

        // find closing brace
        const close = std.mem.indexOfScalar(u8, source[i..], '}') orelse break;
        const declarations_str = source[i .. i + close];
        i += close + 1;

        if (selector.len == 0) continue;

        var rule = try Rule.init(allocator, selector);

        // parse declarations
        var decl_iter = std.mem.splitScalar(u8, declarations_str, ';');
        while (decl_iter.next()) |decl| {
            const trimmed = std.mem.trim(u8, decl, " \t\n\r");
            if (trimmed.len == 0) continue;

            // find colon
            const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse continue;
            const property = std.mem.trim(u8, trimmed[0..colon], " \t\n\r");
            const value = std.mem.trim(u8, trimmed[colon + 1 ..], " \t\n\r");

            if (property.len > 0 and value.len > 0) {
                try rule.addDeclaration(property, value);
            }
        }

        try sheet.rules.append(rule);
    }

    return sheet;
}

/// Find a rule matching a simple selector
pub fn findRule(sheet: *const Stylesheet, selector: []const u8) ?*const Rule {
    for (sheet.rules.items) |*rule| {
        if (std.mem.eql(u8, rule.selector, selector)) {
            return rule;
        }
    }
    return null;
}
