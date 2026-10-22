---
name: flutter-implement-json-serialization
description: Create model classes with `fromJson` and `toJson` methods using `dart:convert`. Use when manually mapping JSON keys to class properties for simple data structures.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 21:44:50 GMT
---
# Serializing JSON Manually in Flutter

## Contents
- [Core Guidelines](#core-guidelines)
- [Workflow: Implementing a Serializable Model](#workflow-implementing-a-serializable-model)
- [Workflow: Fetching and Parsing JSON](#workflow-fetching-and-parsing-json)
- [Examples](#examples)

## Core Guidelines

- **Import `dart:convert`**: Utilize Flutter's built-in `dart:convert` library for manual JSON encoding (`jsonEncode`) and decoding (`jsonDecode`).
- **Enforce Type Safety**: Cast the `dynamic` result of `jsonDecode()` to `Map<String, Object?>` for objects or `List<Object?>` for arrays. Evita `dynamic` en las firmas de los modelos.
- **Decode UTF-8 explicitly**: Usa `utf8.decode(response.bodyBytes)`; `response.body` asume Latin-1 cuando el servidor no declara `charset`, lo que corrompe acentos y `ñ`.
- **Encapsulate Serialization Logic**: Define plain model classes containing properties corresponding to the JSON structure. Implement a `fromJson` factory constructor and a `toJson` method within the model. La clase solo se encarga de serialización; las peticiones HTTP van en `lib/data/datasources/remote/`.
- **Handle Background Parsing**: If parsing large JSON documents (execution time > 16ms), offload both the UTF-8 decoding and parsing to a separate isolate using Flutter's `compute()` function to prevent UI jank.
- **Throw Exceptions on Failure**: When handling HTTP responses, throw an exception if the status code is not successful (e.g., not 200 OK or 201 Created). Do not return `null`.
- **Bound the response**: Define un timeout, limita el tamaño del payload y valida el `Content-Type` antes de decodificar. Nunca confíes en el tamaño que anuncia el servidor.

## Workflow: Implementing a Serializable Model

Use this checklist to implement manual JSON serialization for a data model.

**Task Progress:**
- [ ] Define the plain model class with `final` properties.
- [ ] Implement the `factory Model.fromJson(Map<String, Object?> json)` constructor.
- [ ] Implement the `Map<String, Object?> toJson()` method.
- [ ] Write unit tests for both serialization methods.
- [ ] Run validator -> review type mismatch errors -> fix casting logic.

1. **Define the Model**: Create a class with properties matching the JSON keys.
2. **Implement `fromJson`**: Extract values from the `Map` and cast them to the appropriate Dart types. Use pattern matching or explicit casting.
3. **Implement `toJson`**: Return a `Map<String, Object?>` mapping the class properties back to their JSON string keys.
4. **Validate**: Execute unit tests to ensure type safety, autocompletion, and compile-time exception handling function correctly.

## Workflow: Fetching and Parsing JSON

Use this conditional workflow when retrieving and parsing JSON from a network request.

**Task Progress:**
- [ ] Execute the HTTP request.
- [ ] Validate the response status code.
- [ ] Determine parsing strategy (Synchronous vs. Isolate).
- [ ] Decode and map the JSON to the model.

1. **Execute Request**: Use the `http` package inside a Service class and apply `.timeout(const Duration(seconds: 10))`.
2. **Validate Response**: 
   - If `response.statusCode == 200` (or 201 for POST), proceed to parsing.
   - If the status code indicates failure, throw an `Exception` with el código, sin incluir el body crudo.
   - Verifica que el `Content-Type` sea JSON y que `response.bodyBytes.length` esté dentro del límite permitido.
3. **Determine Parsing Strategy**:
   - If parsing a **small payload** (e.g., a single object), parse synchronously on the main thread.
   - If parsing a **large payload** (e.g., an array of thousands of objects), use `compute(parseFunction, response.bodyBytes)` y decodifica UTF-8 dentro del isolate.
4. **Decode and Map**: `utf8.decode(response.bodyBytes)` -> `jsonDecode(...)` -> `Model.fromJson(...)`. El Service devuelve el DTO; el repositorio lo mapea a `lib/domain/models/` y traduce las excepciones a `Result<T>`.

## Examples

### High-Fidelity Model Implementation

```dart
import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  // Factory constructor for deserialization
  factory User.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'email': String email,
      } => 
        User(
          id: id,
          name: name,
          email: email,
        ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }

  // Method for serialization
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

> Si el backend puede enviar `1.0` para un `int`, usa `(json['id'] as num).toInt()` en lugar del patrón `int id`. No uses `toString()` para convertir tipos numéricos.

> Ubicación: el DTO va siempre en `lib/data/models/`. El repositorio de `lib/data/repositories/` lo transforma a la entidad de `lib/domain/models/`; los Services devuelven DTOs o lanzan excepciones, nunca entidades de dominio. Si la app es pequeña, usa un único modelo inmutable y evita duplicarlo.
> El modelo no conoce Riverpod ni HTTP. Expón `UserService`/`UserRepository` como providers en `lib/app/`; el provider apunta al contrato de `lib/domain/repositories/`.

### Mapping DTO to Domain Model

```dart
// domain/models/user.dart
class User {
  const User({required this.id, required this.name});

  final int id;
  final String name;
}

// data/repositories/user_repository_impl.dart
User _toDomain(UserDto dto) => User(id: dto.id, name: dto.fullName);
```

> Un DTO sin capa de dominio no se justifica: si el proyecto es pequeño o el payload coincide con la entidad, usa un único modelo. En cuanto haya `domain/`, ningún widget importa `data/models`.

### Synchronous Parsing (Small Payload)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// Remote data source: lib/data/datasources/remote/user_service.dart
class UserService {
  UserService(this._client);

  static const _timeout = Duration(seconds: 10);
  static const _maxPayloadBytes = 5 * 1024 * 1024;

  final http.Client _client;

  Future<User> fetchUser(int userId) async {
    final response = await _client
        .get(
          Uri.parse('https://api.example.com/users/$userId'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user (${response.statusCode})');
    }
    if (!(response.headers['content-type'] ?? '').contains('application/json')) {
      throw const FormatException('Unexpected content type');
    }
    if (response.bodyBytes.length > _maxPayloadBytes) {
      throw const FormatException('Payload too large');
    }

    final jsonMap =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
    return User.fromJson(jsonMap);
  }
}
```

### Background Parsing (Large Payload)

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Top-level function required for compute(). Decode UTF-8 inside the isolate.
List<User> parseUsers(List<int> bodyBytes) {
  final decoded = jsonDecode(utf8.decode(bodyBytes)) as List<Object?>;
  return decoded
      .cast<Map<String, Object?>>()
      .map(User.fromJson)
      .toList();
}

Future<List<User>> fetchUsers(http.Client client) async {
  final response = await client
      .get(
        Uri.parse('https://api.example.com/users'),
        headers: {'Accept': 'application/json'},
      )
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Failed to load users (${response.statusCode})');
  }
  if (response.bodyBytes.length > 5 * 1024 * 1024) {
    throw const FormatException('Payload too large');
  }

  // Offload decoding and parsing to a background isolate.
  return compute(parseUsers, response.bodyBytes);
}
```
