extends HBoxContainer
@onready var name_label = $listaJugadores/nombreJugador
@onready var coins_label = $listaJugadores/monedasJugador
@onready var ifluence_containet = $cartasInfluencia
@onready var challenge_button = $ActionButtons/ChallengeButton
@onready var pass_button = $ActionButtons/PassButton
@onready var block_button = $ActionButtons/BlockButton

var player_data = null
var player_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	challenge_button.connect("pressed", Callable(self, "_on_ChallengeButton_pressed"))
	pass_button.connect("pressed", Callable(self, "_on_PassButton_pressed"))
	block_button.connect("pressed", Callable(self, "_on_BlockButton_pressed"))
	
func update_info(data: Dictionary, index: int):
	player_data = data
	player_index = index
	
	self.modulate = Color.RED if data.name == GameData.get_current_player().name else Color.WHITE
	self.visible = not data.is_out
	name_label.text = data.name
	coins_label.text = "Monedas: %d" % data.coins


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
