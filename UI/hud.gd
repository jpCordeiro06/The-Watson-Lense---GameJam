# HUD.gd
extends CanvasLayer

@onready var btn_quadro: Button = $MarginContainer/HBoxContainer/BtnQuadroEvidencias

func _ready():
	# Conectar o botão
	if btn_quadro:
		btn_quadro.pressed.connect(_on_btn_quadro_evidencias_pressed)
	else:
		print("AVISO: Botão do quadro não encontrado no HUD!")

func _on_btn_quadro_evidencias_pressed() -> void:
	print("Botão EVIDÊNCIAS clicado!")
	
	QuadroEvidencias.toggle()
