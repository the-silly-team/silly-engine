// Renderer - paints DOM tree to a pixel buffer
// Uses font.zig for text rendering

const std = @import("std");
const dom = @import("dom.zig");
const css = @import("css.zig");
const selector = @import("selector.zig");
const font = @import("font.zig");

pub const Color = struct {
    r: u8 = 255,
    g: u8 = 255,
    b: u8 = 255,
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

pub fn paint(doc: dom.Document, buffer: []u8, width: u32, height: u32) void {
    _ = doc;
    // Clear to white background
    var i: usize = 0;
    while (i < buffer.len) : (i += 4) {
        buffer[i] = 255;
        buffer[i + 1] = 255;
        buffer[i + 2] = 255;
        buffer[i + 3] = 255;
    }

    // Draw border
    drawRect(buffer, width, height, 0, 0, width - 1, height - 1, 128, 128, 128);

    // Draw title
    font.drawText(buffer, width, 10, 10, "Silly Engine v0.3", 1, 139, 108, 240);

    // Draw subtitle
    font.drawText(buffer, width, 10, 30, "HTML/CSS/JS Browser Engine in Zig", 1, 100, 100, 100);
}

pub fn renderDOM(doc: dom.Document, buffer: []u8, width: u32, height: u32, stylesheet: ?css.Stylesheet) void {
    _ = stylesheet;
    // Clear to white background
    var i: usize = 0;
    while (i < buffer.len) : (i += 4) {
        buffer[i] = 255;
        buffer[i + 1] = 255;
        buffer[i + 2] = 255;
        buffer[i + 3] = 255;
    }

    // Draw border
    drawRect(buffer, width, height, 0, 0, width - 1, height - 1, 200, 200, 200);

    var y: u32 = 10;
    renderNode(doc.root, buffer, width, height, &y, 10);
}

fn renderNode(node: *dom.Node, buffer: []u8, width: u32, height: u32, y: *u32, indent: u32) void {
    switch (node.node_type) {
        .text => {
            const text = std.mem.trim(u8, node.text, " \t\n\r");
            if (text.len > 0 and y.* + 10 < height) {
                font.drawText(buffer, width, indent, y.*, text, 1, 0, 0, 0);
                y.* += 12;
            }
        },
        .element => {
            if (std.mem.eql(u8, node.tag, "h1")) {
                if (y.* + 20 < height) {
                    // render h1 text in purple, bigger (scale 2)
                    for (node.children.items) |child| {
                        if (child.node_type == .text) {
                            font.drawText(buffer, width, indent, y.*, child.text, 2, 139, 108, 240);
                            y.* += 18;
                        }
                    }
                }
            } else if (std.mem.eql(u8, node.tag, "h2")) {
                if (y.* + 16 < height) {
                    for (node.children.items) |child| {
                        if (child.node_type == .text) {
                            font.drawText(buffer, width, indent, y.*, child.text, 1, 100, 100, 100);
                            y.* += 14;
                        }
                    }
                }
            } else {
                for (node.children.items) |child| {
                    renderNode(child, buffer, width, height, y, indent);
                }
            }
            if (isBlock(node.tag)) {
                y.* += 4;
            }
        },
        .document => {
            for (node.children.items) |child| {
                renderNode(child, buffer, width, height, y, indent);
            }
        },
        .comment => {},
    }
}

fn isBlock(tag: []const u8) bool {
    const blocks = [_][]const u8{ "p", "div", "h1", "h2", "h3", "h4", "h5", "h6", "ul", "ol", "li", "section", "article", "header", "footer", "blockquote", "pre", "form", "body", "html" };
    for (blocks) |b| {
        if (std.mem.eql(u8, tag, b)) return true;
    }
    return false;
}

fn drawRect(buffer: []u8, width: u32, height: u32, x1: u32, y1: u32, x2: u32, y2: u32, r: u8, g: u8, b: u8) void {
    _ = height;
    var x = x1;
    while (x <= x2 and x < width) : (x += 1) {
        if (y1 * width + x < buffer.len / 4) {
            const idx = (y1 * width + x) * 4;
            buffer[idx] = r;
            buffer[idx + 1] = g;
            buffer[idx + 2] = b;
        }
        if (y2 * width + x < buffer.len / 4) {
            const idx = (y2 * width + x) * 4;
            buffer[idx] = r;
            buffer[idx + 1] = g;
            buffer[idx + 2] = b;
        }
    }
    var y = y1;
    while (y <= y2 and y < (buffer.len / (width * 4))) : (y += 1) {
        if (y * width + x1 < buffer.len / 4) {
            const idx = (y * width + x1) * 4;
            buffer[idx] = r;
            buffer[idx + 1] = g;
            buffer[idx + 2] = b;
        }
        if (y * width + x2 < buffer.len / 4) {
            const idx = (y * width + x2) * 4;
            buffer[idx] = r;
            buffer[idx + 1] = g;
            buffer[idx + 2] = b;
        }
    }
}

pub fn colorFromCSS(value: []const u8) Color {
    if (value.len > 0 and value[0] == '#') {
        return Color.fromHex(value);
    }
    if (std.mem.eql(u8, value, "red")) return .{ .r = 255, .g = 0, .b = 0 };
    if (std.mem.eql(u8, value, "blue")) return .{ .r = 0, .g = 0, .b = 255 };
    if (std.mem.eql(u8, value, "green")) return .{ .r = 0, .g = 128, .b = 0 };
    if (std.mem.eql(u8, value, "black")) return .{ .r = 0, .g = 0, .b = 0 };
    if (std.mem.eql(u8, value, "white")) return .{ .r = 255, .g = 255, .b = 255 };
    if (std.mem.eql(u8, value, "purple")) return .{ .r = 139, .g = 108, .b = 240 };
    return .{ .r = 0, .g = 0, .b = 0 };
}
