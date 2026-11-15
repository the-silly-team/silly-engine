# the silly engine

a lightweight html/css/js browser engine written in zig.

built for the silly browser and anyone who wants to render web pages without chromium.

## status

early development. currently implements:
- html parser (basic tags, attributes, text nodes)
- css parser (rules, declarations, basic selectors)
- dom tree
- block layout (elements stacked vertically)
- basic text rendering (5x7 bitmap font)
- win32 gui (displays rendered output in a window)

## building

requires [zig 0.13.0+](https://ziglang.org/download/)

```sh
zig build
zig build run    # opens a window with rendered output
zig build test   # run unit tests
```

## roadmap

- [x] html parser
- [x] css parser
- [x] dom tree
- [x] block layout
- [x] basic text rendering (bitmap font)
- [x] win32 gui window
- [ ] inline layout (text flow)
- [ ] css selector matching
- [ ] style computation (cascade, inheritance)
- [ ] text rendering (font metrics, actual glyphs)
- [ ] javascript engine integration
- [ ] network (http client)
- [ ] embeddable c api
- [ ] powers silly browser v2

## why zig?

because it sounds silly. and we are all about silly.

also it's fast, memory-safe, has great c interop, and doesn't have a garbage collector. perfect for a browser engine.

## license

mit

<div align="center">
  <p>built with <code>:3</code> and a concerning amount of coffee.....</p>
  <p>
    <a href="https://github.com/the-silly-team">github.com/the-silly-team</a>
  </p>
</div>
