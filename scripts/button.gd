extends Button

signal return_pressed

@export var button_pitch : float = 1.0
@export var sound : Resource
var id : int

func _ready():
	$ButtonSound.stream = sound
	$ButtonSound.pitch_scale = button_pitch
	


func _process(_delta):
	pass


func _on_pressed():
	$ButtonSound.play()
	return_pressed.emit(id)

func disable_buttons():
	disabled = true

func enable_buttons():
	disabled = false

func play_button_sound():
	$ButtonSound.play()
