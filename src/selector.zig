// CSS selector matching - added to css.zig

const std = @import("std");
const dom = @import("dom.zig");
const css = @import("css.zig");

/// Check if a selector matches a node
pub fn matchesSelector(selector: []const u8, node: *dom.Node) bool {
    if (node.node_type != .element) return false;

    const trimmed = std.mem.trim(u8, selector, " \t\n\r");

    // ID selector: #idname
    if (trimmed.len > 0 and trimmed[0] == '#') {
        const id = trimmed[1..];
        if (node.getAttribute("id")) |node_id| {
            return std.mem.eql(u8, node_id, id);
        }
        return false;
    }

    // Class selector: .classname
    if (trimmed.len > 0 and trimmed[0] == '.') {
        const class_name = trimmed[1..];
        return node.hasClass(class_name);
    }

    // Element selector: tagname
    return std.mem.eql(u8, trimmed, node.tag);
}

/// Get all matching rules for a node (in order of specificity)
pub fn getMatchingRules(sheet: *const css.Stylesheet, node: *dom.Node, allocator: std.mem.Allocator) !std.ArrayList(*const css.Rule) {
    var matches = std.ArrayList(*const css.Rule).init(allocator);
    for (sheet.rules.items) |*rule| {
        if (matchesSelector(rule.selector, node)) {
            try matches.append(rule);
        }
    }
    return matches;
}

/// Compute the style for a node by merging all matching rules
pub fn computeStyle(sheet: *const css.Stylesheet, node: *dom.Node, allocator: std.mem.Allocator) !std.StringHashMap([]const u8) {
    var style = std.StringHashMap([]const u8).init(allocator);

    // Get matching rules in order
    var matches = try getMatchingRules(sheet, node, allocator);
    defer matches.deinit();

    // Apply rules in order (later rules override earlier ones)
    for (matches.items) |rule| {
        for (rule.declarations.items) |decl| {
            const key = try allocator.dupe(u8, decl.property);
            const val = try allocator.dupe(u8, decl.value);
            try style.put(key, val);
        }
    }

    return style;
}
