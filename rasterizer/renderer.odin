package rasterizer

import lalg "core:math/linalg"
import "core:fmt"

clear_pixels :: proc(view: ^ImageView, color: Col4ub)
{
	for i in 0..< view.width * view.height
	{
		view.pixels[i] = color
	}
}

draw :: proc(view: ImageView, call: DrawCall)
{
	for vertIdx := uint(0); vertIdx + 2 < call.mesh.vertexCount; vertIdx += 3
	{
		// v0 := call.transform * idx_attr(vertIdx + 0, call.mesh.positions)^
		// v1 := call.transform * idx_attr(vertIdx + 1, call.mesh.positions)^
		// v2 := call.transform * idx_attr(vertIdx + 2, call.mesh.positions)^
		//
		// c0: Vec4f = idx_attr(vertIdx + 0, call.mesh.colors)^
		// c1: Vec4f = idx_attr(vertIdx + 1, call.mesh.colors)^
		// c2: Vec4f = idx_attr(vertIdx + 2, call.mesh.colors)^

		v0 := call.transform * call.mesh.positions.data[vertIdx + 0]
		v1 := call.transform * call.mesh.positions.data[vertIdx + 1]
		v2 := call.transform * call.mesh.positions.data[vertIdx + 2]

		c0 := call.mesh.colors.data[vertIdx + 0]
		c1 := call.mesh.colors.data[vertIdx + 1]
		c2 := call.mesh.colors.data[vertIdx + 2]

		mat := matrix[2,2]f32 {
			v1.x - v0.x, v1.y - v0.y,
			v2.x - v0.x, v2.y - v0.y,
		}

		det012: f32 = lalg.determinant(mat)

		ccw := det012 < 0

		switch call.cullMode
		{
			case .CW:
				if (!ccw)
				{
					continue
				}
			case .CCW:
				if (ccw)
				{
					continue
				}
			case .NONE:
				// Dont cull anything
		}

		if (ccw)
		{
			v1, v2 = v2, v1
			det012 = -det012
		}

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
				point := Vec4f{f32(x) + 0.5, f32(y) + 0.5, 0, 0}

				mat = {
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
					l0: f32 = det12point / det012
					l1: f32 = det20point / det012
					l2: f32 = det01point / det012

					pixel_at(view, x, y)^ = to_Col4ub(l0 * c0 + l1 * c1 + l2 * c2)
				}
			}
		}
	}
}
