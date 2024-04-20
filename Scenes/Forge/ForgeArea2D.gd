@tool
class_name ForgeArea2D
extends Area2D

@export var forge_temperature : float = 1000.0
@export var radius : float = 10 :
	set(value):
		radius = value
		_update_collision_area()
		_update_gradient()
@export var enabled : bool = true :
	set(value):
		enabled = value
		if is_inside_tree():
			if enabled:
				%AnimationPlayer.play("ForgeOn")
			else:
				%AnimationPlayer.play_backwards("ForgeOn")
			%ForgeFireParticles2D.emitting = enabled
			monitoring = enabled
@export_group("Extras")
@export var heat_ramp : Curve
@export var forge_texture : GradientTexture2D
@export var heat_refresh_time : float = 0.25

var heating_pieces : Array[MetalPiece2D]

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

func _get_ambient_temperature_for_piece(piece : MetalPiece2D):
	var relative_distance = global_position.distance_to(piece.global_position)
	var distance_ratio = clamp(relative_distance / radius, 0, 1)
	var heat_ratio = heat_ramp.sample(distance_ratio)
	return heat_ratio * forge_temperature

func _update_ambient_temperature_on_piece(piece : MetalPiece2D):
	piece.heat_controller.ambient_temperature = _get_ambient_temperature_for_piece(piece)

func _start_heat_refresh_loop(piece : MetalPiece2D):
	if heat_refresh_time <= 0:
		return
	while(is_instance_valid(piece) and piece in heating_pieces):
		_update_ambient_temperature_on_piece(piece)
		await(get_tree().create_timer(heat_refresh_time).timeout)

func _add_heat_piece(object):
	if object is MetalPiece2D:
		heating_pieces.append(object)
		_start_heat_refresh_loop(object)
		
func _remove_heat_piece(object):
	if object is MetalPiece2D and object in heating_pieces:
		heating_pieces.erase(object)
		object.heat_controller.ambient_temperature = 0

func _ready():
	enabled = enabled
	if not body_entered.is_connected(_add_heat_piece):
		body_entered.connect(_add_heat_piece)
	if not body_exited.is_connected(_remove_heat_piece):
		body_exited.connect(_remove_heat_piece)

