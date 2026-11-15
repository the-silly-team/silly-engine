// HTML parser - converts HTML source into a DOM tree
// (simplified, handles basic tags)

const std = @import("std");
const dom = @import("dom.zig");

pub fn parse(allocator: std.mem.Allocator, source: []const u8) !dom.Document {
    var doc = try dom.Document.init(allocator);
    var current: *dom.Node = doc.root;
    var i: usize = 0;

    while (i < source.len) {
        if (source[i] == '<') {
            // find the end of the tag
            const tag_end = std.mem.indexOfScalar(u8, source[i..], '>') orelse break;
            const tag_content = source[i + 1 .. i + tag_end];

            if (tag_content.len > 0 and tag_content[0] == '/') {
                // closing tag - go up
                if (current.parent) |p| current = p;
            } else if (tag_content.len > 0 and (tag_content[0] == '!' or tag_content[0] == '?')) {
                // doctype or comment, skip
            } else {
                // parse tag name
                var tag_name_end: usize = 0;
                while (tag_name_end < tag_content.len and tag_content[tag_name_end] != ' ' and tag_content[tag_name_end] != '/' and tag_content[tag_name_end] != '>') {
                    tag_name_end += 1;
                }
                const tag_name = tag_content[0..tag_name_end];

                // skip void elements
                const is_void = isVoidElement(tag_name);

                // create element node
                const element = try dom.Node.init(allocator, .element);
                element.tag = try allocator.dupe(u8, tag_name);
                try parseAttributes(allocator, element, tag_content[tag_name_end..]);

                // handle title
                if (std.mem.eql(u8, tag_name, "title")) {
                    // find text content
                    const content_start = i + tag_end + 1;
                    if (std.mem.indexOf(u8, source[content_start..], "</title>")) |end_idx| {
                        doc.title = try allocator.dupe(u8, source[content_start .. content_start + end_idx]);
                    }
                }

                try current.appendChild(element);

                if (!is_void) {
                    current = element;
                }
            }
            i += tag_end + 1;
        } else {
            // text content
            const text_start = i;
            while (i < source.len and source[i] != '<') {
                i += 1;
            }
            const text = std.mem.trim(u8, source[text_start..i], " \t\n\r");
            if (text.len > 0) {
                const text_node = try dom.Node.init(allocator, .text);
                text_node.text = try allocator.dupe(u8, text);
                try current.appendChild(text_node);
            }
        }
    }

    // go back to root
    while (current.parent) |p| current = p;

    return doc;
}

fn isVoidElement(tag: []const u8) bool {
    const void_elements = [_][]const u8{ "br", "hr", "img", "input", "meta", "link", "col", "embed", "source", "wbr", "area", "base", "param" };
    for (void_elements) |ve| {
        if (std.mem.eql(u8, tag, ve)) return true;
    }
    return false;
}

fn parseAttributes(allocator: std.mem.Allocator, node: *dom.Node, attr_str: []const u8) !void {
    var i: usize = 0;
    while (i < attr_str.len) {
        // skip whitespace and /
        while (i < attr_str.len and (attr_str[i] == ' ' or attr_str[i] == '/')) {
            i += 1;
        }
        if (i >= attr_str.len) break;

        // find attribute name
        const name_start = i;
        while (i < attr_str.len and attr_str[i] != '=' and attr_str[i] != ' ' and attr_str[i] != '>') {
            i += 1;
        }
        const name = attr_str[name_start..i];

        if (i >= attr_str.len or attr_str[i] != '=') {
            // boolean attribute
            if (name.len > 0) {
                try node.setAttribute(name, "");
            }
            continue;
        }
        i += 1; // skip =

        // skip whitespace
        while (i < attr_str.len and attr_str[i] == ' ') i += 1;

        // find value
        var value: []const u8 = "";
        if (i < attr_str.len and (attr_str[i] == '"' or attr_str[i] == '\'')) {
            const quote = attr_str[i];
            i += 1;
            const val_start = i;
            while (i < attr_str.len and attr_str[i] != quote) {
                i += 1;
            }
            value = attr_str[val_start..i];
            i += 1; // skip closing quote
        } else {
            const val_start = i;
            while (i < attr_str.len and attr_str[i] != ' ' and attr_str[i] != '>') {
                i += 1;
            }
            value = attr_str[val_start..i];
        }

        if (name.len > 0) {
            const name_dup = try allocator.dupe(u8, name);
            const value_dup = try allocator.dupe(u8, value);
            try node.setAttribute(name_dup, value_dup);
        }
    }
}
