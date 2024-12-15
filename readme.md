# Proyecto de Simulación de Vehículos

Este proyecto es una simulación de vehículos utilizando el motor de juegos Godot. Incluye varias escenas, scripts y recursos para crear una experiencia de simulación realista. Usando los addons Vitah-Vehicle y Godot Jolt.

## Estructura del Proyecto

- `.gitattributes`: Archivo de configuración para Git.
- `.godot/`: Directorio que contiene archivos y configuraciones específicas de Godot.
- `editor/`: Configuraciones del editor de Godot.
- `imported/`: Archivos importados por Godot.
- `shader_cache/`: Caché de shaders.
- `addons/`: Directorio que contiene complementos de Godot.
- `godot-jolt/`: Complemento para la física de Jolt en Godot.
- `vitavehicle_ui/`: Interfaz de usuario para la simulación de vehículos.
- `car.tscn`: Escena principal del coche.
- `default_bus_layout.tres`: Configuración de buses de audio.
- `default_env.tres`: Configuración del entorno por defecto.
- `engine sounds/`: Directorio que contiene sonidos del motor.
- `export_presets.cfg`: Configuraciones de exportación.
- `FONT/`: Directorio que contiene fuentes.
- `Grid.png.import`: Archivo importado de una imagen de cuadrícula.
- `icon.png.import`: Archivo importado del icono del proyecto.
- `logo.png.import`: Archivo importado del logo del proyecto.
- `MAIN/`: Directorio principal que contiene scripts y escenas principales.
- `MISC/`: Directorio que contiene scripts y escenas misceláneas.
- `debugger.tscn`: Escena del depurador.
- `tachometre/tacho.gd`: Script del tacómetro.
- `visual gravity system/vgs.tscn`: Escena del sistema de gravedad visual.
- `morning_env.scn`: Escena del entorno matutino.
- `project.godot`: Archivo de configuración del proyecto de Godot.
- `readme.md`: Este archivo.
- `scene.tscn`: Escena adicional.
- `world.tscn`: Escena del mundo principal.

## Scripts Principales y sus Funciones

### `MISC/tachometre/tacho.gd`
Este script controla el tacómetro y el turbo del vehículo. Define las constantes para los ángulos de las agujas del tacómetro y del turbo, y maneja las variables de estado como `currentrpm` y `currentpsi`. También permite configurar la visibilidad del turbo y los rangos de RPM y PSI.

### `MISC/misc scripts/debug.gd`
Este script se encarga de la depuración y visualización de datos en tiempo real. Muestra información como la distribución del peso, la velocidad, la potencia y el torque del vehículo. También maneja la visualización de indicadores como ABS, TCS y ESP, y permite reiniciar el motor y alternar la visualización de fuerzas.

### `MISC/graph/draw.gd`
Este script dibuja gráficos de potencia y torque. Configura las unidades de torque y potencia, y define las propiedades del motor como la fricción, el arrastre y la respuesta del acelerador. También maneja la configuración de la ECU y el estado del torque.

### `addons/vitavehicle_ui/script.gd`
Este script es parte del complemento de la interfaz de usuario para la simulación de vehículos. Se encarga de crear y gestionar la instancia del panel del equipo en el editor de Godot. También define funciones para mostrar y ocultar el panel, y proporciona el nombre y el icono del complemento.

### Participación en el Código

- **`tacho.gd`**: Se utiliza para actualizar y mostrar la información del tacómetro y el turbo en la interfaz del vehículo. Es llamado desde otros scripts para reflejar los cambios en el estado del motor.
- **`debug.gd`**: Se ejecuta continuamente para proporcionar información de depuración en tiempo real. Interactúa con varios nodos del vehículo para obtener y mostrar datos relevantes.
- **`draw.gd`**: Se encarga de dibujar los gráficos de potencia y torque en la interfaz. Es utilizado para visualizar el rendimiento del motor en diferentes condiciones.
- **`script.gd`**: Gestiona la interfaz de usuario del complemento en el editor de Godot. Permite a los desarrolladores interactuar con el panel del equipo y ajustar configuraciones desde el editor.

Estos scripts trabajan en conjunto para proporcionar una simulación de vehículos realista y una interfaz de usuario intuitiva tanto en el juego como en el editor de Godot.

## Configuración del Proyecto

El archivo `project.godot` contiene la configuración principal del proyecto, incluyendo la escena principal (`world.tscn`), configuraciones de ventana, y autoloads para scripts importantes.

## Controles

### Teclado
- `W/↑`: Acelerar
- `S/↓`: Frenar
- `A/←`: Girar a la izquierda
- `D/→`: Girar a la derecha
- `K/Shift`: Embrague
- `E/P`: Subir de marcha
- `Q/L`: Bajar de marcha
- `Espacio/Ctrl`: Freno de mano

### Ratón
- `Botón izquierdo (LMB)`: Acelerar
- `Botón derecho (RMB)`: Frenar
- `Movimiento horizontal del cursor`: Dirección
- `W`: Embrague
- `E`: Subir de marcha
- `Q`: Bajar de marcha

## Requisitos

- Godot Engine 4.3 o superior.

## Instalación

1. Clona el repositorio.
2. Abre el proyecto en Godot Engine.
3. Ejecuta la escena principal `world.tscn`.

## Licencia

Este proyecto utiliza el complemento Godot Jolt, que está licenciado bajo la [MIT License](addons/godot-jolt/LICENSE.txt).
