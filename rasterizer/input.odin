package rasterizer

import sdl "vendor:sdl3"

keyStates: [^]bool
mouseButtons: sdl.MouseButtonFlags

init_input :: proc()
{
	keyStates = sdl.GetKeyboardState(nil)
}

get_key_pressed :: proc(scancode: sdl.Scancode) -> bool
{
	return keyStates[scancode]
}

get_mouse_motion :: proc(x, y: ^f32)
{
	mouseButtons = sdl.GetRelativeMouseState(x, y)
}
