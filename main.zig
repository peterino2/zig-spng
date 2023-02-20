const std = @import("std");
const spng = @import("spng.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
    var allocator = std.heap.c_allocator;

    var pngBuffer = try allocator.alloc(u8, 1000 * 1000 * 100);
    defer allocator.free(pngBuffer);

    var decoder = try spng.SpngContext.newDecoder();
    defer decoder.deinit();
    try decoder.setBuffer(pngBuffer);

    var decodeBuffer = try allocator.alloc(u8, 500 * 1000 * 1000);
    defer allocator.free(decodeBuffer);

    var decoder2 = try spng.SpngContext.newDecoder();
    defer decoder2.deinit();
    try decoder2.setFile("testpng.png");

    var len = try decoder2.decode(decodeBuffer, spng.SPNG_FMT_RGBA8, spng.SPNG_DECODE_TRNS);
    std.debug.print("decoded size = {d}\nheader={any}", .{ len, try decoder2.getHeader() });

    var encoder = try spng.SpngContext.newDecoder();
    defer encoder.deinit();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
