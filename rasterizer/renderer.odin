package rasterizer

import lalg "core:math/linalg"

clear_pixels :: proc(view: ^ImageView, color: Col4_ub)
{
	for i in 0..< view.width * view.height
	{
		view.pixels[i] = color
	}
}

draw :: proc(view: ImageView, drawCall: DrawCall)
{
	for vertIdx := 0; vertIdx + 2 < len(drawCall.mesh.positions); vertIdx += 3
	{
		v0 := drawCall.mesh.positions[vertIdx + 0]
		v1 := drawCall.mesh.positions[vertIdx + 1]
		v2 := drawCall.mesh.positions[vertIdx + 2]

		xMin := min(i32(v0.x), i32(v1.x), i32(v2.x))
		xMax := max(i32(v0.x), i32(v1.x), i32(v2.x))
		yMin := min(i32(v0.y), i32(v1.y), i32(v2.y))
		yMax := max(i32(v0.y), i32(v1.y), i32(v2.y))

		xMin = max(0, xMin)
		xMax = min(i32(view.width) - 1, xMax)
		yMin = max(0, yMin)
		yMax = min(i32(view.height) - 1, yMax)

		for y in yMin..= yMax
		{
			for x in xMin..= xMax
			{
				point := Vec4_f{f32(x) + 0.5, f32(y) + 0.5, 0, 0}

				mat := matrix[2,2]f32 {
					v1.x - v0.x, v1.y - v0.y,
					point.x - v0.x, point.y - v0.y,
				}
				
				det01point: f32 = lalg.determinant(mat)

				mat = {
					v2.x - v1.x, v2.y - v1.y,
					point.x - v1.x, point.y - v1.y,
				}

				det12point: f32 = lalg.determinant(mat)

				mat = {
					v0.x - v2.x, v0.y - v2.y,
					point.x - v2.x, point.y - v2.y,
				}

				det20point: f32 = lalg.determinant(mat)

				if det01point >= 0 && det12point >= 0 && det20point >= 0
				{
					pixel_at(view, x, y)^ = drawCall.mesh.color
				}
			}
		}
	}
}
