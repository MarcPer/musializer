# Musializer

Visualize audio as a spectrum of colors.

Heavily based on [Tsoding's musializer](https://github.com/tsoding/musializer).

## Getting started

Setup:
```sh
git clone https://github.com/marcper/musializer.git
cd musializer
git submodule update --init --recursive
git apply patches/raylib-zig.patch
```

Run:
```sh
zig build run
```

Note: The raylib-zig library is patched to work with zig 0.13. See https://github.com/ryupold/raylib.zig/pull/46.


## References

- [Tsoding's musializer](https://github.com/tsoding/musializer)
- [Tsoding Musializer video](https://www.youtube.com/watch?v=Xdbk1Pr5WXU)
- [raylib.zig](https://github.com/ryupold/raylib.zig)
- [Audio Stream Processing](https://github.com/raysan5/raylib/blob/master/examples/audio/audio_stream_effects.c)