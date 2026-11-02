import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../domain/value_objects/post_draft.dart';
import '../../../core/widgets/app_shell.dart';
import '../view_models/create_post_view_model.dart';
import '../view_models/feed_view_model.dart';
import '../widgets/create_post_form.dart';

class CreatePostView extends ConsumerWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPostViewModelProvider);

    Future<void> submit(PostDraft draft) async {
      final post = await ref
          .read(createPostViewModelProvider.notifier)
          .submit(draft);

      if (post == null || !context.mounted) return;

      ref.invalidate(feedViewModelProvider);
      context.go(AppRoutes.home);
    }

    return AppShell(
      selectedIndex: 0,
      onLogout: () => context.go(AppRoutes.login),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 40, horizontal, 80),
                  child: CreatePostForm(
                    isSaving: state.isSaving,
                    errors: state.errors,
                    onSubmit: submit,
                    onCancel: () => context.go(AppRoutes.home),
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
