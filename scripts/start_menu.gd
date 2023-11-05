extends Control
@export_file var game_scene_path
var game_scene


func _ready():
	game_scene = load(game_scene_path)
	pass


func _process(_delta):
	pass


func _on_start_game_pressed():
	$ButtonSound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(game_scene)


func _on_exit_game_pressed():
	$ButtonSound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
