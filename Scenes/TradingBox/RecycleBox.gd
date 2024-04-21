class_name RecycleBox
extends Node2D


signal pieces_recycled(metal_pieces : Array[MetalPiece])
@export var recovered_piece : MetalPiece
@export var sparks_per_mass : int = 8
@export var resting_spark_ratio : float = 0.1 :
	set(value):
		resting_spark_ratio = value
		for particles_2d in recycling_particles_2ds:
			particles_2d.amount_ratio = resting_spark_ratio
@onready var recycling_particles_2ds : Array[GPUParticles2D] = [%RecyclingParticles2D, %RecyclingParticles2D2]
@onready var recycle_stream_player : AudioStreamPlayer2D = $RecycleStreamPlayer2D

func _show_sparks(mass_recycled : int):
	for particles_2d in recycling_particles_2ds:
		particles_2d.amount_ratio = clampf(float(mass_recycled * sparks_per_mass) / particles_2d.amount, 0, 1)
	$ParticleEmittingTimer.start()

func _recover_pieces(count : int):
	var metal_pieces : Array[MetalPiece] = []
	for i in range(count):
		metal_pieces.append(recovered_piece)
	pieces_recycled.emit(metal_pieces)
	_show_sparks(count)


func _recycle_piece(object):
	if object is MetalPiece2D :
		if object.scored:
			return
		object.drop()
		recycle_stream_player.play()
		_recover_pieces(round(object.mass))
		object.queue_free()

func _on_particle_emitting_timer_timeout():
	for particles_2d in recycling_particles_2ds:
		particles_2d.amount_ratio = resting_spark_ratio

func _on_recycle_area_2d_body_entered(body):
	_recycle_piece(body)

func _ready():
	resting_spark_ratio = resting_spark_ratio
