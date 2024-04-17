class_name DragController
extends Node

@export var container : Node2D
@export var throw_mod : float = 1.0

var held_object = null

func _ready():
	for node in container.get_children():
		_catch_clicked_signal(node)
	if not container.child_entered_tree.is_connected(_catch_clicked_signal):
		container.child_entered_tree.connect(_catch_clicked_signal)

func _catch_clicked_signal(node):
	if node is MetalPiece2D:
		if not node.clicked.is_connected(_on_pickable_clicked):
			node.clicked.connect(_on_pickable_clicked)

func _on_pickable_clicked(object):
	if !held_object:
		object.pickup()
		held_object = object

func _unhandled_input(event):
	if event.is_action_released("select") and held_object:
		if is_instance_valid(held_object) and held_object is MetalPiece2D:
			held_object.drop(Input.get_last_mouse_velocity() * throw_mod)
		held_object = null
