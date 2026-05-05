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

draw :: proc(info: RenderInfo, call: DrawCall)
{
	// looping over all the triangles, per mesh index
	for i := uint(0); i + 2 < len(call.mesh.indices); i += 3
	{
		i0 := call.mesh.indices[i + 0]
		i1 := call.mesh.indices[i + 1]
		i2 := call.mesh.indices[i + 2]
		
		// after transformation by projection matrix, the vertices are in clip space
		v0 := info.matrices.projection * info.matrices.view * call.transform * call.mesh.positions.data[i0]
		v1 := info.matrices.projection * info.matrices.view * call.transform * call.mesh.positions.data[i1]
		v2 := info.matrices.projection * info.matrices.view * call.transform * call.mesh.positions.data[i2]

		// if vertex is behind the near plane, discard
		if v0.w <= 0 || v1.w <= 0 || v2.w <= 0
		{
			continue
		}
		
		// conversion back into NDC space
		v0.xyz /= v0.w
		v1.xyz /= v1.w
		v2.xyz /= v2.w

		v0 = ndc_to_viewport_pixel(info.viewport, v0)
		v1 = ndc_to_viewport_pixel(info.viewport, v1)
		v2 = ndc_to_viewport_pixel(info.viewport, v2)

		c0 := call.mesh.colors.data[i0]
		c1 := call.mesh.colors.data[i1]
		c2 := call.mesh.colors.data[i2]

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

		xMin := max(0, info.viewport.x)
		xMax := min(info.tex.width, info.viewport.x + info.viewport.width)
		yMin := max(0, info.viewport.y)
		yMax := min(info.tex.height, info.viewport.y + info.viewport.height)

		xMin = max(xMin, min(i32(v0.x), i32(v1.x), i32(v2.x)))
		xMax = min(xMax, max(i32(v0.x), i32(v1.x), i32(v2.x)))
		yMin = max(yMin, min(i32(v0.y), i32(v1.y), i32(v2.y)))
		yMax = min(yMax, max(i32(v0.y), i32(v1.y), i32(v2.y)))

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

					pixel_at(info.tex, x, y)^ = to_Col4ub(l0 * c0 + l1 * c1 + l2 * c2)
				}
			}
		}
	}
}
