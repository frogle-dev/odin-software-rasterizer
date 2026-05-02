package rasterizer

ImageView :: struct
{
	pixels: [^]Col4ub,
	width, height: i32,
}

pixel_at :: proc(imageView: ImageView, x, y: i32) -> ^Col4ub
{
	return &imageView.pixels[x + y * imageView.width]
}
