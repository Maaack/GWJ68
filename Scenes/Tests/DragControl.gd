class_name DragController
extends Node

@export var container : Node2D

var held_object = null

func _ready():
	for node in container.get_children():
		if node is MetalPiece2D:
			node.clicked.connect(_on_pickable_clicked)

func _on_pickable_clicked(object):
	if !held_object:
		object.pickup()
		held_object = object

func _unhandled_input(event):
	if event.is_action_released("select") and held_object:
		held_object.drop(Input.get_last_mouse_velocity())
		held_object = null
