
class SettingLogic {
  bool muteNotifications = false;
  bool appAppearance = false;

  void toggleNotifications() {
    muteNotifications = !muteNotifications;
  }

  void toggleAppAppearance() {
    appAppearance = !appAppearance;
  }

  Map<String, bool> getSettings() {
    return {
      'muteNotifications': muteNotifications,
      'appAppearance': appAppearance,
    };
  }

  void updateSettings(bool notifications, bool appearance) {
    muteNotifications = notifications;
    appAppearance = appearance;
  }
}
