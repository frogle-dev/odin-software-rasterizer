package rasterizer

import "core:mem"

Attribute :: struct($T: typeid)
{
	data: ^[]T,
	// stride: uint,
}

// idx_attr :: proc(idx: uint, attr: Attribute($T)) -> ^T
// {
// 	return mem.ptr_offset(attr.data, attr.stride * idx)
// }
