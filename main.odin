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

	rz.init_input()


	cameraPosition: rz.Vec3f = {0,0,-3}
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

		pos := []rz.Vec4f{
			// Front
			{ 0.5, -0.5,  0.5, 1},  // 0
			{ 0.5,  0.5,  0.5, 1},  // 1
			{-0.5,  0.5,  0.5, 1},  // 2
			{-0.5, -0.5,  0.5, 1},  // 3
			// Back
			{ 0.5, -0.5, -0.5, 1},  // 4
			{ 0.5,  0.5, -0.5, 1},  // 5
			{-0.5,  0.5, -0.5, 1},  // 6
			{-0.5, -0.5, -0.5, 1},  // 7
		}

		indices := []int{
			// Front  (+Z)
			0, 1, 2,  0, 2, 3,
			// Back   (-Z)
			4, 6, 5,  4, 7, 6,
			// Right  (+X)
			4, 5, 1,  4, 1, 0,
			// Left   (-X)
			3, 2, 6,  3, 6, 7,
			// Top    (+Y)
			1, 5, 6,  1, 6, 2,
			// Bottom (-Y)
			4, 0, 3,  4, 3, 7,
		}

		colors := []rz.Vec4f{
			{1, 0, 0, 1},  // 0 red
			{0, 1, 0, 1},  // 1 green
			{0, 0, 1, 1},  // 2 blue
			{1, 1, 0, 1},  // 3 yellow
			{1, 0, 1, 1},  // 4 magenta
			{0, 1, 1, 1},  // 5 cyan
			{1, 1, 1, 1},  // 6 white
			{0, 0, 0, 1},  // 7 black
		}

		speed := f32(5.0)
		direction := rz.Vec3f {0, 0, 0}
		if rz.get_key_pressed(.A)
		{
			direction.x += 1
		}
		if rz.get_key_pressed(.D)
		{
			direction.x -= 1
		}
		if rz.get_key_pressed(.W)
		{
			direction.z += 1
		}
		if rz.get_key_pressed(.S)
		{
			direction.z -= 1
		}
		cameraPosition += direction * speed * ctx.deltaTime

		viewMatrices := rz.ViewMatrices {
			view = lalg.matrix4_translate_f32(cameraPosition),
			projection = lalg.matrix4_perspective_f32(lalg.to_radians(f32(45)), f32(viewport.width)/f32(viewport.height), 0.1, 100.0)
		}
		
		rotation += ctx.deltaTime
		model := lalg.matrix4_rotate_f32(rotation * 2, {1, 0, 0})

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
				cullMode = .CCW,
				transform = model,
			}
		)
		
		rz.exit_frame(ctx)
	}

	rz.quit(ctx)
}
