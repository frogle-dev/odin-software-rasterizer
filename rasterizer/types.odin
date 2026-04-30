package rasterizer

Col4_ub :: [4]u8

Vec4_f :: [4]f32
Vec3_f :: [3]f32
Vec2_f :: [2]f32

Mesh :: struct
{
	color: Col4_ub,
	positions: []Vec4_f,
}
