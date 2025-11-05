extends CanvasLayer

# Sinais
signal evidencia_inspecionada(id_evidencia: String)

# Referências de UI
@onready var painel_principal: Panel = $PainelPrincipal
@onready var btn_fechar: Button = $PainelPrincipal/BtnFechar 
@onready var lista_evidencias: VBoxContainer = $PainelPrincipal/HBoxContainer/InventarioScroll/ListaEvidencias
@onready var quadro_conexoes: Control = $PainelPrincipal/HBoxContainer/QuadroConexoes

# Estado
var aberto: bool = false
var evidencias_coletadas: Dictionary = {}  # {id: {nome, sprite, dialogo_data, ...}}
var evidencia_selecionada: PanelContainer = null
var conexoes: Array = [] 

# Configurações
const LARGURA_PAINEL = 0.85  
const ALTURA_PAINEL = 0.85   
const DURACAO_ANIMACAO = 0.3  
const ICONE_INVENTARIO_SCRIPT = preload("res://scripts/IconeInventario.gd")
const EVIDENCIA_NO_QUADRO_SCENE = preload("res://cenas/EvidenciaQuadro.tscn")
const RESUMO_UI_SCENE = preload("res://cenas/ResumoUI.tscn")

func _ready():
	print("=== DEBUG QuadroEvidencias ===")
	print("PainelPrincipal existe? ", painel_principal != null)
	
	if painel_principal:
		painel_principal.visible = true
	
	_ajustar_tamanho()
	
	# Esconder no início (após ajustar tamanho)
	var viewport_size = get_viewport().get_visible_rect().size
	var pos_escondida = -painel_principal.size.x - 50  
	painel_principal.position.x = pos_escondida
	
	print("Posição inicial X: ", painel_principal.position.x)
	print("Tamanho do painel: ", painel_principal.size)
	print("Viewport size: ", viewport_size)
	
	# Conectar botão fechar
	if btn_fechar:
		print("Botão fechar conectado!")
	else:
		print("AVISO: Botão fechar não encontrado!") # A referência original era Header/BtnFechar
	
	if quadro_conexoes:
		quadro_conexoes.evidencia_largada.connect(_on_evidencia_largada_no_quadro)
	
func _ajustar_tamanho():
	var viewport_size = get_viewport().get_visible_rect().size
	var largura = viewport_size.x * LARGURA_PAINEL
	var altura = viewport_size.y * ALTURA_PAINEL
	
	painel_principal.custom_minimum_size = Vector2(largura, altura)
	painel_principal.size = Vector2(largura, altura)
	
	# Centralizar verticalmente
	painel_principal.position.y = (viewport_size.y - altura) / 2

func abrir():
	print("=== Função ABRIR chamada ===")
	
	if aberto:
		print("Já está aberto, ignorando...")
		return
	
	print("Abrindo quadro...")
	aberto = true
	get_tree().paused = true
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  

	
	var posicao_final = Vector2.ZERO
	posicao_final.y = painel_principal.position.y  
	
	print("Posição final X: ", posicao_final.x)
	
	tween.tween_property(painel_principal, "position:x", posicao_final.x, DURACAO_ANIMACAO)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	print("Animação iniciada!")

func fechar():
	print("=== Função FECHAR chamada ===")
	
	if not aberto:
		print("Já está fechado, ignorando...")
		return
	
	print("Fechando quadro...")
	aberto = false
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	var pos_escondida = -painel_principal.size.x - 50
	
	print("Posição final (escondida) X: ", pos_escondida)
	
	tween.tween_property(painel_principal, "position:x", pos_escondida, DURACAO_ANIMACAO)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	
	await tween.finished
	get_tree().paused = false
	print("Quadro fechado e jogo despausado!")

func toggle():
	print("=== Função TOGGLE chamada ===")
	print("Estado atual - aberto: ", aberto)
	
	if aberto:
		fechar()
	else:
		abrir()

