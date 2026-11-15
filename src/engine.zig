// silly engine - public API
// this is what embedders use to render HTML/CSS

const std = @import("std");
const dom = @import("dom.zig");
const html = @import("html.zig");
const css = @import("css.zig");
const selector = @import("selector.zig");
const layout_mod = @import("layout.zig");
const render_mod = @import("render.zig");

pub const Engine = struct {
    allocator: std.mem.Allocator,
    document: ?dom.Document = null,
    stylesheet: ?css.Stylesheet = null,

    pub fn init(allocator: std.mem.Allocator) Engine {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *Engine) void {
        if (self.document) |*doc| doc.deinit();
        if (self.stylesheet) |*ss| ss.deinit();
    }

    /// Load HTML from a string
    pub fn loadHTML(self: *Engine, source: []const u8) !void {
        if (self.document) |*doc| doc.deinit();
        self.document = try html.parse(self.allocator, source);
    }

    /// Load CSS from a string
    pub fn loadCSS(self: *Engine, source: []const u8) !void {
        if (self.stylesheet) |*ss| ss.deinit();
        self.stylesheet = try css.parse(self.allocator, source);
    }

    /// Compute layout for a given viewport size
    pub fn layout(self: *Engine, width: u32, height: u32) !void {
        if (self.document) |*doc| {
            const ss = if (self.stylesheet) |s| s else null;
            try layout_mod.compute(self.allocator, doc, ss, width, height);
        }
    }

    /// Render to a pixel buffer (RGBA, width*height*4 bytes)
    pub fn render(self: *Engine, buffer: []u8, width: u32, height: u32) void {
        if (self.document) |doc| {
            render_mod.renderDOM(doc, buffer, width, height, self.stylesheet);
        } else {
            // clear to white
            for (buffer) |*b| b.* = 255;
        }
    }

    /// Get computed style for a node
    pub fn getStyle(self: *Engine, node: *dom.Node) !std.StringHashMap([]const u8) {
        if (self.stylesheet) |*ss| {
            return try selector.computeStyle(ss, node, self.allocator);
        }
        return std.StringHashMap([]const u8).init(self.allocator);
    }

    /// Get the document title
    pub fn getTitle(self: *Engine) []const u8 {
        if (self.document) |doc| {
            return doc.title;
        }
        return "";
    }
};

// Re-export types for embedders
pub const Document = dom.Document;
pub const Node = dom.Node;
pub const NodeType = dom.NodeType;
pub const Stylesheet = css.Stylesheet;
pub const Color = render_mod.Color;
pub const Rect = layout_mod.Rect;
