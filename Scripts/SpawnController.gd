class_name SpawnController
extends Node

@export var container : Node2D
@export var spawn_position_node_2d : Node2D
@export var spawn_piece : PackedScene
@export var spawn_piece_list : Array[MetalPiece]
@export var spawn_cooldown : float = 0.0

@onready var _spawn_position = spawn_position_node_2d.position

var _spawn_queue : Array[MetalPiece]
var _dequeuing : bool = false

func spawn():
	var metal_piece = spawn_piece_list.pick_random()
	_spawn_metal_piece(metal_piece)

func _spawn_metal_piece(metal_piece : MetalPiece):
	var piece_instance = spawn_piece.instantiate()
	if not piece_instance is MetalPiece2D:
		return
	piece_instance.starting_metal_piece = metal_piece
	piece_instance.position = _spawn_position
	container.call_deferred("add_child", piece_instance)

func _dequeue_metal_pieces():
	if _dequeuing:
		return
	_dequeuing = true
	while(_spawn_queue.size() > 0):
		var metal_piece = _spawn_queue.pop_front()
		_spawn_metal_piece(metal_piece)
		await(get_tree().create_timer(spawn_cooldown, false).timeout)
	_dequeuing = false

func spawn_metal_piece(metal_piece : MetalPiece):
	_spawn_queue.append(metal_piece)
	_dequeue_metal_pieces()
