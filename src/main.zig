const std = @import("std");
const raylib = @import("raylib");

pub fn main() !void {
    raylib.InitAudioDevice();
    const music = raylib.LoadMusicStream("songs/p5_2.ogg");
    raylib.PlayMusicStream(music);
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(800, 800, "hello world!");
    raylib.SetTargetFPS(60);

    std.debug.print("sampleRate: {}, channels: {}\n", .{ music.stream.sampleRate, music.stream.channels });

    defer raylib.CloseWindow();

    var isPaused = false;

    raylib.AttachAudioStreamProcessor(music.stream, &storeBuffer);

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.UpdateMusicStream(music);

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        const timePlayed = raylib.GetMusicTimePlayed(music) / raylib.GetMusicTimeLength(music);

        raylib.DrawRectangle(200, 200, 400, 12, raylib.LIGHTGRAY);
        raylib.DrawRectangle(200, 200, @as(u16, @intFromFloat(timePlayed * 400.0)), 12, raylib.MAROON);
        raylib.DrawRectangleLines(200, 200, 400, 12, raylib.GRAY);

        drawBuffer();

        // Pause/Resume music
        if (raylib.IsKeyPressed(raylib.KeyboardKey.KEY_P)) {
            isPaused = !isPaused;
            if (isPaused) {
                raylib.PauseMusicStream(music);
            } else {
                raylib.ResumeMusicStream(music);
            }
        }
    }
}

const globalBufferSize = 1024;
var globalBuffer: [globalBufferSize]f32 = undefined;
var globalBufferIndex: u32 = 0;

fn storeBuffer(rawBuffer: ?*anyopaque, frames: u32) void {
    if (rawBuffer == null) {
        std.debug.print("Error: Null buffer in storeBuffer\n", .{});
        return;
    }

    std.debug.assert(frames * 2 <= globalBufferSize);

    const bufferData: [*]f32 = @ptrCast(@alignCast(rawBuffer.?));

    const spareCapacity = globalBufferSize - globalBufferIndex;

    var i: usize = 0;
    if (frames * 2 <= spareCapacity) {
        while (i < frames * 2) : (i += 2) {
            globalBuffer[globalBufferIndex] = bufferData[i];
            globalBufferIndex += 1;
        }
    } else {
        while (i < spareCapacity) : (i += 2) {
            globalBuffer[globalBufferIndex] = bufferData[i];
            globalBufferIndex += 1;
        }
        globalBufferIndex = 0;
        while (i < (frames * 2 - spareCapacity)) : (i += 2) {
            globalBuffer[globalBufferIndex] = bufferData[i];
            globalBufferIndex += 1;
        }
    }
}

fn drawBuffer() void {
    const cellWidth: f32 = @as(f32, @floatFromInt(raylib.GetScreenWidth())) / @as(f32, @floatFromInt(globalBufferSize));
    var cellIntWidth: i32 = @as(i32, @intFromFloat(cellWidth));
    if (cellIntWidth == 0) {
        cellIntWidth = 1;
    }
    const cellMaxHeight: u32 = @intCast(@divTrunc(raylib.GetScreenHeight(), 2));

    var i: usize = 0;
    while (i < globalBufferSize) : (i += 1) {
        const cellHeight: f32 = globalBuffer[i] * @as(f32, @floatFromInt(cellMaxHeight));
        const cellIntHeight: i32 = @as(i32, @intFromFloat(cellHeight));
        const positionX = @as(u16, @intFromFloat(@as(f32, @floatFromInt(i)) * cellWidth));
        raylib.DrawRectangle(positionX, 500 - cellIntHeight, cellIntWidth, cellIntHeight, raylib.RED);
    }
}
