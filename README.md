# Pokédex Flutter

Una aplicación móvil moderna de Pokédex desarrollada con Flutter que permite explorar y descubrir información detallada sobre Pokémon.

## 🚀 Características

### Funcionalidades Implementadas
- **Lista de Pokémon**: Vista completa de todos los Pokémon con scroll infinito
- **Búsqueda en Tiempo Real**: Busca Pokémon por nombre mientras escribes
- **Pantalla de Detalles**: Información completa de cada Pokémon
- **Sistema de Evolución**: Muestra cadenas evolutivas y métodos de evolución
- **Estadísticas Visuales**: Barras de progreso para stats base (HP, Ataque, Defensa, etc.)
- **Diseño Responsive**: Interfaz adaptada para móviles con gestos táctiles

### Experiencia de Usuario
- **Interfaz Intuitiva**: Navegación simple entre lista y detalles
- **Animaciones**: Transiciones suaves entre pantallas
- **Tema de Colores Dinámico**: Colores basados en tipos de Pokémon
- **Indicadores de Carga**: Feedback visual durante operaciones de red
- **Manejo de Errores**: Mensajes amigables cuando falla la carga de datos

## 📱 Pantallas

### Lista Principal
- Grid de Pokémon con imagen, nombre y número
- Barra de búsqueda superior
- Carga progresiva con paginación
- Indicadores de tipos con colores

### Detalles del Pokémon
- **Header**: Imagen grande con fondo de gradiente
- **Información Básica**: Nombre, número, tipos, especie
- **Pestañas Organizadas**:
  - **About**: Altura, peso, habilidades, experiencia base
  - **Stats**: Estadísticas con barras visuales y total
  - **Evolution**: Cadena evolutiva completa con métodos
- **Debilidades**: Tipos a los que es vulnerable

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework principal
- **Dart**: Lenguaje de programación
- **PokeAPI**: Fuente de datos de Pokémon
- **HTTP**: Para consumo de APIs REST
- **Material Design**: Componentes de UI

## 📦 Estructura del Proyecto
lib/
├── models/
│ ├── pokemon.dart # Modelo principal de Pokémon
│ └── pokemon_evolution.dart # Modelo de evoluciones
├── services/
│ └── pokemon_service.dart # Servicio para APIs de Pokémon
├── screens/
│ ├── pokemon_list_screen.dart # Pantalla de lista
│ └── pokemon_detail_screen.dart # Pantalla de detalles
├── constants/
│ └── colors.dart # Colores por tipo de Pokémon
└── main.dart # Punto de entrada

## 🚀 Instalación y Uso

### Prerrequisitos
- Flutter SDK instalado
- Dispositivo o emulador configurado

### Pasos
1. **Clonar el repositorio**
   ```bash
   git clone [url-del-repositorio]
   cd pokedex-flutter
   flutter pub get
   flutter run

## 🎯 Funcionalidades Técnicas
### Gestión de Estado
- Estado local con setState para pantallas simples
- Llamadas async/await para operaciones de red

## APIs Consumidas
- Pokémon List: /pokemon?limit=20&offset=0
- Pokémon Details: /pokemon/{id}
- Evolution Chain: /evolution-chain/{id}

## Widgets Personalizados
- PokemonCard: Tarjeta reusable para lista
- TypeChip: Chip visual para tipos de Pokémon
- StatBar: Barra de progreso para estadísticas
- EvolutionChain: Visualización de evoluciones

## 📄 Arquitectura

### Flujo de Datos
- **PokemonService** maneja todas las llamadas a la API
- **Models** representan la estructura de datos
- **Screens** contienen la lógica de presentación
- **Widgets** son componentes reutilizables

### Patrones Utilizados
- **Service Pattern**: Para abstraer la lógica de API
- **Model Classes**: Para estructura de datos tipada
- **Widget Composition**: Para UI modular

## 🐛 Solución de Problemas Comunes

### Imágenes no cargan
- Verificar conexión a internet
- Revisar que la URL de la imagen sea accesible

### Error en la API
- La PokeAPI ocasionalmente puede tener downtime
- Verificar en https://pokeapi.co/ el estado del servicio

### Build falla
- Ejecutar `flutter clean`
- Verificar `flutter doctor` para issues de entorno

## 🌟 Características Destacadas

### Evoluciones
- Muestra cadena evolutiva completa
- Detalla métodos de evolución (nivel, objeto, trade)
- Navegación visual entre formas evolutivas

### Estadísticas
- Visualización clara de todos los stats base
- Barras de progreso con colores temáticos
- Cálculo automático del total de stats

### Diseño Visual
- Gradientes dinámicos basados en tipo
- Iconografía consistente
- Espaciado y jerarquía visual clara