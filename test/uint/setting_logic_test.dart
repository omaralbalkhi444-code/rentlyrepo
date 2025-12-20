
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/setting_logic.dart';


void main() {
  group('SettingLogic', () {
    late SettingLogic logic;

    setUp(() {
      logic = SettingLogic();
    });

    test('Initial state is false', () {
      expect(logic.muteNotifications, false);
      expect(logic.appAppearance, false);
    });

    test('toggleNotifications changes state', () {
      logic.toggleNotifications();
      expect(logic.muteNotifications, true);
      
      logic.toggleNotifications();
      expect(logic.muteNotifications, false);
    });

    test('toggleAppAppearance changes state', () {
      logic.toggleAppAppearance();
      expect(logic.appAppearance, true);
      
      logic.toggleAppAppearance();
      expect(logic.appAppearance, false);
    });

    test('getSettings returns correct map', () {
      final settings = logic.getSettings();
      expect(settings['muteNotifications'], false);
      expect(settings['appAppearance'], false);
      
      logic.toggleNotifications();
      final newSettings = logic.getSettings();
      expect(newSettings['muteNotifications'], true);
      expect(newSettings['appAppearance'], false);
    });

    test('updateSettings updates both values', () {
      logic.updateSettings(true, false);
      expect(logic.muteNotifications, true);
      expect(logic.appAppearance, false);
      
      logic.updateSettings(false, true);
      expect(logic.muteNotifications, false);
      expect(logic.appAppearance, true);
      
      logic.updateSettings(true, true);
      expect(logic.muteNotifications, true);
      expect(logic.appAppearance, true);
    });

    test('Independent toggling', () {
      logic.toggleNotifications();
      expect(logic.muteNotifications, true);
      expect(logic.appAppearance, false);
      
      logic.toggleAppAppearance();
      expect(logic.muteNotifications, true);
      expect(logic.appAppearance, true);
      
      logic.toggleNotifications();
      expect(logic.muteNotifications, false);
      expect(logic.appAppearance, true);
    });
  });
}
