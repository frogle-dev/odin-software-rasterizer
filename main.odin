package main

import "core:container/handle_map"
import rz "rasterizer"

import "core:fmt"
import "core:time"
import "core:log"
import lalg "core:math/linalg"
import sdl "vendor:sdl3"

main :: proc()
{
	ctx, ok := rz.init(1280, 720)
	if !ok
	{
		log.info("Initialization failed")
		return
	}

	for !ctx.quit
	{
		rz.handle_events(&ctx)
		rz.enter_frame(&ctx)

		colorBuffer := rz.ImageView {
			pixels = cast([^]rz.Col4ub)ctx.surface.pixels,
			width  = ctx.width,
			height = ctx.height,
		}

		rz.clear_pixels(&colorBuffer, {255, 255, 255, 255})

		pos := []rz.Vec4f {
			{0,   0,   0, 1},
			{100, 0,   0, 1},
			{0  , 100, 0, 1},
		}

		colors := []rz.Vec4f {
			{1, 0, 0, 1},
			{0, 1, 0, 1},
			{0, 0, 1, 1},
		}

		for i in 0..< 100
		{
			rz.draw(colorBuffer, {
				mesh = {
					positions = {data = &pos},
					colors = {data = &colors},
					vertexCount = len(pos),
				},
				cullMode = .NONE,
				transform = lalg.matrix4_translate_f32({ctx.mouseX + 50 * f32(i % 10), ctx.mouseY + 50 * f32(i / 10), 0}) * lalg.matrix4_scale_f32({0.5, 0.5, 0.5}),
			})
		}
		
		rz.exit_frame(ctx)
	}

	rz.quit(ctx)
}
