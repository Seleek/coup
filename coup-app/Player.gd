extends HBoxContainer
@onready var name_label = $listaJugadores/nombreJugador
@onready var coins_label = $listaJugadores/monedasJugador
@onready var influence_container = $cartasInfluencia
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
	
	for i in range (GameData.MAX_INFLUENCE):
		var card_node = influence_container.get_child(i)
		
		if i < data.influence.size():
			card_node.visible = true
			var card_name = data.influence[i] if player_index == GameData.current_player_index else "INFLUENCIA"
			card_node.get_node("nombreJugador").text = card_name
		else:
			card_node.visible = false
			
	challenge_button.visible = false
	pass_button.visible = false
	block_button.visible = false
	
	if GameData.current_game_state == GameData.GameState.WAITING_FOR_CHALLENGE:
		if player_index != GameData.current_player_index and not data.is_out:
			challenge_button.visible = true
			pass_button.visible = true
			
	if GameData.current_game_state == GameData.GameState.WAITING_FOR_BLOCK:
		if player_index != GameData.active_action.actor_index and not data.is_out:
			block_button.visible = true
			pass_button.visible = true
			
	if GameData.current_game_state == GameData.GameState.WAITING_FOR_ACTION:
		if data.coins >= 10:
			pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_challenge_button_pressed():
	if GameData.current_game_state == GameData.GameState.WAITING_FOR_CHALLENGE:
		GameData.player_response(player_index, "CHALLENGE")
		
	elif GameData.current_game_state == GameData.GameState.WAITING_FOR_BLOCK_CHALLENGE:
		if player_index == GameData.active_action.actor_index:
			GameData.player_response(GameData.active_action.blocker_index, "CHALLENGE_BLOCK_RESPONSE", "CHALLENGE")

func _on_pass_button_pressed():
	GameData.player_response(player_index, "PASS")


func _on_block_button_pressed():
	if GameData.active_action.name == "Ayuda Externa":
		GameData.player_response(player_index, "BLOCK", "Duque")
	else:
		pass
	
