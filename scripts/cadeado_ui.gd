extends PanelContainer

signal codigo_inserido(codigo)

# Referências aos 4 VSliders (rodas do cadeado)
@onready var roda1: VSlider = $VBoxContainer/HBoxContainer/Roda1
@onready var roda2: VSlider = $VBoxContainer/HBoxContainer/Roda2
@onready var roda3: VSlider = $VBoxContainer/HBoxContainer/Roda3
@onready var roda4: VSlider = $VBoxContainer/HBoxContainer/Roda4

# Labels que mostram o número atual de cada roda
@onready var label1: Label = $VBoxContainer/HBoxContainer/Roda1/Label
@onready var label2: Label = $VBoxContainer/HBoxContainer/Roda2/Label
@onready var label3: Label = $VBoxContainer/HBoxContainer/Roda3/Label
@onready var label4: Label = $VBoxContainer/HBoxContainer/Roda4/Label

# Botões
@onready var confirmar_btn: Button = $VBoxContainer/BotoesContainer/ConfirmarButton
@onready var resetar_btn: Button = $VBoxContainer/BotoesContainer/ResetarButton
@onready var fechar_btn: Button = $VBoxContainer/TitleBar/CloseButton

# Label de feedback
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel

# Som de clique (opcional - adicione um AudioStreamPlayer se quiser)
@onready var som_clique: AudioStreamPlayer = $SomClique if has_node("SomClique") else null

func _ready() -> void:
	print("=== DEBUG CadeadoUI ===")
	print("Roda1: ", roda1)
	print("Roda2: ", roda2)
	print("Roda3: ", roda3)
	print("Roda4: ", roda4)
	print("Label1: ", label1)
	print("Label2: ", label2)
	print("Label3: ", label3)
	print("Label4: ", label4)
	
	hide()
	
	# Configurar as rodas (VSliders)
	configurar_roda(roda1, label1)
	configurar_roda(roda2, label2)
	configurar_roda(roda3, label3)
	configurar_roda(roda4, label4)
	
	# Conectar sinais dos botões
	if confirmar_btn:
		confirmar_btn.pressed.connect(_on_confirmar_button_pressed)
	if resetar_btn:
		resetar_btn.pressed.connect(_on_resetar_button_pressed)
	if fechar_btn:
		fechar_btn.pressed.connect(_on_close_button_pressed)
	
	# Resetar para posição inicial
	resetar_rodas()
	
	print("=== CadeadoUI inicializado ===")

func _input(event):
	# Detectar clique fora da interface
	if visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Verificar se o clique foi fora do painel
		var rect = get_global_rect()
		if not rect.has_point(event.position):
			esconder()

func configurar_roda(roda: VSlider, label: Label):
	if roda == null:
		print("ERRO: Roda é null!")
		return
	
	print("Configurando roda: ", roda.name)
	
	# Configurar range do slider: 0 a 9
	roda.min_value = 0
	roda.max_value = 9
	roda.step = 1
	roda.value = 0
	
	# IMPORTANTE: Garantir que o slider é clicável
	roda.mouse_filter = Control.MOUSE_FILTER_STOP
	roda.editable = true
	
	# Conectar sinal de mudança de valor
	roda.value_changed.connect(_on_roda_changed.bind(label, roda))
	
	# Atualizar label inicial
	if label:
		label.text = str(int(roda.value))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Label não bloqueia cliques
	
	print("✓ Roda configurada: ", roda.name)

func _on_roda_changed(novo_valor: float, label: Label, roda: VSlider):
	print("=== RODA MUDOU ===")
	print("Roda: ", roda.name if roda else "null")
	print("Novo valor: ", novo_valor)
	print("Label: ", label if label else "null")
	
	# Atualizar o label com o novo número
	if label:
		label.text = str(int(novo_valor))
		print("✓ Label atualizado para: ", label.text)
	else:
		print("✗ Label é null!")
	
	# Tocar som de clique (se existir)
	if som_clique and som_clique.stream:
		som_clique.play()
	
	# Limpar feedback anterior quando mexer nas rodas
	if feedback_label:
		feedback_label.text = ""
		feedback_label.modulate = Color.WHITE

func _on_confirmar_button_pressed():
	# Pegar os valores das 4 rodas e montar o código
	var digito1 = str(int(roda1.value))
	var digito2 = str(int(roda2.value))
	var digito3 = str(int(roda3.value))
	var digito4 = str(int(roda4.value))
	
	var codigo_completo = digito1 + digito2 + digito3 + digito4
	
	print("Código tentado: ", codigo_completo)
	
	# Emitir sinal com o código
	emit_signal("codigo_inserido", codigo_completo)

func _on_resetar_button_pressed():
	resetar_rodas()
	
	if feedback_label:
		feedback_label.text = "Combinação resetada"
		feedback_label.modulate = Color.GRAY

<<<<<<< HEAD
func _on_close_button_pressed():
	esconder()

=======
=======
>>>>>>> 606d9466f94989b4894c62d6fc5c4ee5545a8079
func resetar_rodas():
	# Voltar todas as rodas para 0
	if roda1:
		roda1.value = 0
	if roda2:
		roda2.value = 0
	if roda3:
		roda3.value = 0
	if roda4:
		roda4.value = 0

func mostrar():
	show()
	resetar_rodas()
	
	# Forçar tamanho fixo
	custom_minimum_size = Vector2(250, 180)
	size = Vector2(250, 180)
	
	# FORÇAR resolução 480x270 (sua resolução configurada)
	var viewport_size = Vector2(480, 270)
	
	position = (viewport_size - size) / 2
	
	print("=== MOSTRAR CADEADO ===")
	print("Tamanho do painel: ", size)
	print("Posição: ", position)
	
	if feedback_label:
		feedback_label.text = "Gire as rodas para encontrar a combinação"
		feedback_label.modulate = Color.WHITE
	
	if confirmar_btn:
		confirmar_btn.grab_focus()
	
	# Focar no botão de confirmar para navegação por teclado
	if confirmar_btn:
		confirmar_btn.grab_focus()

func esconder():
	hide()
	
	# Despausar o jogo se estiver pausado
	if get_tree().paused:
		get_tree().paused = false

func mostrar_feedback_erro():
	if feedback_label:
		feedback_label.text = "COMBINAÇÃO INCORRETA"
		feedback_label.modulate = Color.RED

func mostrar_feedback_sucesso():
	if feedback_label:
		feedback_label.text = "CADEADO DESBLOQUEADO!"
		feedback_label.modulate = Color.GREEN


func _on_close_button_pressed() -> void:
	esconder()
