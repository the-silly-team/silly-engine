# silly engine

a lightweight HTML/CSS/JS browser engine written in zig.

built for the silly browser and anyone who wants to render web pages without chromium.

## status

🚧 **very early development** 🚧

currently implements:
- HTML parser (basic tags, attributes, text nodes)
- CSS parser (rules, declarations, basic selectors)
- DOM tree
- block layout (elements stacked vertically)
- basic renderer (placeholder - draws "Silly Engine" text)

## building

requires [zig 0.13.0+](https://ziglang.org/download/)

```sh
zig build
zig build run
zig build test
```

## roadmap

- [x] HTML parser
- [x] CSS parser
- [x] DOM tree
- [x] block layout
- [ ] inline layout (text flow)
- [ ] CSS selector matching
- [ ] style computation (cascade, inheritance)
- [ ] text rendering (font metrics)
- [ ] JavaScript engine integration
- [ ] windowing / surface (raylib or SDL)
- [ ] network (HTTP client)
- [ ] embeddable C API
- [ ] powers silly browser v2

## license

MIT

made with :3 and concerning amounts of coffee.. and tons of brain liquidation 🥖💜
