# Pokédex Flutter (BLoC + PokeAPI)

Aplicación móvil tipo Pokédex desarrollada en Flutter. Demuestra un enfoque “production-ready” con paginación, búsqueda en tiempo real, pantalla de detalles con pestañas, cadena evolutiva y manejo robusto de estados con BLoC.

## Demo
- Video (60–90s): <pon aquí tu link de Loom/YouTube>
- APK/Release: <link a GitHub Releases>

---

## 🚀 Features

### Funcionalidades
- ✅ **Lista de Pokémon** con **scroll infinito** (paginación)
- ✅ **Búsqueda en tiempo real** (actualiza mientras escribes)
- ✅ **Pantalla de detalles** con info completa
- ✅ **Evoluciones**: cadena evolutiva + métodos (nivel/objeto/trade)
- ✅ **Stats visuales**: barras de progreso y total
- ✅ **UI dinámica**: colores basados en el tipo de Pokémon

### Experiencia de usuario
- ✅ Animaciones y transiciones suaves
- ✅ Skeleton loading / indicadores de carga
- ✅ Manejo de errores con mensajes claros y opción de reintentar

---

## 🧠 Arquitectura y Estado

### Gestión de estado (BLoC)
- `PokemonListBloc`: paginación, búsqueda, estados `loading/success/empty/error`
- (Opcional recomendado) `PokemonDetailBloc`: detalles, stats, evolución

### Flujo de datos
UI (Screens/Widgets)  
→ BLoC (Events/States)  
→ Service / Repository (PokeAPI)  
→ Models

---

## 🛠️ Tech Stack
- **Flutter** / **Dart**
- **flutter_bloc** (BLoC) + estados tipados
- **HTTP** (consumo REST)
- **PokeAPI** (fuente de datos)
- Material Design

---

## 📦 Estructura del proyecto
