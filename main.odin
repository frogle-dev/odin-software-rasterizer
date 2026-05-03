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
	ctx, ok := rz.init(720, 720)
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

		viewport := rz.Viewport {
			xMin = 0,
			yMin = 0,
			xMax = colorBuffer.width,
			yMax = colorBuffer.height,
		}

		rz.clear_pixels(&colorBuffer, {255, 255, 255, 255})

		pos := []rz.Vec4f {
			{ 0.5, -0.5,  0.0, 1},
			{ 0.5,  0.5,  0.0, 1},
			{-0.5,  0.5,  0.0, 1},
			{-0.5, -0.5,  0.0, 1},
		}

		indices := []int {
			0, 1, 2,
			0, 2, 3,
		}

		colors := []rz.Vec4f {
			{1, 0, 0, 1},
			{0, 1, 0, 1},
			{0, 0, 1, 1},
			{0, 0, 0, 1},
		}

		rz.draw(colorBuffer, viewport, {
			mesh = {
				positions 	= {data = &pos},
				colors 		= {data = &colors},
				vertexCount = len(pos),
				indices 	= indices,
			},
			cullMode = .NONE,
			transform = lalg.MATRIX4F32_IDENTITY,
		})
		
		rz.exit_frame(ctx)
	}

	rz.quit(ctx)
}
