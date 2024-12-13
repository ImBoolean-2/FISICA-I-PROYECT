extends Control

# Constantes para los ángulos de las agujas y tacómetro
const TACHO_LOW_ANGLE = -120.0
const TACHO_HIGH_ANGLE = 120.0
const TURBO_LOW_ANGLE = -90.0
const TURBO_HIGH_ANGLE = 90.0

# Variables de estado
var currentrpm: float = 0.0
var currentpsi: float = 0.0

# Variables exportadas configurables
@export var Turbo_Visible: bool = false
@export var Max_PSI: float = 13.0
@export var RPM_Range: float = 9000.0
@export var Redline: float = 7000.0

# Lista para almacenar marcas generadas dinámicamente
var generated_markers = []

func _ready():
	# Validar variables configurables
	if Max_PSI <= 0.0:
		Max_PSI = 1.0
	if RPM_Range <= 0.0:
		RPM_Range = 1.0

	# Configuración inicial del turbo
	$turbo.visible = Turbo_Visible
	$turbo/maxpsi.text = str(int(Max_PSI))

	# Limpiar nodos generados previamente
	if len(generated_markers) > 0:
		for marker in generated_markers:
			marker.queue_free()
		generated_markers.clear()

	# Generar marcas del tacómetro
	generate_tachometer_markers()


func generate_tachometer_markers():
	# Cálculo de límites
	var divisions = int(RPM_Range / 1000.0)  # Divisiones mayores (en miles)
	var redline_position = Redline / 1000.0

	for i in range(divisions + 1):
		# Calcular ángulo de la marca principal
		var main_angle = lerp(TACHO_LOW_ANGLE, TACHO_HIGH_ANGLE, float(i) / divisions)
		var is_red = float(i) >= redline_position

		# Crear marca principal
		create_marker($tacho, $tacho/major, main_angle, str(i), is_red)

		# Crear subdivisiones menores (si no es la última división)
		if i != divisions:
			for fraction in [0.25, 0.5, 0.75]:
				var sub_angle = lerp(TACHO_LOW_ANGLE, TACHO_HIGH_ANGLE, (float(i) + fraction) / divisions)
				var is_sub_red = float(i) + fraction >= redline_position
				create_marker($tacho, $tacho/minor, sub_angle, "", is_sub_red)


func create_marker(parent, template, angle, text="", is_red=false):
	"""
	Crea una marca en el tacómetro.
	- parent: Nodo padre donde se agregará la marca.
	- template: Nodo que se duplicará.
	- angle: Ángulo de rotación de la marca.
	- text: Texto de la marca (opcional).
	- is_red: Si la marca debe estar en color rojo.
	"""
	var marker = template.duplicate(true)
	parent.add_child(marker)
	marker.rotation_degrees = angle
	marker.visible = true

	if text != "":
		var label = marker.get_node("tetx")
		label.text = text
		label.rotation_degrees = -angle
		if len(label.text) > 1:
			label.position.y += 5  # Ajuste visual para textos más largos

	if is_red:
		marker.color = Color(1, 0, 0)

	generated_markers.append(marker)


func _process(_delta):
	# Actualizar la rotación de la aguja del tacómetro
	var tacho_angle = lerp(TACHO_LOW_ANGLE, TACHO_HIGH_ANGLE, abs(currentrpm) / RPM_Range)
	if $tacho/needle.rotation_degrees != tacho_angle:
		$tacho/needle.rotation_degrees = tacho_angle

	# Actualizar la rotación de la aguja del turbo
	var turbo_angle = lerp(TURBO_LOW_ANGLE, TURBO_HIGH_ANGLE, currentpsi / Max_PSI)
	if $turbo/needle.rotation_degrees != turbo_angle:
		$turbo/needle.rotation_degrees = clamp(turbo_angle, TURBO_LOW_ANGLE, TURBO_HIGH_ANGLE)
