package main

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
		return
	}

	_, _, _, lastFrame := time.precise_clock_from_time(time.now())

	mouseX, mouseY: f32
	quit := false
	for !quit
	{
		for e: sdl.Event; sdl.PollEvent(&e);
		{
			#partial switch e.type
			{
				case .QUIT:
					quit = true
					break
				case .WINDOW_RESIZED:
					if (ctx.surface != nil) 
					{
						sdl.DestroySurface(ctx.surface)
						ctx.surface = nil
					}
					ctx.width = e.window.data1
					ctx.height = e.window.data2
				case .MOUSE_MOTION:
					mouseX = e.motion.x
					mouseY = e.motion.y
			}
		}
		
		_, _, _, currentFrame := time.precise_clock_from_time(time.now())

		deltaTime: f32 = f32(currentFrame - lastFrame) / 1000000000
		lastFrame = currentFrame

		// fmt.printfln("ms: %v", deltaTime)

		if (ctx.surface == nil)
		{
			ctx.surface = sdl.CreateSurface(ctx.width, ctx.height, .RGBA32)
			// sdl.SetSurfaceBlendMode(surface, .ADD)
		}

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

		rect := sdl.Rect { x = 0, y = 0, w = ctx.width, h = ctx.height, }
		sdl.BlitSurface(ctx.surface, &rect, sdl.GetWindowSurface(ctx.window), &rect)

		sdl.UpdateWindowSurface(ctx.window)
	}

	rz.quit(ctx)
}
