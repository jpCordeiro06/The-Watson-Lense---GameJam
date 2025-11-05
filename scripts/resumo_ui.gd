# ResumoUI.gd
extends PanelContainer

@onready var label_texto: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var fechar_btn: Button = $VBoxContainer/Button

func _ready():
	fechar_btn.text = "Fechar"
	fechar_btn.pressed.connect(queue_free) # Se destrói ao fechar

func mostrar_resumo(texto_resumo: String):
	label_texto.text = texto_resumo
	# Centraliza o popup
	position = (get_viewport_rect().size - size) / 2
