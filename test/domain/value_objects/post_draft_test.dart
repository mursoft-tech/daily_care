import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/domain/value_objects/post_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostDraft', () {
    test('defaults to the whole room, activity and an empty body', () {
      const draft = PostDraft();

      expect(draft.childIds, isEmpty);
      expect(draft.isForRoom, isTrue);
      expect(draft.type, PostType.activity);
      expect(draft.body, isEmpty);
      expect(draft.trimmedBody, isEmpty);
    });

    test('trims the body without mutating the original text', () {
      const draft = PostDraft(body: '  Pintamos con témperas  ');

      expect(draft.body, '  Pintamos con témperas  ');
      expect(draft.trimmedBody, 'Pintamos con témperas');
    });

    test('is for families when one or more child ids are present', () {
      const single = PostDraft(childIds: ['mateo-fernandez']);
      const several = PostDraft(
        childIds: ['mateo-fernandez', 'sofia-mendez'],
      );

      expect(single.isForRoom, isFalse);
      expect(single.childIds, hasLength(1));
      expect(several.isForRoom, isFalse);
      expect(several.childIds, hasLength(2));
    });
  });
}
