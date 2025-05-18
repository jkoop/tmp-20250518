const std = @import("std");
const ws = @import("websocket");

var allocator: std.mem.Allocator = undefined;
var connections: std.ArrayList(*Connection) = undefined;
var connections_mutex: std.Thread.Mutex = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    allocator = gpa.allocator();

    connections = .init(allocator);
    connections_mutex = .{};

    var server = try ws.Server(Connection).init(allocator, .{
        .port = 8080,
        .address = "0.0.0.0",
        .handshake = .{
            .timeout = 3,
            .max_size = 1024,
            .max_headers = 0,
        },
    });

    const ctx: struct {} = .{};

    // this blocks
    try server.listen(ctx);
}

pub const Connection = struct {
    ws_connection: *ws.Conn,

    pub fn init(_: anytype, conn: *ws.Conn, _: anytype) !@This() {
        var connection = @This(){
            .ws_connection = conn,
        };

        {
            connections_mutex.lock();
            defer connections_mutex.unlock();
            try connections.append(&connection);
        }

        return connection;
    }

    pub fn close(self: *@This()) void {
        _ = self;
        // not used in this example
    }

    pub fn clientMessage(self: *@This(), data: []const u8) !void {
        _ = self;
        _ = data;

        connections_mutex.lock();
        defer connections_mutex.unlock();

        for (connections.items) |connection| {
            try connection.ws_connection.write("Hi!");
        }
    }
};
