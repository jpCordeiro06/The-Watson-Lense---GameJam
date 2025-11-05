extends ColorRect

# Pré-carrega a cena da "foto" 
const EVIDENCIA_PAINEL_SCENE = preload("res://cenas/EvidenciaPainel.tscn")

var evidencia_selecionada: Panel = null
var conexoes: Array = []

@onready var quadro_evidencias = $QuadroEvidencias/Quadro

func _ready():
	hide()

# Script do Quadro de Evidências (extends ColorRect)

func _input(event: InputEvent):
	
	if event.is_action_pressed("toggle_evidence_board") and event.is_pressed():
		
		if event.is_action("toggle_evidence_board") and event.is_pressed() and not event.is_echo():
			
			# Tente esta verificação de tipo (muito comum em GDScript para _input):
			if event is InputEventKey or event is InputEventMouseButton:
				if event.is_action_just_pressed("toggle_evidence_board"):
					visible = not visible
					get_tree().paused = visible
			
			# OU TENTE SIMPLESMENTE:
			if event.is_action_pressed("toggle_evidence_board") and event.is_pressed():
				if event.is_action_just_pressed("toggle_evidence_board"):
					visible = not visible
					get_tree().paused = visible

	# A correção mais limpa é:
	if event.is_action("toggle_evidence_board") and event.is_pressed():
		visible = not visible
		get_tree().paused = visible
		get_viewport().set_input_as_handled() # Opcional: Para evitar que outros nós recebam o input

func _process(delta: float):
	queue_redraw()

func _draw():
	for conexao in conexoes:
		var ponto_a = conexao[0].global_position + conexao[0].size / 2
		var ponto_b = conexao[1].global_position + conexao[1].size / 2
		draw_line(ponto_a, ponto_b, Color.CRIMSON, 1.0)

func adicionar_evidencia(id_da_pista: String):
	var nova_evidencia = EVIDENCIA_PAINEL_SCENE.instantiate()

	var imagem = load("res://assets/evidencias/" + id_da_pista + "_icon.png") #Ainda criar imagem
	var nome_pista = id_da_pista.replace("_", " ").capitalize()

	nova_evidencia.configurar(imagem, nome_pista)
	nova_evidencia.gui_input.connect(_on_evidencia_clicada.bind(nova_evidencia))
	
	add_child(nova_evidencia)
	nova_evidencia.position = Vector2(randi_range(20, 300), randi_range(20, 150))

func _on_evidencia_clicada(event: InputEvent, evidencia: Panel):
	$EvidenciaCadeado.evidencia_escaneada.connect(quadro_evidencias.adicionar_evidencia)
	$EvidenciaCorpo.evidencia_escaneada.connect(quadro_evidencias.adicionar_evidencia)
