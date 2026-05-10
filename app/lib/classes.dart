class Participant {
  bool isOnline;

  Participant({
    required this.isOnline,
  });
}

class Room {
  final int quizId;
  final String pin;
  final String name;
  late Settings settings;
  Map<String, dynamic> participants = {};

  Room({
    required this.pin,
    required this.name,
    required this.quizId,
  }){
    settings = Settings();
  }

  int get numOnlinePlayers => participants.values.where((p) => p.isOnline).length;
}

class Settings {
  bool hostControlled;
  bool allowLateEntry;
  bool showLeaderboardBetweenQuestions;
  bool showAnswers;
  int? maxClients;
  int? duration;
  bool startAtHost;

  Settings({
    this.hostControlled = false,
    this.allowLateEntry = false,
    this.showLeaderboardBetweenQuestions = false,
    this.showAnswers = false,
    this.maxClients,
    this.duration,
    this.startAtHost = true,
  });
  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  void loadJson(Map<String, dynamic> data) {
    hostControlled = _toBool(data['host_controlled']);
    allowLateEntry = _toBool(data['allow_late_entry']);
    showLeaderboardBetweenQuestions = _toBool(data['show_leaderboard_between_questions']);
    showAnswers = _toBool(data['show_answers']);
    maxClients = data['max_clients'];
    duration = data['duration'];
    startAtHost = _toBool(data['start_at_host']);
  }

  Map<String, dynamic> toJson() => {
    'host_controlled': hostControlled,
    'allow_late_entry': allowLateEntry,
    'show_leaderboard_between_questions': showLeaderboardBetweenQuestions,
    'show_answers': showAnswers,
    'max_clients': maxClients,
    'duration': duration,
    'start_at_host': startAtHost,
  };
}