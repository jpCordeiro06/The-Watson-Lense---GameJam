# CadeadoInterativo.gd
extends Area2D

signal evidencia_escaneada(id_da_pista)

@export var id_da_pista: String = "cadeado_quarto"

var player_in_range: CharacterBody2D = null

func _ready():
	modulate.a = 0.7

func scan():
	print("Cadeado '", id_da_pista, "' foi escaneado!")
	
	emit_signal("evidencia_escaneada", id_da_pista)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = body
		modulate.a = 1.0

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = null
		modulate.a = 0.7
