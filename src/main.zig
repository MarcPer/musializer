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

    var enableEffectDelay = false;

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

        // Add/Remove effect: delay
        if (raylib.IsKeyPressed(raylib.KeyboardKey.KEY_D)) {
            enableEffectDelay = !enableEffectDelay;
            if (enableEffectDelay) {
                std.debug.print("Attaching audio stream processor\n", .{});
                raylib.AttachAudioStreamProcessor(music.stream, &audioProcessEffectDelay);
            } else {
                std.debug.print("Detaching audio stream processor\n", .{});
                raylib.DetachAudioStreamProcessor(music.stream, &audioProcessEffectDelay);
            }
        }
    }
}

const delayBufferSize = 48000 * 2 * 5;
var delayBuffer: [delayBufferSize]f32 = undefined;
var delayReadIndex: u32 = 2;
var delayWriteIndex: u32 = 0;

fn audioProcessEffectDelay(rawBuffer: ?*anyopaque, frames: u32) void {
    if (rawBuffer == null) {
        std.debug.print("Error: Null buffer in audioProcessEffectDelay\n", .{});
        return;
    }

    // Cast the raw pointer to the correct type
    const bufferData: [*]f32 = @ptrCast(@alignCast(rawBuffer.?));
    std.debug.print("Processing audio effect delay. Frames: {}\n", .{frames});

    var i: usize = 0;
    while (i < frames * 2) : (i += 2) {
        if (delayReadIndex == delayBufferSize) {
            delayReadIndex = 0;
        }

        if (delayReadIndex >= delayBufferSize or delayWriteIndex >= delayBufferSize) {
            std.debug.print("Error: Index out of bounds. Read: {}, Write: {}, BufferSize: {}\n", .{ delayReadIndex, delayWriteIndex, delayBufferSize });
            return;
        }
        const leftDelay = delayBuffer[delayReadIndex];
        delayReadIndex += 1;
        const rightDelay = delayBuffer[delayReadIndex];
        delayReadIndex += 1;

        // Modify the buffer in place
        bufferData[i] = 0.5 * bufferData[i] + 0.5 * leftDelay;
        bufferData[i + 1] = 0.5 * bufferData[i + 1] + 0.5 * rightDelay;

        delayBuffer[delayWriteIndex] = bufferData[i];
        delayWriteIndex += 1;
        delayBuffer[delayWriteIndex] = bufferData[i + 1];
        delayWriteIndex += 1;
        if (delayWriteIndex == delayBufferSize) {
            delayWriteIndex = 0;
        }
    }

    std.debug.print("Finished processing audio effect delay\n", .{});
}
