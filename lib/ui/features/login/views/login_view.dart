import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/login_form.dart';
import '../widgets/login_hero_panel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;

          if (isWide) {
            return const Row(
              children: [
                Expanded(
                  flex: 11,
                  child: LoginHeroPanel(isMobileBanner: false),
                ),
                Expanded(
                  flex: 10,
                  child: LoginForm(),
                ),
              ],
            );
          }

          return const Column(
            children: [
              LoginHeroPanel(isMobileBanner: true),
              Expanded(
                child: LoginForm(),
              ),
            ],
          );
        },
      ),
    );
  }
}
