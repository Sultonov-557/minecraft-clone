@tool
extends MeshInstance3D

var verts = PackedVector3Array()
var indices = PackedInt32Array()

var FACE_VERTICES = {
	"x+": [Vector3(1, 0, 0), Vector3(1, 0, -1), Vector3(1, 1, -1), Vector3(1, 1, 0)],
	"x-": [Vector3(0, 0, -1), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, -1)],
	"z+": [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0)],
	"z-": [Vector3(1, 0, -1), Vector3(0, 0, -1), Vector3(0, 1, -1), Vector3(1, 1, -1)],
	"y+": [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, -1), Vector3(0, 1, -1)],
	"y-": [Vector3(0, 0, -1), Vector3(1, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 0)],
}

@export var generate=false:
	set(new):
		generateMesh()
	get:
		return false

func generateMesh():
	mesh=ArrayMesh.new()
	FACE_VERTICES = {
		"x+": [Vector3(1, 0, 0), Vector3(1, 0, -1), Vector3(1, 1, -1), Vector3(1, 1, 0)],
		"x-": [Vector3(0, 0, -1), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, -1)],
		"z+": [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0)],
		"z-": [Vector3(1, 0, -1), Vector3(0, 0, -1), Vector3(0, 1, -1), Vector3(1, 1, -1)],
		"y+": [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, -1), Vector3(0, 1, -1)],
		"y-": [Vector3(0, 0, -1), Vector3(1, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 0)],
	}
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	verts = PackedVector3Array()
	indices = PackedInt32Array()
	
	add_face(Vector3(0,0,0),"x-")
	add_face(Vector3(0,0,0),"x+")
	add_face(Vector3(0,0,0),"z-")
	add_face(Vector3(0,0,0),"z+")
	add_face(Vector3(0,0,0),"y-")
	add_face(Vector3(0,0,0),"y+")
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return

func add_face(pos:Vector3, direction: String) -> void:
	var base_index = verts.size()
	var face = FACE_VERTICES.get(direction)
	if face == null:
		push_error("Invalid face direction: %s" % direction)
		return
	
	for v in face:
		verts.append(v + pos)
	
	indices.append(base_index + 2)
	indices.append(base_index + 1)
	indices.append(base_index + 0)
	indices.append(base_index + 3)
	indices.append(base_index + 2)
	indices.append(base_index + 0)
	
