import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';

class KidsSearchField extends StatefulWidget {
  const KidsSearchField({
    required this.query,
    required this.onChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<KidsSearchField> createState() => _KidsSearchFieldState();
}

class _KidsSearchFieldState extends State<KidsSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant KidsSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    _handleChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const AppIcon(
            asset: 'assets/icons/search.svg',
            size: 18,
            color: AppColors.photoIcon,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Semantics(
              label: l10n.searchChildHint,
              textField: true,
              child: TextField(
                controller: _controller,
                onChanged: _handleChanged,
                textInputAction: TextInputAction.search,
                style: AppTypography.nunito(
                  size: 15,
                  color: AppColors.textStrong,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchChildHint,
                  hintStyle: AppTypography.nunito(
                    size: 15,
                    color: AppColors.textSoft,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            AppLink(
              key: const Key('kids-search-clear'),
              tooltip: l10n.clearSearch,
              borderRadius: BorderRadius.circular(8),
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: AppIcon(
                  asset: 'assets/icons/close.svg',
                  size: 16,
                  color: AppColors.textSoft,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
