import 'dart:math';

import 'package:flutter_application_4patrol/services/campaign_feed_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dice', () {
    test('1D10 always yields one die between 1 and 10', () {
      final rng = Random(1);
      for (var i = 0; i < 5000; i++) {
        final d = CampaignFeedService.rollDice(DiceKind.d10, rng);
        expect(d.length, 1);
        expect(d.single, inInclusiveRange(1, 10));
      }
    });

    test('2D10 always yields two dice between 1 and 10', () {
      final rng = Random(2);
      for (var i = 0; i < 5000; i++) {
        final d = CampaignFeedService.rollDice(DiceKind.twoD10, rng);
        expect(d.length, 2);
        expect(d, everyElement(inInclusiveRange(1, 10)));
      }
    });

    test('every face appears (no dead faces)', () {
      final rng = Random(3);
      final d10 = <int>{};
      for (var i = 0; i < 5000; i++) {
        d10.addAll(CampaignFeedService.rollDice(DiceKind.d10, rng));
        d10.addAll(CampaignFeedService.rollDice(DiceKind.twoD10, rng));
      }
      expect(d10, {for (var i = 1; i <= 10; i++) i});
    });

    test('rolls are roughly uniform', () {
      final rng = Random(4);
      final counts = List.filled(11, 0);
      const n = 100000;
      for (var i = 0; i < n; i++) {
        counts[CampaignFeedService.rollDice(DiceKind.d10, rng).single]++;
      }
      for (var f = 1; f <= 10; f++) {
        expect(counts[f] / n, closeTo(0.1, 0.01));
      }
    });
  });

  group('file validation', () {
    test('allows png, jpg, jpeg, pdf in any case', () {
      for (final n in ['a.png', 'a.JPG', 'a.jpeg', 'x.y.PDF']) {
        expect(CampaignFeedService.validateFile(n, 100), isNull, reason: n);
      }
    });

    test('rejects other types and extensionless names', () {
      for (final n in ['a.exe', 'a.html', 'a.svg', 'a.png.exe', 'png', 'a.']) {
        expect(CampaignFeedService.validateFile(n, 100), isNotNull, reason: n);
      }
    });

    test('enforces size limits at the boundary', () {
      expect(CampaignFeedService.validateFile('a.png', 0), isNotNull);
      expect(CampaignFeedService.validateFile('a.png', 5 * 1024 * 1024), isNull);
      expect(
        CampaignFeedService.validateFile('a.png', 5 * 1024 * 1024 + 1),
        isNotNull,
      );
    });

    test('safeFileName strips path and unsafe characters', () {
      expect(CampaignFeedService.safeFileName('../a b/c?.png'), '.._a_b_c_.png');
      expect(CampaignFeedService.safeFileName('ok-1_2.png'), 'ok-1_2.png');
    });

    test('content types match extension', () {
      expect(CampaignFeedService.contentTypeFor('a.jpg'), 'image/jpeg');
      expect(CampaignFeedService.contentTypeFor('a.pdf'), 'application/pdf');
    });
  });
}
