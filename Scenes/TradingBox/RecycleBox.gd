class_name RecycleBox
extends Node2D


signal pieces_recycled(metal_pieces : Array[MetalPiece])
@export var recovered_piece : MetalPiece
@export var sparks_per_mass : int = 8
@onready var recycling_particles_2ds : Array[GPUParticles2D] = [%RecyclingParticles2D, %RecyclingParticles2D2]

func _show_sparks(mass_recycled : int):
	for particles_2d in recycling_particles_2ds:
		particles_2d.amount = mass_recycled * sparks_per_mass
		particles_2d.emitting = true
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
		_recover_pieces(round(object.mass))
		object.queue_free()

func _on_particle_emitting_timer_timeout():
	for particles_2d in recycling_particles_2ds:
		particles_2d.emitting = false

func _on_recycle_area_2d_body_entered(body):
	_recycle_piece(body)
