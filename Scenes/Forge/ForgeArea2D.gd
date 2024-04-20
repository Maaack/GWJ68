@tool
extends Area2D


@export var forge_texture : GradientTexture2D

@export var radius : float = 10 :
	set(value):
		radius = value
		_update_collision_area()
		_update_gradient()

func _update_collision_area():
	if radius <= 0 or not (is_inside_tree() or Engine.is_editor_hint()):
		return
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = radius
	%CollisionShape2D.shape = circle_shape

func _update_gradient():
	if radius <= 0 or not (is_inside_tree() or Engine.is_editor_hint()):
		return
	var gradient_2d := forge_texture.duplicate()
	gradient_2d.width = radius
	gradient_2d.height = radius
	%Sprite2D.texture = gradient_2d
