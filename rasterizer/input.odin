package rasterizer

import sdl "vendor:sdl3"

keyStates: [^]bool

init_input :: proc()
{
	keyStates = sdl.GetKeyboardState(nil)
}

get_key_pressed :: proc(scancode: sdl.Scancode) -> bool
{
	return keyStates[scancode]
}
