// silly engine - demo app
// parses HTML and CSS, prints the DOM tree

const std = @import("std");
const engine = @import("engine.zig");
const dom = @import("dom.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var eng = engine.Engine.init(allocator);
    defer eng.deinit();

    // Sample HTML
    const html_source =
        \\<!DOCTYPE html>
        \\<html>
        \\  <head><title>Silly Engine Demo</title></head>
        \\  <body>
        \\    <h1>Hello from Silly Engine!</h1>
        \\    <p>This is a paragraph with some text.</p>
        \\    <div class="container">
        \\      <p>Nested paragraph inside a div.</p>
        \\      <ul>
        \\        <li>Item one</li>
        \\        <li>Item two</li>
        \\      </ul>
        \\    </div>
        \\  </body>
        \\</html>
    ;

    // Sample CSS
    const css_source =
        \\body { background: #ffffff; color: #000000; }
        \\h1 { color: #8b6cf0; }
        \\.container { margin: 10px; }
        \\p { line-height: 1.5; }
    ;

    std.debug.print("=== Silly Engine Demo ===\\n", .{});
    std.debug.print("\\nLoading HTML...\\n", .{});

    try eng.loadHTML(html_source);
    std.debug.print("Title: {s}\\n", .{eng.getTitle()});

    std.debug.print("\\nLoading CSS...\\n", .{});
    try eng.loadCSS(css_source);

    std.debug.print("\\nComputing layout (800x600)...\\n", .{});
    try eng.layout(800, 600);

    std.debug.print("\\nRendering...\\n", .{});
    const buffer_size = 800 * 600 * 4;
    const buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);
    eng.render(buffer, 800, 600);

    std.debug.print("Rendered {d} bytes\\n", .{buffer.len});

    // Print DOM tree
    std.debug.print("\\n=== DOM Tree ===\\n", .{});
    if (eng.document) |doc| {
        printNode(doc.root, 0);
    }

    std.debug.print("\\n=== Done ===\\n", .{});
}

fn printNode(node: *dom.Node, depth: usize) void {
    var i: usize = 0;
    while (i < depth) : (i += 1) {
        std.debug.print("  ", .{});
    }
    switch (node.node_type) {
        .document => {
            std.debug.print("[document]\\n", .{});
            for (node.children.items) |child| {
                printNode(child, depth + 1);
            }
        },
        .element => {
            std.debug.print("<{s}", .{node.tag});
            var it = node.attributes.iterator();
            while (it.next()) |entry| {
                std.debug.print(" {s}=\"{s}\"", .{ entry.key_ptr.*, entry.value_ptr.* });
            }
            std.debug.print(">\\n", .{});
            for (node.children.items) |child| {
                printNode(child, depth + 1);
            }
            i = 0;
            while (i < depth) : (i += 1) {
                std.debug.print("  ", .{});
            }
            std.debug.print("</{s}>\\n", .{node.tag});
        },
        .text => std.debug.print("\"{s}\"\\n", .{node.text}),
        .comment => std.debug.print("<!-- comment -->\\n", .{}),
    }
}
