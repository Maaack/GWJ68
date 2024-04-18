class_name SpawnController
extends Node

@export var container : Node2D
@export var spawn_position_node_2d : Node2D
@export var spawn_piece : PackedScene
@export var spawn_piece_list : Array[MetalPiece]

@onready var _spawn_position = spawn_position_node_2d.position

func spawn():
	var metal_piece = spawn_piece_list.pick_random()
	var piece_instance = spawn_piece.instantiate()
	if not piece_instance is MetalPiece2D:
		return
	piece_instance.starting_metal_piece = metal_piece
	piece_instance.position = _spawn_position
	container.call_deferred("add_child", piece_instance)
