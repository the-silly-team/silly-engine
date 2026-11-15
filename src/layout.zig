// Layout engine - computes positions and sizes of DOM nodes
// (block layout: elements stacked vertically)

const std = @import("std");
const dom = @import("dom.zig");
const css = @import("css.zig");

pub const Rect = struct {
    x: f32 = 0,
    y: f32 = 0,
    width: f32 = 0,
    height: f32 = 0,
};

pub const LayoutBox = struct {
    rect: Rect = .{},
    node: *dom.Node,
    children: std.ArrayList(LayoutBox),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, node: *dom.Node) LayoutBox {
        return .{
            .node = node,
            .children = std.ArrayList(LayoutBox).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *LayoutBox) void {
        for (self.children.items) |*child| {
            child.deinit();
        }
        self.children.deinit();
    }
};

pub fn compute(allocator: std.mem.Allocator, doc: *dom.Document, stylesheet: ?css.Stylesheet, viewport_width: u32, viewport_height: u32) !void {
    // Simple block layout: walk DOM tree, stack elements vertically
    _ = stylesheet;
    _ = viewport_height;

    var y_offset: f32 = 10; // top margin
    const line_height: f32 = 18;
    const indent: f32 = 10;

    // Walk through all nodes

    // Simple recursive layout
    try layoutNode(allocator, doc.root, &y_offset, indent, @as(f32, @floatFromInt(viewport_width)), line_height);
}

fn layoutNode(allocator: std.mem.Allocator, node: *dom.Node, y: *f32, x: f32, viewport_width: f32, line_height: f32) !void {
    switch (node.node_type) {
        .element => {
            // Block elements take full width
            const tag = node.tag;
            if (isBlockElement(tag)) {
                y.* += 4; // margin
                // Estimate height based on children
                for (node.children.items) |child| {
                    try layoutNode(allocator, child, y, x + 0, viewport_width, line_height);
                }
                // If no children, give it some height
                if (node.children.items.len == 0) {
                    y.* += line_height;
                }
                y.* += 4; // margin
            } else {
                // Inline element - just lay out children
                for (node.children.items) |child| {
                    try layoutNode(allocator, child, y, x, viewport_width, line_height);
                }
            }
        },
        .text => {
            // Text node - estimate height
            const text = node.text;
            if (text.len > 0) {
                // Simple: one line per ~80 chars
                const lines_needed = (text.len + 79) / 80;
                y.* += @as(f32, @floatFromInt(lines_needed)) * line_height;
            }
        },
        .document => {
            for (node.children.items) |child| {
                try layoutNode(allocator, child, y, x, viewport_width, line_height);
            }
        },
        .comment => {},
    }
}

fn isBlockElement(tag: []const u8) bool {
    const block_tags = [_][]const u8{ "html", "body", "div", "p", "h1", "h2", "h3", "h4", "h5", "h6", "ul", "ol", "li", "table", "tr", "td", "th", "section", "article", "header", "footer", "nav", "main", "aside", "blockquote", "pre", "form", "fieldset" };
    for (block_tags) |bt| {
        if (std.mem.eql(u8, tag, bt)) return true;
    }
    return false;
}

pub fn getRect(node: *dom.Node) Rect {
    _ = node;
    return .{};
}
