extends Area2D

signal evidencia_escaneada(id_da_pista)
# Esta variável aparecerá no Inspector para cada pista que você colocar no nível.
# Assim, você pode dizer qual informação cada uma delas envia para a IA HOLMES.
@export var id_da_pista: String = "pista_generica"
@onready var game_director = get_node("/root/Sala")

var player_in_range: CharacterBody2D = null

func _ready():
	modulate.a = 0.7 

func scan():
	if not game_director.pode_interagir(id_da_pista):
		print("Não posso interagir com '", id_da_pista, "' agora.")
		return # Interrompe a função aqui
	
	print("Evidência '", id_da_pista, "' foi escaneada!")
	emit_signal("evidencia_escaneada", id_da_pista)
	
	$CollisionShape2D.set_deferred("disabled", true)
	modulate.a = 0.4


func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = body
		modulate.a = 1.0

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = null
		modulate.a = 0.7
		
