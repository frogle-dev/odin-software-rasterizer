package rasterizer

Viewport :: struct
{
	width, height, x, y: i32,
}

ndc_to_viewport_pixel :: proc(viewport: Viewport, vec: Vec4f) -> Vec4f
{
	v: Vec4f
	v.x = f32(viewport.x) + f32(viewport.width)  * (0.5 + 0.5 * vec.x)
	v.y = f32(viewport.y) + f32(viewport.height) * (0.5 - 0.5 * vec.y)

	return v
}

ImageView :: struct
{
	pixels: [^]Col4ub,
	width, height: i32,
}

pixel_at :: proc(imageView: ImageView, x, y: i32) -> ^Col4ub
{
	return &imageView.pixels[x + y * imageView.width]
}

ViewMatrices :: struct
{
	view: Matrix4x4f,
	projection: Matrix4x4f,
}


RenderInfo :: struct
{
	viewport: Viewport,
	tex: ImageView,
	matrices: ViewMatrices,
}
