# dialogo_ui.gd 
extends PanelContainer

signal dialogo_encerrado

@onready var label_texto: RichTextLabel = $VBoxContainer/HBoxContainer/DialogoTexto
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer
@onready var timer_fechar_dialogo: Timer = $Timer 

# NOVO: Variável para guardar a análise original
var original_analise: String = ""

func _ready():
	hide() # Começa escondido

# Função para iniciar a conversa
func start_dialogue(data: Dictionary):
	# Limpa qualquer botão de conversas anteriores
	for child in choices_container.get_children():
		child.queue_free()
		
	# MUDANÇA: Guarda a análise original
	original_analise = data.get("analise_holmes", "...")
	
	# Mostra a análise inicial do HOLMES
	label_texto.text = original_analise # 
	
	# Cria os botões de opção
	for i in range(data["opcoes"].size()):
		var opcao_data = data["opcoes"][i]
		var new_button = Button.new()
		new_button.text = opcao_data["texto"] # 
		
		# Conecta o sinal 'pressed' do botão
		new_button.pressed.connect(_on_opcao_escolhida.bind(
			opcao_data["resposta_holmes"],
			new_button
		))
		
		choices_container.add_child(new_button)
	
	# Adiciona um botão "Fechar" manual
	var fechar_button = Button.new()
	fechar_button.text = "Encerrar Análise"
	fechar_button.pressed.connect(_on_timer_fechar_dialogo_timeout) 
	choices_container.add_child(fechar_button)

	show()

# MUDANÇA: Esta função agora RECONFIGURA o texto em vez de adicionar
func _on_opcao_escolhida(resposta_holmes: String, button_node: Button):
	# 1. Reseta o texto para a análise original
	label_texto.text = original_analise
	
	# 2. Adiciona APENAS a pergunta e resposta atuais
	label_texto.text += "\n\n> " + button_node.text + "\n" + resposta_holmes
	
	# 3. Desativa o botão que foi clicado
	button_node.disabled = true

# Mostra uma resposta única (usado pelo Cadeado ou outras interações).
func mostrar_dialogo(texto_resposta: String):
	for child in choices_container.get_children():
		child.queue_free()
	
	label_texto.text = texto_resposta
	
	var fechar_button = Button.new()
	fechar_button.text = "Entendido"
	fechar_button.pressed.connect(_on_timer_fechar_dialogo_timeout)
	choices_container.add_child(fechar_button)
	
	show() 

# Função chamada quando o timer termina OU o botão "Fechar" é pressionado
func _on_timer_fechar_dialogo_timeout():
	hide()
	# Limpa a análise original para a próxima interação
	original_analise = "" 
	emit_signal("dialogo_encerrado")
