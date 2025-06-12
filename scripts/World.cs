using Godot;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Concurrent;

[Tool]
public partial class World : Node3D
{
	[Export]
	public int WorldSize { get; set; } = 16;

	[Export]
	public PackedScene ChunkScene { get; set; }

	private ConcurrentQueue<ChunkData> _chunkQueue = new ConcurrentQueue<ChunkData>();
	private bool _isGenerating = false;

	private struct ChunkData
	{
		public Vector3 Position;
		public Chunk Chunk;
	}

	public override async void _Ready()
	{
		foreach (Node child in GetChildren())
		{
			child.QueueFree();
		}

		_isGenerating = true;

		// Queue chunks for generation
		for (int x = 0; x < WorldSize; x++)
		{
			for (int z = 0; z < WorldSize; z++)
			{
				Vector3 pos = new Vector3(x * 16, 0, z * 16);
				await QueueChunk(pos);
			}
		}

		// Process chunks in the main thread to avoid threading issues
		while (_isGenerating || !_chunkQueue.IsEmpty)
		{
			if (_chunkQueue.TryDequeue(out ChunkData chunkData))
			{
				AddChild(chunkData.Chunk);
				chunkData.Chunk.GenerateMesh();
			}
			await ToSignal(GetTree(), "process_frame");
		}

		_isGenerating = false;
	}

	private async Task QueueChunk(Vector3 pos)
	{
		Chunk chunk = (Chunk)ChunkScene.Instantiate<MeshInstance3D>();
		chunk.Position = pos;
		_chunkQueue.Enqueue(new ChunkData { Position = pos, Chunk = chunk });
	}
}
