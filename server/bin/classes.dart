const SESSION_STATUS_LOBBY = 'LOBBY';
const SESSION_STATUS_ACTIVE = 'ACTIVE';
const SESSION_STATUS_FINISHED = 'FINISHED';

class Session {
  final int dbId;
  final int quizId;
  final String quizName;
  final int hostUserId;
  String status;
  String hostSocketID;
  List<Participant> participants;

  Session({
    required this.dbId,
    required this.quizId,
    required this.quizName,
    required this.hostUserId,
    required this.hostSocketID,
    this.status = 'LOBBY',
    this.participants = const [],
  });

  bool statusLobby() => status == SESSION_STATUS_LOBBY;
  bool statusActive() => status == SESSION_STATUS_ACTIVE;
  bool statusFinished() => status == SESSION_STATUS_FINISHED;
}

class Participant {
  String socketId; 
  final int dbId;
  final String name;
  final String securityCode;
  bool isOnline;

  Participant({
    required this.socketId,
    required this.dbId,
    required this.name,
    required this.securityCode,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'participant_id': dbId,
  };
}