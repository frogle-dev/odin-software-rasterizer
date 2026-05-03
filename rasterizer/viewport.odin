package rasterizer

Viewport :: struct
{
	xMin, xMax, yMin, yMax: i32,
}

ndc_to_viewport_pixel :: proc(viewport: Viewport, vec: Vec4f) -> Vec4f
{
	v: Vec4f
	v.x = f32(viewport.xMin) + f32(viewport.xMax - viewport.xMin) * (0.5 + 0.5 * vec.x)
	v.y = f32(viewport.yMin) + f32(viewport.yMax - viewport.yMin) * (0.5 + 0.5 * vec.y)

	return v
}
