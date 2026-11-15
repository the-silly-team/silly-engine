# 🧠 THE SILLY ENGINE 🧠

## A LIGHTWEIGHT HTML/CSS/JS BROWSER ENGINE WRITTEN IN ZIG

no chromium. no gecko. just zig and vibes.

## STATUS

early development. currently implements:
- html parser (basic tags, attributes, text nodes)
- css parser (rules, declarations, basic selectors)
- dom tree
- block layout (elements stacked vertically)
- basic text rendering (5x7 bitmap font, actual characters)
- win32 gui (displays rendered output in a window)
- css selector matching
- style computation (cascade, inheritance)
- 6 unit tests passing

## BUILDING

requires [zig 0.13.0+](https://ziglang.org/download/)

```sh
zig build
zig build run    # opens a window with rendered output
zig build test   # run unit tests
```

## WHY ZIG?

because it sounds silly. and we are all about silly.

also it's fast, memory-safe, has great c interop, and doesn't have a garbage collector. perfect for a browser engine.

## ROADMAP

- [x] html parser
- [x] css parser
- [x] dom tree
- [x] block layout
- [x] basic text rendering (bitmap font)
- [x] win32 gui window
- [x] css selector matching
- [x] style computation
- [ ] inline layout (text flow)
- [ ] text rendering (font metrics, actual glyphs)
- [ ] javascript engine integration
- [ ] network (http client)
- [ ] embeddable c api
- [ ] powers silly browser v2

## LICENSE

mit

<div align="center">
  <p>built with <code>:3</code> and a concerning amount of coffee.....</p>
  <p>
    <a href="https://github.com/the-silly-team">github.com/the-silly-team</a>
  </p>
</div>
