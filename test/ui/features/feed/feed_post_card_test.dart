import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/models/post_audience.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/ui/features/feed/widgets/feed_post_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Post _post({
  required String childName,
  required PostAudience audience,
  List<String> recipientNames = const [],
}) {
  return Post(
    id: 'post',
    childName: childName,
    childInitial: audience == PostAudience.room ? null : childName[0],
    childColorToken: audience == PostAudience.room ? 'announcement' : 'blue',
    timeLabel: '09:05',
    audience: audience,
    type: PostType.activity,
    body: 'Pintamos con témperas',
    likes: 0,
    comments: 0,
    recipientNames: recipientNames,
  );
}

Widget _pump(Post post) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: buildAppTheme(),
    home: Scaffold(
      body: SingleChildScrollView(child: FeedPostCard(post: post)),
    ),
  );
}

void main() {
  testWidgets('shows the family audience for a single recipient', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pump(
        _post(
          childName: 'Mateo',
          audience: PostAudience.family,
          recipientNames: const ['Mateo'],
        ),
      ),
    );

    expect(find.text('Para: familia de Mateo'), findsOneWidget);
  });

  testWidgets('lists every family for several recipients', (tester) async {
    await tester.pumpWidget(
      _pump(
        _post(
          childName: 'Mateo',
          audience: PostAudience.family,
          recipientNames: const ['Mateo', 'Sofía'],
        ),
      ),
    );

    expect(find.text('Para: familias de Mateo y Sofía'), findsOneWidget);
  });

  testWidgets('falls back to the author when recipients are missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pump(
        _post(childName: 'Mateo', audience: PostAudience.family),
      ),
    );

    expect(find.text('Para: familia de Mateo'), findsOneWidget);
  });

  testWidgets('keeps the room audience for the whole room', (tester) async {
    await tester.pumpWidget(
      _pump(_post(childName: 'Toda la sala', audience: PostAudience.room)),
    );

    expect(find.text('Para: toda la sala'), findsOneWidget);
  });
}