func _on_btn_fechar_pressed():
	print("=== Botão FECHAR pressionado ===")
	fechar()

# --- FUNÇÃO ATUALIZADA ---
# Adicionar evidência coletada ao quadro
func adicionar_evidencia(id: String, nome: String, sprite: Texture2D, dialogo_data: Dictionary):
	if evidencias_coletadas.has(id):
		print("Evidência '", id, "' já foi adicionada.")
		return
	
	# Salvar dados da evidência
	evidencias_coletadas[id] = {
		"nome": nome,
		"sprite": sprite,
		"dialogo_data": dialogo_data, # <-- MUDANÇA: Salva o dicionário todo
		"posicao_quadro": Vector2.ZERO,
		"conexoes": []
	}
	
	# Criar ícone na lista de inventário
	_criar_icone_inventario(id, nome, sprite)
	
	print("Evidência '", nome, "' adicionada ao quadro!")

func _criar_icone_inventario(id: String, nome: String, sprite: Texture2D):
	var icone_container = PanelContainer.new()
	icone_container.name = "Evidencia_" + id
	icone_container.custom_minimum_size = Vector2(70, 70)  
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1a1a2e")
	style.border_color = Color("#00d9ff")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	icone_container.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = sprite
	texture_rect.custom_minimum_size = Vector2(40, 40)  
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var label = Label.new()
	label.text = nome
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#00d9ff"))
	label.add_theme_font_size_override("font_size", 7)  

	
	vbox.add_child(texture_rect)
	vbox.add_child(label)
	icone_container.add_child(vbox)
	
	icone_container.set_script(ICONE_INVENTARIO_SCRIPT)

	icone_container.id = id
	icone_container.nome = nome
	icone_container.sprite = sprite

	lista_evidencias.add_child(icone_container)

func _on_evidencia_largada_no_quadro(data, posicao_local):
	var nova_evidencia = EVIDENCIA_NO_QUADRO_SCENE.instantiate()
	
	quadro_conexoes.add_child(nova_evidencia)
	
	nova_evidencia.set_data(data["id"], data["nome"], data["sprite"])
	
	nova_evidencia.position = posicao_local - (nova_evidencia.size / 2) 
	
	nova_evidencia.clicado.connect(quadro_conexoes._on_evidencia_no_quadro_clicada)
	nova_evidencia.arrastado.connect(quadro_conexoes._on_evidencia_arrastada)
	nova_evidencia.inspecionado.connect(_on_evidencia_inspecionada)


# --- FUNÇÃO ATUALIZADA ---
func _on_evidencia_inspecionada(evidencia_id: String):
	# 1. Pega os dados da evidência que salvamos
	var dados_evidencia = evidencias_coletadas.get(evidencia_id)
	if dados_evidencia:
		# Pega o dicionário de diálogo completo
		var dialogo_data = dados_evidencia.get("dialogo_data")
		if not dialogo_data:
			print("Erro: Evidência '", evidencia_id, "' sem dados de diálogo.")
			return

		# 2. Constrói o log completo
		# Começa com a análise principal
		var resumo_completo = dialogo_data.get("analise_holmes", "[DADOS CORROMPIDOS]")
		
		# Adiciona todas as perguntas e respostas
		var opcoes = dialogo_data.get("opcoes", [])
		for opcao in opcoes:
			var pergunta = opcao.get("texto", "?")
			var resposta = opcao.get("resposta_holmes", "...")
			resumo_completo += "\n\n> " + pergunta + "\n" + resposta
			
		# 3. Cria o pop-up
		var popup = RESUMO_UI_SCENE.instantiate()

		# 4. Adiciona o pop-up à cena (self é o CanvasLayer)
		add_child(popup)

		# 5. Mostra o texto
		popup.mostrar_resumo(resumo_completo)

func carregar_estado():
	pass

func salvar_estado():
	pass
