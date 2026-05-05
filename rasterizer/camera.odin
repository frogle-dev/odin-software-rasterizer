package rasterizer

import lalg "core:math/linalg"

Camera :: struct
{
	sensitivity: f32,

	pos: Vec3f,
	rotation: Vec3f,

	forward, right, up: Vec3f,
	straightForward: Vec3f,

	view: Matrix4x4f,
}

camera_look :: proc(cam: ^Camera, ctx: AppCtx)
{
	x, y: f32
	get_mouse_motion(&x, &y)

	cam.rotation.y += x * cam.sensitivity
	cam.rotation.x += y * cam.sensitivity
	cam.rotation.x = lalg.clamp(cam.rotation.x, -89, 89)

	quat := lalg.quaternion_from_pitch_yaw_roll_f32(lalg.to_radians(-cam.rotation.x), lalg.to_radians(-cam.rotation.y), lalg.to_radians(cam.rotation.z))

	cam.forward = lalg.quaternion128_mul_vector3(quat, Vec3f{0, 0, -1})
	cam.right 	= lalg.quaternion128_mul_vector3(quat, Vec3f{1, 0, 0})
	cam.up		= lalg.quaternion128_mul_vector3(quat, Vec3f{0, 1, 0})
	cam.straightForward = lalg.normalize(lalg.vector_cross3(Vec3f{0, 1, 0}, cam.right))
	
	cam.view = lalg.matrix4_look_at_f32(cam.pos, cam.pos + cam.forward, Vec3f{0, 1, 0})
}
