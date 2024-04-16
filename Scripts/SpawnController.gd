class_name SpawnController
extends Node

@export var container : Node2D
@export var spawn_position_node_2d : Node2D
@export var spawn_piece : PackedScene

@onready var _spawn_position = spawn_position_node_2d.position

func spawn():
	var piece_instance = spawn_piece.instantiate()
	piece_instance.position = _spawn_position
	container.call_deferred("add_child", piece_instance)
