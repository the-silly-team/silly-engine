// silly engine - GUI demo (Windows GDI)
// displays rendered pixel buffer in a window

const std = @import("std");
const engine = @import("engine.zig");
const dom = @import("dom.zig");

const windows = std.os.windows;

// Type aliases for Windows handles
const HINSTANCE = windows.HINSTANCE;
const HWND = windows.HWND;
const UINT = windows.UINT;
const WPARAM = windows.WPARAM;
const LPARAM = windows.LPARAM;
const LRESULT = windows.LRESULT;
const HBITMAP = *opaque {};
const HDC = windows.HDC;
const HGDIOBJ = *opaque {};

// Window dimensions
const WIDTH = 800;
const HEIGHT = 600;

// Global state
var g_buffer: ?[*]u8 = null;
var g_allocator: std.mem.Allocator = undefined;
var g_hwnd: ?HWND = null;
var g_hdc_mem: ?HDC = null;
var g_hbitmap: ?HBITMAP = null;
var g_bits: ?*anyopaque = null;

// Win32 constants
const WS_OVERLAPPEDWINDOW: u32 = 0x00CF0000;
const WS_VISIBLE: u32 = 0x10000000;
const CW_USEDEFAULT: i32 = @bitCast(@as(u32, 0x80000000));
const WM_DESTROY: u32 = 0x0002;
const WM_PAINT: u32 = 0x000F;
const SRCCOPY: u32 = 0x00CC0020;
const DIB_RGB_COLORS: u32 = 0;

// Extern functions
extern "kernel32" fn GetModuleHandleW(lpModuleName: ?[*:0]const u16) callconv(.C) ?HINSTANCE;
extern "user32" fn CreateWindowExA(
    dwExStyle: u32,
    lpClassName: [*:0]const u8,
    lpWindowName: [*:0]const u8,
    dwStyle: u32,
    X: i32,
    Y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: ?HWND,
    hMenu: ?windows.HMENU,
    hInstance: HINSTANCE,
    lpParam: ?*anyopaque,
) callconv(.C) ?HWND;

