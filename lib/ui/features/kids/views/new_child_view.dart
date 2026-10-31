import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../domain/value_objects/child_draft.dart';
import '../../../core/widgets/app_shell.dart';
import '../view_models/kids_view_model.dart';
import '../view_models/new_child_view_model.dart';
import '../widgets/new_child_form.dart';

class NewChildView extends ConsumerWidget {
  const NewChildView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newChildViewModelProvider);

    Future<void> submit(ChildDraft draft) async {
      final child = await ref
          .read(newChildViewModelProvider.notifier)
          .submit(draft);

      if (child == null || !context.mounted) return;

      ref.invalidate(kidsViewModelProvider);
      context.go(AppRoutes.kids);
    }

    return AppShell(
      selectedIndex: 1,
      onLogout: () => context.go(AppRoutes.login),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 40, horizontal, 80),
                  child: NewChildForm(
                    initialDraft: ChildDraft.empty(),
                    isSaving: state.isSaving,
                    errors: state.errors,
                    onSubmit: submit,
                    onCancel: () => context.go(AppRoutes.kids),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
