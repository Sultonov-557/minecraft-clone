using System.Collections.Generic;
using Godot;

[Tool]
public partial class Chunk : MeshInstance3D
{
	private int[,,] voxelMap;
	[Export] private FastNoiseLite noise = new FastNoiseLite();

	private List<Vector3> verts = new List<Vector3>();
	private List<int> indices = new List<int>();

	private Dictionary<string, Vector3[]> FACE_VERTICES = new Dictionary<string, Vector3[]>
	{
		{"x+", new Vector3[] {new Vector3(1, 0, 0), new Vector3(1, 0, -1), new Vector3(1, 1, -1), new Vector3(1, 1, 0)}},
		{"x-", new Vector3[] {new Vector3(0, 0, -1), new Vector3(0, 0, 0), new Vector3(0, 1, 0), new Vector3(0, 1, -1)}},
		{"z+", new Vector3[] {new Vector3(0, 0, 0), new Vector3(1, 0, 0), new Vector3(1, 1, 0), new Vector3(0, 1, 0)}},
		{"z-", new Vector3[] {new Vector3(1, 0, -1), new Vector3(0, 0, -1), new Vector3(0, 1, -1), new Vector3(1, 1, -1)}},
		{"y+", new Vector3[] {new Vector3(0, 1, 0), new Vector3(1, 1, 0), new Vector3(1, 1, -1), new Vector3(0, 1, -1)}},
		{"y-", new Vector3[] {new Vector3(0, 0, -1), new Vector3(1, 0, -1), new Vector3(1, 0, 0), new Vector3(0, 0, 0)}}
	};

	public void GenerateWorld()
	{
		voxelMap = new int[16, 64, 16];
		for (int x = 0; x < 16; x++)
		{
			for (int y = 0; y < 64; y++)
			{
				for (int z = 0; z < 16; z++)
				{
					float h = noise.GetNoise2D(GlobalPosition.X + x, GlobalPosition.Z + z);
					voxelMap[x, y, z] = 1;
					if ((h * 40) + 20 < y)
					{
						voxelMap[x, y, z] = 0;
					}
				}
			}
		}
	}

	public void GenerateMesh()
	{
		Mesh = new ArrayMesh();

		Godot.Collections.Array surfaceArray = new Godot.Collections.Array();
		surfaceArray.Resize((int)Mesh.ArrayType.Max);

		verts = new List<Vector3>();
		indices = new List<int>();

		GenerateWorld();

		for (int x = 0; x < 16; x++)
		{
			for (int y = 0; y < 64; y++)
			{
				for (int z = 0; z < 16; z++)
				{
					if (voxelMap[x, y, z] == 1)
					{
						if (x == 15 || voxelMap[x + 1, y, z] == 0) AddFace(new Vector3(x, y, z), "x+");
						if (x == 0 || voxelMap[x - 1, y, z] == 0) AddFace(new Vector3(x, y, z), "x-");
						if (z == 15 || voxelMap[x, y, z + 1] == 0) AddFace(new Vector3(x, y, z), "z+");
						if (z == 0 || voxelMap[x, y, z - 1] == 0) AddFace(new Vector3(x, y, z), "z-");
						if (y == 63 || voxelMap[x, y + 1, z] == 0) AddFace(new Vector3(x, y, z), "y+");
						if (y == 0 || voxelMap[x, y - 1, z] == 0) AddFace(new Vector3(x, y, z), "y-");
					}
				}
			}
		}

		surfaceArray[(int)Mesh.ArrayType.Vertex] = verts.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Index] = indices.ToArray();

		((ArrayMesh)Mesh).AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, surfaceArray);
	}

	private void AddFace(Vector3 pos, string direction)
	{
		int baseIndex = verts.Count;

		if (!FACE_VERTICES.ContainsKey(direction))
		{
			GD.PushError($"Invalid face direction: {direction}");
			return;
		}

		foreach (Vector3 v in FACE_VERTICES[direction])
		{
			verts.Add(v + pos);
		}

		indices.Add(baseIndex + 2);
		indices.Add(baseIndex + 1);
		indices.Add(baseIndex + 0);
		indices.Add(baseIndex + 3);
		indices.Add(baseIndex + 2);
		indices.Add(baseIndex + 0);
	}
}
