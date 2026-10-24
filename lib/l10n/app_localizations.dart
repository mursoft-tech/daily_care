import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'OpenDayCare'**
  String get brandName;

  /// Nombre de la sala
  ///
  /// In es, this message translates to:
  /// **'Sala Soles'**
  String get salaName;

  /// No description provided for @navFeed.
  ///
  /// In es, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navChildren.
  ///
  /// In es, this message translates to:
  /// **'Niños'**
  String get navChildren;

  /// No description provided for @navNotices.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get navNotices;

  /// No description provided for @navAccount.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get navAccount;

  /// No description provided for @newPost.
  ///
  /// In es, this message translates to:
  /// **'Nueva publicación'**
  String get newPost;

  /// No description provided for @logoutTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutTooltip;

  /// No description provided for @logoutLabel.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutLabel;

  /// No description provided for @menuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Abrir menú'**
  String get menuTooltip;

  /// No description provided for @loginComingSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión en preparación'**
  String get loginComingSoonTitle;

  /// No description provided for @loginComingSoonBody.
  ///
  /// In es, this message translates to:
  /// **'La autenticación real llegará en la próxima etapa. Mientras tanto, podés volver al feed.'**
  String get loginComingSoonBody;

  /// No description provided for @backToFeed.
  ///
  /// In es, this message translates to:
  /// **'Volver al feed'**
  String get backToFeed;

  /// Título del error de navegación
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esa pantalla'**
  String get routeErrorTitle;

  /// Mensaje genérico del error de navegación
  ///
  /// In es, this message translates to:
  /// **'Revisá la dirección o volvé al feed para seguir navegando.'**
  String get routeErrorBody;

  /// No description provided for @teacherRole.
  ///
  /// In es, this message translates to:
  /// **'Maestra · Soles'**
  String get teacherRole;

  /// No description provided for @familyRole.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get familyRole;

  /// Saludo de la cabecera del home
  ///
  /// In es, this message translates to:
  /// **'Buenas, {name}'**
  String greeting(String name);

  /// Resumen de cantidad de niños y fecha
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 niño} other{{count} niños}} · {date}'**
  String summary(int count, String date);

  /// Etiqueta sobre el saludo
  ///
  /// In es, this message translates to:
  /// **'GUARDERÍA · SALA SOLES'**
  String get eyebrow;

  /// No description provided for @publishedToday.
  ///
  /// In es, this message translates to:
  /// **'PUBLICADO HOY'**
  String get publishedToday;

  /// No description provided for @composerHint.
  ///
  /// In es, this message translates to:
  /// **'Compartí un momento…'**
  String get composerHint;

  /// No description provided for @composerPhotoTooltip.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get composerPhotoTooltip;

  /// Audiencia de una publicación dirigida a una familia
  ///
  /// In es, this message translates to:
  /// **'Para: familia de {childName}'**
  String audienceFamily(String childName);

  /// No description provided for @audienceAll.
  ///
  /// In es, this message translates to:
  /// **'Para: toda la sala'**
  String get audienceAll;

  /// Hora y autor de la publicación
  ///
  /// In es, this message translates to:
  /// **'{time} · publicado por vos'**
  String postMeta(String time);

  /// No description provided for @typeAchievement.
  ///
  /// In es, this message translates to:
  /// **'LOGRO'**
  String get typeAchievement;

  /// No description provided for @typeActivity.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDAD'**
  String get typeActivity;

  /// No description provided for @typeAnnouncement.
  ///
  /// In es, this message translates to:
  /// **'ANUNCIO'**
  String get typeAnnouncement;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @feedError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el feed'**
  String get feedError;

  /// No description provided for @loadingFeed.
  ///
  /// In es, this message translates to:
  /// **'Cargando feed'**
  String get loadingFeed;

  /// Etiqueta del placeholder de foto
  ///
  /// In es, this message translates to:
  /// **'Foto · {label}'**
  String photoLabel(String label);

  /// Etiqueta accesible del contador de likes
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 me gusta} other{{count} me gusta}}'**
  String likesSemantics(int count);

  /// Etiqueta accesible del contador de comentarios
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 comentario} other{{count} comentarios}}'**
  String commentsSemantics(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
