package rasterizer

import sdl "vendor:sdl3"

import "core:log"
import "core:time"

AppCtx :: struct
{
	width, height: i32,
	window: ^sdl.Window,
	surface: ^sdl.Surface,

	mouseX, mouseY: f32,
	quit: bool,

	lastFrame: int,
	deltaTime: f32,

	logger: log.Logger,
}

init :: proc(width, height: i32) -> (ctx: AppCtx, ok: bool)
{
	ctx.width = width
	ctx.height = height

	ctx.logger = log.create_console_logger()
	context.logger = ctx.logger

	if !sdl.SetAppMetadata("HelloOdin", "1.0", "HelloOdin")
	{
		log.info("Failed to initialize sdl3 app metadata")
		return ctx, false
	}

	if !sdl.Init({})
	{
		log.info("Failed to initialize sdl3")
		return ctx, false
	}
	
	ctx.window = sdl.CreateWindow("HelloOdin", ctx.width, ctx.height, {.RESIZABLE})
	if ctx.window == nil
	{
		log.info("Failed to create window")
		return ctx, false
	}

	_, _, _, ctx.lastFrame = time.precise_clock_from_time(time.now())

	return ctx, true
}

handle_events :: proc(ctx: ^AppCtx)
{
	for e: sdl.Event; sdl.PollEvent(&e);
	{
		#partial switch e.type
		{
			case .QUIT:
				ctx.quit = true
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
				ctx.mouseX = e.motion.x
				ctx.mouseY = e.motion.y
		}
	}
}

enter_frame :: proc(ctx: ^AppCtx)
{
	_, _, _, currentFrame := time.precise_clock_from_time(time.now())

	ctx.deltaTime = f32(currentFrame - ctx.lastFrame) / 1000000000
	ctx.lastFrame = currentFrame

	// fmt.printfln("ms: %v", deltaTime)

	if (ctx.surface == nil)
	{
		ctx.surface = sdl.CreateSurface(ctx.width, ctx.height, .RGBA32)
		// sdl.SetSurfaceBlendMode(surface, .ADD)
	}
}

exit_frame :: proc(ctx: AppCtx)
{
	rect := sdl.Rect { x = 0, y = 0, w = ctx.width, h = ctx.height, }
	sdl.BlitSurface(ctx.surface, &rect, sdl.GetWindowSurface(ctx.window), &rect)

	sdl.UpdateWindowSurface(ctx.window)
}

quit :: proc(ctx: AppCtx)
{
	sdl.DestroyWindow(ctx.window)
	sdl.Quit()

	log.destroy_console_logger(ctx.logger)
}
