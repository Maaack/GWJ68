@tool
class_name FadeOutText
extends Node2D

enum Qualities{
	PERFECT,
	EXCELLENT,
	GREAT,
	GOOD,
	OKAY,
	BAD,
	TERRIBLE,
	REJECTED
}

@export var quality : Qualities :
	set(value):
		quality = value
		if is_inside_tree():
			if quality in qualities:
				var index := qualities.find(quality)
				$Label.modulate = colors[index]
				$Label.text = texts[index] 
@export_group("Settings")
@export var colors : Array[Color]
@export var texts : Array[String]
@export var qualities : Array[Qualities]
