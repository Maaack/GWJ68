class_name GameWorld2D
extends Node2D

signal money_updated(new_value : int)
signal day_progress_updated(new_value : float)
signal day_count_updated(new_value : int)
signal day_ended()

@export var starting_money : int = 0
@export var day_length : float = 60.0
@export var has_shop : bool = true
@export var daily_rent_due : int = 0

@onready var drag_controller : DragController = $DragController
@onready var forge_controller : ForgeController = $ForgeController

var day_progress : float = 0.0 :
	set(value):
		day_progress = value
		day_progress_updated.emit(day_progress)

var day_count : int = 0 : 
	set(value):
		day_count = value
		day_count_updated.emit(day_count)
		

var money : int :
	set(value):
		money = value
		money_updated.emit(money)

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		$SpawnController.spawn()

func spawn_metal_piece(metal_piece : MetalPiece):
	$SpawnController.spawn_metal_piece(metal_piece)

func earn_money(money_earned : int):
	money += money_earned

func _on_trade_controller_piece_sold(value):
	money += value

func start_day():
	day_count += 1
	$DayTimer.start(day_length)
	forge_controller.enabled = true

func _end_day():
	forge_controller.enabled = false
	drag_controller.drop()
	day_ended.emit()

func _process(delta):
	var time_passed : float = day_length - $DayTimer.time_left
	day_progress = time_passed / day_length

func _on_day_timer_timeout():
	_end_day()

func _ready():
	money = starting_money

