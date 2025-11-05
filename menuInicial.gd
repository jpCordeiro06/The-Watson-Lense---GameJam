extends Node2D

@onready var btnNovoJogo = $"Botoes/btnNovoJogo"
@onready var btnCarregar = $"Botoes/btnCarregar"
@onready var btnConfig = $Botoes/btnConfig
@onready var btnCred = $Botoes/btnCred
@onready var btnSair = $Botoes/btnSair

func _on_btn_novo_jogo_pressed():
	get_tree().change_scene_to_file("res://cenas/Instruções.tscn")

func _on_btn_carregar_pressed() -> void:
	print("Carregar")

func _on_btn_config_pressed() -> void:
	print("Config")

func _on_btn_cred_pressed():
	get_tree().change_scene_to_file("res://cenas/creditos.tscn")

func _on_btn_sair_pressed() -> void:
	get_tree().quit()
