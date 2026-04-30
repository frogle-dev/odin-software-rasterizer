package rasterizer

ImageView :: struct
{
	pixels: [^]Col4_ub,
	width, height: i32,
}

pixel_at :: proc(imageView: ImageView, x, y: i32) -> ^Col4_ub
{
	return &imageView.pixels[x + y * imageView.width]
}