extern "user32" fn RegisterClassExA(lpwcx: *const WNDCLASSEXA) callconv(.C) u16;
extern "user32" fn DefWindowProcA(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(.C) LRESULT;
extern "user32" fn GetMessageA(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: u32, wMsgFilterMax: u32) callconv(.C) i32;
extern "user32" fn TranslateMessage(lpMsg: *const MSG) callconv(.C) i32;
extern "user32" fn DispatchMessageA(lpMsg: *const MSG) callconv(.C) LRESULT;
extern "user32" fn PostQuitMessage(nExitCode: i32) callconv(.C) void;
extern "user32" fn BeginPaint(hWnd: HWND, lpPaint: *PAINTSTRUCT) callconv(.C) windows.HDC;
extern "user32" fn EndPaint(hWnd: HWND, lpPaint: *const PAINTSTRUCT) callconv(.C) i32;
extern "user32" fn GetDC(hWnd: ?HWND) callconv(.C) windows.HDC;
extern "user32" fn ReleaseDC(hWnd: ?HWND, hDC: windows.HDC) callconv(.C) i32;

extern "gdi32" fn CreateDIBSection(
    hdc: windows.HDC,
    pbmi: *const BITMAPINFO,
    usage: u32,
    ppvBits: *?*anyopaque,
    hSection: ?windows.HANDLE,
    offset: u32,
) callconv(.C) ?HBITMAP;

extern "gdi32" fn SelectObject(hdc: windows.HDC, h: HBITMAP) callconv(.C) HGDIOBJ;
extern "gdi32" fn BitBlt(
    hdcDest: windows.HDC,
    nXDest: i32,
    nYDest: i32,
    nWidth: i32,
    nHeight: i32,
    hdcSrc: windows.HDC,
    nXSrc: i32,
    nYSrc: i32,
    dwRop: u32,
) callconv(.C) i32;
extern "gdi32" fn CreateCompatibleDC(hdc: windows.HDC) callconv(.C) ?windows.HDC;
extern "gdi32" fn DeleteDC(hdc: windows.HDC) callconv(.C) i32;
extern "gdi32" fn DeleteObject(ho: HGDIOBJ) callconv(.C) i32;

const WNDCLASSEXA = extern struct {
    cbSize: u32 = @sizeOf(WNDCLASSEXA),
    style: u32 = 0,
    lpfnWndProc: *const fn (HWND, UINT, WPARAM, LPARAM) callconv(.C) LRESULT,
    cbClsExtra: i32 = 0,
    cbWndExtra: i32 = 0,
    hInstance: HINSTANCE,
    hIcon: ?windows.HICON = null,
    hCursor: ?windows.HCURSOR = null,
    hbrBackground: ?windows.HBRUSH = null,
    lpszMenuName: ?[*:0]const u8 = null,
    lpszClassName: [*:0]const u8,
    hIconSm: ?windows.HICON = null,
};

const MSG = extern struct {
    hwnd: HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: u32,
    pt: extern struct { x: i32, y: i32 },
};

const PAINTSTRUCT = extern struct {
    hdc: windows.HDC,
    fErase: i32,
    rcPaint: extern struct { left: i32, top: i32, right: i32, bottom: i32 },
    fRestore: i32,
    fIncUpdate: i32,
    rgbReserved: [32]u8,
};

const BITMAPINFOHEADER = extern struct {
    biSize: u32 = @sizeOf(BITMAPINFOHEADER),
    biWidth: i32,
    biHeight: i32,
    biPlanes: u16 = 1,
    biBitCount: u16 = 32,
    biCompression: u32 = 0,
    biSizeImage: u32 = 0,
    biXPelsPerMeter: i32 = 0,
    biYPelsPerMeter: i32 = 0,
    biClrUsed: u32 = 0,
    biClrImportant: u32 = 0,
};

const BITMAPINFO = extern struct {
    bmiHeader: BITMAPINFOHEADER,
    bmiColors: [1]u32 = .{0},
};

fn wndProc(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM) callconv(.C) LRESULT {
    switch (msg) {
        WM_DESTROY => {
            PostQuitMessage(0);
            return 0;
        },
        WM_PAINT => {
            var ps: PAINTSTRUCT = undefined;
            const hdc = BeginPaint(hwnd, &ps);
            if (g_hdc_mem) |mem_dc| {
                _ = BitBlt(hdc, 0, 0, WIDTH, HEIGHT, mem_dc, 0, 0, SRCCOPY);
            }
            _ = EndPaint(hwnd, &ps);
            return 0;
        },
        else => return DefWindowProcA(hwnd, msg, wparam, lparam),
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    g_allocator = allocator;

    // Initialize engine
    var eng = engine.Engine.init(allocator);
    defer eng.deinit();

    const html_source =
        \\<!DOCTYPE html>
        \\<html>
        \\  <head><title>Silly Engine Demo</title></head>
        \\  <body>
        \\    <h1>Hello from Silly Engine!</h1>
        \\    <p>This is a paragraph with some text.</p>
        \\  </body>
        \\</html>
    ;

    try eng.loadHTML(html_source);
    try eng.layout(800, 600);

    // Allocate pixel buffer
    const buffer_size = WIDTH * HEIGHT * 4;
    const buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);

    // Render
    eng.render(buffer, WIDTH, HEIGHT);

    // Store buffer globally
    g_buffer = buffer.ptr;

    // Create window
    const hInstance = GetModuleHandleW(null).?;
    const class_name = "SillyEngineWindow\x00";

    var wc: WNDCLASSEXA = .{
        .hInstance = hInstance,
        .lpfnWndProc = wndProc,
        .lpszClassName = @ptrCast(class_name.ptr),
    };
    _ = RegisterClassExA(&wc);

    const hwnd = CreateWindowExA(
        0,
        @ptrCast(class_name.ptr),
        "Silly Engine - GUI Demo\x00".ptr,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        WIDTH + 16,
        HEIGHT + 39,
        null,
        null,
        hInstance,
        null,
    ) orelse return error.WindowCreationFailed;

    g_hwnd = hwnd;

    // Create DIB section for the pixel buffer
    const hdc_screen = GetDC(hwnd);
    var bmi: BITMAPINFO = .{
        .bmiHeader = .{
            .biWidth = WIDTH,
            .biHeight = -@as(i32, HEIGHT), // top-down
        },
    };
    var ppvBits: ?*anyopaque = null;
    const hbitmap = CreateDIBSection(hdc_screen, &bmi, DIB_RGB_COLORS, &ppvBits, null, 0) orelse return error.DIBFailed;
    g_hbitmap = hbitmap;
    g_bits = ppvBits;

    // Copy rendered buffer to DIB
    if (ppvBits) |bits| {
        const dest: [*]u8 = @ptrCast(bits);
        @memcpy(dest[0..buffer_size], buffer);
    }

    // Create memory DC
    const mem_dc = CreateCompatibleDC(hdc_screen) orelse return error.DCFailed;
    g_hdc_mem = mem_dc;
    _ = SelectObject(mem_dc, hbitmap);

    _ = ReleaseDC(hwnd, hdc_screen);

    // Message loop
    var msg: MSG = undefined;
    while (GetMessageA(&msg, null, 0, 0) != 0) {
        _ = TranslateMessage(&msg);
        _ = DispatchMessageA(&msg);
    }
}
