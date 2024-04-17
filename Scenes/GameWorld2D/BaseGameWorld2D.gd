class_name GameWorld2D
extends Node2D

signal money_updated(new_value : int)
signal day_progress_updated(new_value : float)
signal day_count_updated(new_value : int)
signal day_ended()

@export var starting_money : int = 0
@export var day_length : float = 60.0
@export var daily_rent_due : int = 0

var day_progress : float = 0.0 :
	set(value):
		day_progress = value
		day_progress_updated.emit(day_progress)

var day_count : int = 0 : 
	set(value):
		day_count = value
		day_count_updated.emit(day_count)
		

@onready var money : int = starting_money :
	set(value):
		money = value
		money_updated.emit(money)

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		$SpawnController.spawn()


func _on_trade_controller_piece_sold(value):
	money += value

func start_day():
	day_count += 1
	$DayTimer.start(day_length)

func _end_day():
	day_ended.emit()

func _process(delta):
	var time_passed : float = day_length - $DayTimer.time_left
	day_progress = time_passed / day_length

func _on_day_timer_timeout():
	_end_day()
