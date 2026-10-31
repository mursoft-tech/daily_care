import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';

class KidsHeader extends StatelessWidget {
  const KidsHeader({required this.onAddChild, super.key});

  final VoidCallback onAddChild;

  static const _stackBreakpoint = 480.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.kidsEyebrow,
              style: AppTypography.nunito(
                size: 12.5,
                weight: FontWeight.w800,
                color: AppColors.primaryDark,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.kidsTitle, style: AppTypography.fredoka(size: 30)),
          ],
        );
        final button = _AddChildButton(onTap: onAddChild);

        if (constraints.maxWidth < _stackBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 16), button],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            button,
          ],
        );
      },
    );
  }
}

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppLink(
      key: const Key('kids-add-child'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primarySoft, AppColors.primary],
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryShadow,
              blurRadius: 18,
              offset: Offset(0, 8),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(
              asset: 'assets/icons/plus.svg',
              size: 17,
              color: AppColors.white,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).addChild,
              style: AppTypography.nunito(
                size: 14.5,
                weight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
