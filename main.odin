package main

import "core:container/handle_map"
import rz "rasterizer"

import "core:fmt"
import "core:time"
import "core:log"
import sdl "vendor:sdl3"

main :: proc()
{
	ctx, ok := rz.init(640, 480)
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
			pixels = cast([^]rz.Col4_ub)ctx.surface.pixels,
			width  = ctx.width,
			height = ctx.height,
		}

		rz.clear_pixels(&colorBuffer, {255, 255, 255, 255})

		vertices := []rz.Vec4_f {
			{100, 100, 0, 0},
			{200, 100, 0, 0},
			{100, 200, 0, 0},
		}

		rz.draw(colorBuffer, {
			mesh = {
				positions = vertices,
				color = {0, 200, 200, 255}
			}
		})
		
		rz.exit_frame(ctx)
	}

	rz.quit(ctx)
}
