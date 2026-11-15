// Renderer - paints DOM tree to a pixel buffer
// (simple: white background, black text)

const std = @import("std");
const dom = @import("dom.zig");

pub const Color = struct {
    r: u8 = 255,
    g: u8 = 255,
    b: u8 = 255,
    a: u8 = 255,
};

pub fn paint(doc: dom.Document, buffer: []u8, width: u32, height: u32) void {
    _ = doc;
    // Clear to white background
    var i: usize = 0;
    while (i < buffer.len) : (i += 4) {
        buffer[i] = 255;     // R
        buffer[i + 1] = 255; // G
        buffer[i + 2] = 255; // B
        buffer[i + 3] = 255; // A
    }

    // Draw a simple representation: title at top, then text content
    // (This is a placeholder - real rendering would use font metrics)

    // Draw "Silly Engine" header
    drawText(buffer, width, 10, 10, "Silly Engine v0.1 - Rendering placeholder", 0, 0, 0);

    // Draw a simple border
    drawRect(buffer, width, height, 0, 0, width - 1, height - 1, 128, 128, 128);
}

fn drawText(buffer: []u8, width: u32, x: u32, y: u32, text: []const u8, r: u8, g: u8, b: u8) void {
    // Simple 8x8 bitmap font placeholder
    // Just draw dots for each character (very basic)
    var cx = x;
    for (text) |c| {
        if (c == ' ') {
            cx += 4;
            continue;
        }
        // Draw a simple block for each char
        var dy: u32 = 0;
        while (dy < 8) : (dy += 1) {
            var dx: u32 = 0;
            while (dx < 6) : (dx += 1) {
                const px = cx + dx;
                const py = y + dy;
                if (px < width and py < (buffer.len / (width * 4))) {
                    const idx = (py * width + px) * 4;
                    if (idx + 3 < buffer.len) {
                        buffer[idx] = r;
                        buffer[idx + 1] = g;
                        buffer[idx + 2] = b;
                    }
                }
            }
        }
        cx += 7;
    }
}

fn drawRect(buffer: []u8, width: u32, height: u32, x1: u32, y1: u32, x2: u32, y2: u32, r: u8, g: u8, b: u8) void {
    _ = height;
    // top and bottom
    var x = x1;
    while (x <= x2) : (x += 1) {
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
    // left and right
    var y = y1;
    while (y <= y2) : (y += 1) {
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
    return .{ .r = 0, .g = 0, .b = 0 };
}
