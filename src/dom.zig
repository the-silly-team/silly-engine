// DOM (Document Object Model) tree
// represents the parsed HTML structure

const std = @import("std");

pub const NodeType = enum {
    document,
    element,
    text,
    comment,
};

pub const Node = struct {
    node_type: NodeType,
    tag: []const u8 = "",
    text: []const u8 = "",
    attributes: std.StringHashMap([]const u8),
    children: std.ArrayList(*Node),
    parent: ?*Node = null,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, node_type: NodeType) !*Node {
        const node = try allocator.create(Node);
        node.* = .{
            .node_type = node_type,
            .attributes = std.StringHashMap([]const u8).init(allocator),
            .children = std.ArrayList(*Node).init(allocator),
            .allocator = allocator,
        };
        return node;
    }

    pub fn deinit(self: *Node) void {
        for (self.children.items) |child| {
            child.deinit();
        }
        self.children.deinit();
        self.attributes.deinit();
        self.allocator.destroy(self);
    }

    pub fn appendChild(self: *Node, child: *Node) !void {
        child.parent = self;
        try self.children.append(child);
    }

    pub fn getAttribute(self: *Node, name: []const u8) ?[]const u8 {
        return self.attributes.get(name);
    }

    pub fn setAttribute(self: *Node, name: []const u8, value: []const u8) !void {
        try self.attributes.put(name, value);
    }

    pub fn hasClass(self: *Node, class_name: []const u8) bool {
        if (self.attributes.get("class")) |classes| {
            var it = std.mem.splitScalar(u8, classes, ' ');
            while (it.next()) |c| {
                if (std.mem.eql(u8, c, class_name)) return true;
            }
        }
        return false;
    }

    pub fn getId(self: *Node) ?[]const u8 {
        return self.attributes.get("id");
    }
};

pub const Document = struct {
    root: *Node,
    title: []const u8 = "",
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Document {
        const root = try Node.init(allocator, .document);
        return .{ .root = root, .allocator = allocator };
    }

    pub fn deinit(self: *Document) void {
        self.root.deinit();
    }
};
