import '../models/post_type.dart';

/// Datos capturados en el formulario antes de validarse y convertirse en `Post`.
class PostDraft {
  const PostDraft({
    this.childIds = const <String>[],
    this.type = PostType.activity,
    this.body = '',
  });

  /// Lista vacía significa que la publicación es para toda la sala.
  final List<String> childIds;
  final PostType type;
  final String body;

  String get trimmedBody => body.trim();

  bool get isForRoom => childIds.isEmpty;
}
