package main

import rz "rasterizer"

import "core:fmt"
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


	rotation: f32 = 0
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
			x = 0,
			y = 0,
			width = colorBuffer.width,
			height = colorBuffer.height,
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

		viewMatrices := rz.ViewMatrices {
			view = lalg.matrix4_translate_f32({0, 0, -3}),
			projection = lalg.matrix4_perspective_f32(lalg.to_radians(f32(45)), f32(viewport.width)/f32(viewport.height), 0.1, 100.0)
		}
		
		rotation += ctx.deltaTime
		model := lalg.matrix4_rotate_f32(rotation, {1, 0, 0})

		rz.draw(
			info = {
				viewport = viewport,
				tex = colorBuffer,
				matrices = viewMatrices,
			},
			call = {
				mesh = {
					positions 	= {data = &pos},
					colors 		= {data = &colors},
					vertexCount = len(pos),
					indices 	= indices,
				},
				cullMode = .NONE,
				transform = model,
			}
		)
		
		rz.exit_frame(ctx)
	}

	rz.quit(ctx)
}
