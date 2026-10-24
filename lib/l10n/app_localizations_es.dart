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
  String get logoutLabel => 'Cerrar sesión';

  @override
  String get menuTooltip => 'Abrir menú';

  @override
  String get loginComingSoonTitle => 'Inicio de sesión en preparación';

  @override
  String get loginComingSoonBody =>
      'La autenticación real llegará en la próxima etapa. Mientras tanto, podés volver al feed.';

  @override
  String get backToFeed => 'Volver al feed';

  @override
  String get routeErrorTitle => 'No pudimos abrir esa pantalla';

  @override
  String get routeErrorBody =>
      'Revisá la dirección o volvé al feed para seguir navegando.';

  @override
  String get teacherRole => 'Maestra · Soles';

  @override
  String get familyRole => 'Familia';

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

  @override
  String get kidsEyebrow => 'GESTIÓN';

  @override
  String get kidsTitle => 'Niños';

  @override
  String get addChild => 'Agregar niño';

  @override
  String get searchChildHint => 'Buscar niño…';

  @override
  String get clearSearch => 'Limpiar búsqueda';

  @override
  String get kidsRoomLabel => 'SALA SOLES';

  @override
  String kidsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niños',
      one: '1 niño',
    );
    return '$_temp0';
  }

  @override
  String childAge(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String linkedParents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count padres vinculados',
      one: '1 padre vinculado',
      zero: 'sin padres vinculados',
    );
    return '$_temp0';
  }

  @override
  String get linkParentBadge => 'VINCULAR';

  @override
  String get noKidsResults => 'No encontramos niños con ese nombre';

  @override
  String get kidsError => 'No se pudo cargar el listado de niños';

  @override
  String get loadingKids => 'Cargando niños';

  @override
  String get backToKids => 'Volver a Niños';

  @override
  String get childProfileAllergyTitle => 'Alergias y notas';

  @override
  String get childProfileBirthDate => 'Fecha de nacimiento';

  @override
  String get childProfileRoom => 'Sala';

  @override
  String get childProfileEnrollment => 'Ingreso';

  @override
  String get childProfileParentsTitle => 'PADRES VINCULADOS';

  @override
  String get childProfileDaySummary => 'Resumen del día';

  @override
  String get childProfileNoParents => 'Sin padres vinculados';

  @override
  String get linkParent => 'Vincular un padre';

  @override
  String get linkAnotherParent => 'Vincular otro padre';

  @override
  String get parentRoleMother => 'Mamá';

  @override
  String get parentRoleFather => 'Papá';

  @override
  String get parentRoleGuardian => 'Tutor';

  @override
  String get parentStatusActiveFemale => 'activa';

  @override
  String get parentStatusActiveMale => 'activo';

  @override
  String get parentStatusActiveNeutral => 'con cuenta activa';

  @override
  String get parentStatusInvited => 'invitación enviada';

  @override
  String get parentBadgeActive => 'ACTIVA';

  @override
  String get parentBadgePending => 'PENDIENTE';

  @override
  String get childProfileLoading => 'Cargando ficha';

  @override
  String get childProfileError => 'No se pudo cargar la ficha';

  @override
  String get childProfileNotFound => 'No encontramos este perfil';

  @override
  String get childProfileNotFoundBody =>
      'El niño que buscás no está en esta sala.';
}
