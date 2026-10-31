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
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginSubtitle => 'Ingresá para ver el día de hoy.';

  @override
  String get loginHeroClaim =>
      'El día de cada niño,\ncompartido con su familia.';

  @override
  String get loginHeroDescription =>
      'Publicá momentos, gestioná las salas y mantené a las familias cerca, desde un solo lugar.';

  @override
  String get loginHeroFooter => '🌿 Guardería Sala Soles';

  @override
  String get loginRoleEyebrow => 'INGRESO COMO';

  @override
  String get loginRoleStaff => 'Personal';

  @override
  String get loginRoleParent => 'Familia';

  @override
  String get loginEmailLabel => 'EMAIL';

  @override
  String get loginPasswordLabel => 'CONTRASEÑA';

  @override
  String get loginPasswordPlaceholder => '••••••••';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSubmitButton => 'Iniciar sesión';

  @override
  String get loginInvitationPrompt => '¿Te invitó la guardería?';

  @override
  String get loginActivateAccount => 'Activá tu cuenta';

  @override
  String get loginInvalidEmailError => 'Ingresá un correo electrónico válido';

  @override
  String get loginInvalidCredentialsError =>
      'Credenciales incorrectas. Verificá tu usuario y contraseña';

  @override
  String get loginEmptyPasswordError => 'Ingresá tu contraseña';

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

  @override
  String get activateAccountTitle => 'Bienvenida a OpenDayCare';

  @override
  String get activateAccountSubtitle =>
      'Te invitaron a seguir el día de tu hijo. Creá tu contraseña para activar la cuenta.';

  @override
  String get activateInvitedTo => 'Te invitaron a seguir a';

  @override
  String activateChildRoom(String childName, String roomName) {
    return '$childName · $roomName';
  }

  @override
  String get activateCodeLabel => 'CÓDIGO DE INVITACIÓN';

  @override
  String get activatePasswordLabel => 'CREAR CONTRASEÑA';

  @override
  String get activatePhotoConsent =>
      'Autorizo a la guardería a tomar y compartir fotos de mi hijo dentro de la app.';

  @override
  String get activateSubmitButton => 'Activar mi cuenta';

  @override
  String get activateHaveAccountPrompt => '¿Ya tenés cuenta?';

  @override
  String get activateSignInLink => 'Iniciar sesión';

  @override
  String get activateInvalidCodeError =>
      'No encontramos una invitación con ese código';

  @override
  String get activateEmailMismatchError =>
      'Ese email no coincide con la invitación';

  @override
  String get activateWeakPasswordError =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get activateConsentRequiredError =>
      'Necesitamos tu autorización para continuar';

  @override
  String get activateGenericError =>
      'No pudimos completar la activación. Probá de nuevo.';

  @override
  String get activateLoadingInvitation => 'Cargando invitación';

  @override
  String get activateLoadError => 'No pudimos cargar tu invitación';

  @override
  String get childFormTitle => 'Agregar niño';

  @override
  String get childFormCancel => 'Cancelar';

  @override
  String get childFormSave => 'Guardar';

  @override
  String get childFormSaving => 'Guardando niño';

  @override
  String get childFormNameLabel => 'NOMBRE COMPLETO';

  @override
  String get childFormNameHint => 'Ej. Martina López';

  @override
  String get childFormBirthDateLabel => 'FECHA DE NACIMIENTO';

  @override
  String get childFormBirthDateHint => 'dd/mm/aaaa';

  @override
  String get childFormRoomLabel => 'SALA';

  @override
  String get childFormAllergiesLabel => 'ALERGIAS (ETIQUETAS)';

  @override
  String get childFormAllergiesHint => 'Ej. Maní, Lactosa';

  @override
  String get childFormMedicalNotesLabel => 'NOTAS MÉDICAS';

  @override
  String get childFormMedicalNotesHint =>
      'Indicaciones, medicación, contactos…';

  @override
  String get childFormNameRequiredError => 'Ingresá el nombre completo';

  @override
  String get childFormBirthDateRequiredError =>
      'Ingresá la fecha de nacimiento';

  @override
  String get childFormBirthDateInvalidError =>
      'Ingresá una fecha válida (dd/mm/aaaa)';

  @override
  String get childFormBirthDateFutureError => 'La fecha no puede ser futura';

  @override
  String get childFormBirthDateTooOldError =>
      'Solo se pueden registrar niños de hasta 6 años';

  @override
  String get childFormRoomRequiredError => 'Elegí una sala';

  @override
  String get childFormSaveError =>
      'No pudimos guardar el niño. Probá de nuevo.';
}
