class_name SzeneTransitioner extends Control

signal revealDone
signal hideDone
# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.visible = false

func revealLevel():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	revealDone.emit()

func hideLevel():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	hideDone.emit()
