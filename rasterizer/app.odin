package rasterizer

import sdl "vendor:sdl3"

import "core:log"

AppCtx :: struct
{
	width, height: i32,
	window: ^sdl.Window,
	surface: ^sdl.Surface,

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

	return ctx, true
}

quit :: proc(ctx: AppCtx)
{
	sdl.DestroyWindow(ctx.window)
	sdl.Quit()

	log.destroy_console_logger(ctx.logger)
}
