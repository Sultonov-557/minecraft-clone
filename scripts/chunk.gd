@tool
extends MeshInstance3D

var voxelMap

@export
var noice=FastNoiseLite.new()

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
		generate_mesh()
	get:
		return false

func generate_world():
	voxelMap=[]
	voxelMap.resize(16)
	for x in range(16):
		voxelMap[x]=[]
		voxelMap[x].resize(16)
		print(voxelMap)
		for y in range(16):
			voxelMap[x][y]=[]
			voxelMap[x][y].resize(16)
			for z in range(16):
				var h=noice.get_noise_2d(position.x+x,position.z+z)
				voxelMap[x][y][z]=0
				print(x*16)
				if(h*16>y):
					voxelMap[x][y][z]=1

func generate_mesh():
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
	
	generate_world()
	for x in range(0,16):
		for y in range(0,16):
			for z in range(0,16):
				if(voxelMap[x][y][z]==1):
					add_face(Vector3(x,y,z),"x+")
					add_face(Vector3(x,y,z),"x-")
					add_face(Vector3(x,y,z),"z+")
					add_face(Vector3(x,y,z),"z-")
					add_face(Vector3(x,y,z),"y+")
					add_face(Vector3(x,y,z),"y-")
	
	
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
	
