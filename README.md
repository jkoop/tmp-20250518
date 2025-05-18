A project of mine that depends on karlseguin/websocket.zig crashes when a second player successfully connects. The server crashes while compressing a message to send to one of the players (I have yet to determine which).

This is the simplest program that exibits similar behaviour. This one crashes when the _first_ "player" connects, not the second that my real project exibits, but it crashes in the same place, so maybe it's still useful??
