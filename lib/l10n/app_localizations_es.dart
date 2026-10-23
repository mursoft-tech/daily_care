// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get brandName => 'OpenDayCare';

  @override
  String get salaName => 'Sala Soles';

  @override
  String get navFeed => 'Feed';

  @override
  String get navChildren => 'Niños';

  @override
  String get navNotices => 'Avisos';

  @override
  String get navAccount => 'Mi cuenta';

  @override
  String get newPost => 'Nueva publicación';

  @override
  String get logoutTooltip => 'Cerrar sesión';

  @override
  String get teacherRole => 'Maestra · Soles';

  @override
  String greeting(String name) {
    return 'Buenas, $name';
  }

  @override
  String summary(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niños',
      one: '1 niño',
    );
    return '$_temp0 · $date';
  }

  @override
  String get eyebrow => 'GUARDERÍA · SALA SOLES';

  @override
  String get publishedToday => 'PUBLICADO HOY';

  @override
  String get composerHint => 'Compartí un momento…';

  @override
  String get composerPhotoTooltip => 'Agregar foto';

  @override
  String audienceFamily(String childName) {
    return 'Para: familia de $childName';
  }

  @override
  String get audienceAll => 'Para: toda la sala';

  @override
  String postMeta(String time) {
    return '$time · publicado por vos';
  }

  @override
  String get typeAchievement => 'LOGRO';

  @override
  String get typeActivity => 'ACTIVIDAD';

  @override
  String get typeAnnouncement => 'ANUNCIO';

  @override
  String get edit => 'Editar';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get retry => 'Reintentar';

  @override
  String get feedError => 'No se pudo cargar el feed';

  @override
  String get loadingFeed => 'Cargando feed';

  @override
  String photoLabel(String label) {
    return 'Foto · $label';
  }

  @override
  String likesSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String commentsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }
}
