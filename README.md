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
- basic renderer (paints to pixel buffer)
- **Win32 GUI** (displays rendered output in a window)

## building

requires [zig 0.13.0+](https://ziglang.org/download/)

```sh
zig build
zig build run    # opens a window with rendered output
zig build test   # run unit tests
```

## roadmap

- [x] HTML parser
- [x] CSS parser
- [x] DOM tree
- [x] block layout
- [x] basic renderer (pixel buffer)
- [x] Win32 GUI window
- [ ] inline layout (text flow)
- [ ] CSS selector matching
- [ ] style computation (cascade, inheritance)
- [ ] text rendering (font metrics, actual glyphs)
- [ ] JavaScript engine integration
- [ ] network (HTTP client)
- [ ] embeddable C API
- [ ] powers silly browser v2

## why zig?

because it sounds silly. and we are all about silly.

also it's fast, memory-safe, has great C interop, and doesn't have a garbage collector. perfect for a browser engine.

## the corporate overlords

the silly engine is a product of **brain liquidation inc.**, a fictional corporation whose primary business is supposedly liquidating brains. its subsidiaries include potato computing, the bread foundation, silly systems, neuron destruction llc, and nobro technologies.

the ceo is half a braincell. the legal department is questionable. the financial department is bread-dependent. the stock ticker is BRAIN and the stock price is -999999%.

applesoft has sued brain liquidation inc. for solidifying brains instead of liquidating them. nobro technologies has no bro. the bread foundation controls the entire economy.

the breadening is inevitable. 🥖

## license

MIT

<div align="center">
  <p>built with <code>:3</code> and a concerning amount of coffee..... and also a tiny bit of brain liquidation</p>
  <p>
    <a href="https://github.com/the-silly-team">github.com/the-silly-team</a>
  </p>
  <p><sub>the bread foundation remains operational 🥖</sub></p>
</div>
