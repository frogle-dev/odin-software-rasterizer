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

	// if !sdl.HideCursor()
	// {
	// 	log.info("SDL3 hide cursor failed")
	// 	return
	// }

	if !sdl.SetWindowRelativeMouseMode(ctx.window, true)
	{
		log.info("SDL3 cursor locking failed")
		return
	}

	cam: rz.Camera
	cam.sensitivity = 0.1
	cam.pos = {0, 0, 3}
	cam.rotation = {0, 0, 0}

	rotation: f32 = 0
	for !ctx.quit
	{
		if !rz.handle_events(&ctx)
		{
			log.info("Event handling failed")
			return
		}
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
			0, 2, 1,  0, 3, 2,
			// Back   (-Z)
			4, 5, 6,  4, 6, 7,
			// Right  (+X)
			4, 1, 5,  4, 0, 1,
			// Left   (-X)
			3, 6, 2,  3, 7, 6,
			// Top    (+Y)
			1, 6, 5,  1, 2, 6,
			// Bottom (-Y)
			4, 3, 0,  4, 7, 3,
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
			direction -= cam.right
		}
		if rz.get_key_pressed(.D)
		{
			direction += cam.right
		}
		if rz.get_key_pressed(.W)
		{
			direction += cam.straightForward
		}
		if rz.get_key_pressed(.S)
		{
			direction -= cam.straightForward
		}
		cam.pos += direction * speed * ctx.deltaTime

		rz.camera_look(&cam, ctx)

		viewMatrices := rz.ViewMatrices {
			view = cam.view,
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
