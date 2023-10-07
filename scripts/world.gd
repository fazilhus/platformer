extends Node2D

@onready var ui = $UI
@onready var menu_scene = "res://assets/scenes/menu.tscn"

@export var next_level: PackedScene

func _ready():
	Events.level_completed.connect(on_level_completed)
	Events.game_over.connect(on_game_over)


func on_level_completed():
	get_node("UI/LevelCompleted").show()
	get_node("UI/Label").visible = false
	
	get_tree().paused = true
	if next_level:
		await LevelTransition.fade_to_black()
		get_tree().paused = false
		get_tree().change_scene_to_packed(next_level)
		LevelTransition.fade_from_black()
	else:
		await LevelTransition.fade_to_black()
		get_tree().paused = false
		get_tree().change_scene_to_file(menu_scene)
		LevelTransition.fade_from_black()


func on_game_over():
	get_node("UI/GameOver").show()
	get_node("UI/Label").visible = false
	
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()
	LevelTransition.fade_from_black()
	
