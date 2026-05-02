package rasterizer

import lalg "core:math/linalg"

Col4ub :: [4]u8

Vec4f :: lalg.Vector4f32
Vec3f :: lalg.Vector3f32
Vec2f :: lalg.Vector2f32

Matrix4x4f :: lalg.Matrix4f32

to_Col4ub :: proc(color: Vec4f) -> Col4ub
{
	result: Col4ub

	result.r = u8(max(0, min(255, color.r * 255)))
	result.g = u8(max(0, min(255, color.g * 255)))
	result.b = u8(max(0, min(255, color.b * 255)))
	result.a = u8(max(0, min(255, color.a * 255)))

	return result
}
