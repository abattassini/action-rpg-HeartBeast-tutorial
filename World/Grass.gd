extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	var mainScene = get_tree().current_scene
	mainScene.add_child(grassEffect)
	grassEffect.global_position = global_position
	queue_free()

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
