import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// `material_ui` trae sus propios delegates globales; los de
/// `flutter_localizations` no satisfacen su `MaterialLocalizations`.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

const appSupportedLocales = AppLocalizations.supportedLocales;
