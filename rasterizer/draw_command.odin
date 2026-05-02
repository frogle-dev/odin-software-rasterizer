package rasterizer

DrawCall :: struct
{
	mesh: Mesh,
	cullMode: CullMode,
	transform: Matrix4x4f,
}
