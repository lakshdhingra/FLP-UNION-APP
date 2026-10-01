class StateEngineerCount {
  final String state;
  final int count;

  const StateEngineerCount({
    required this.state,
    required this.count,
  });

  factory StateEngineerCount.fromJson(Map<String, dynamic> json) {
    return StateEngineerCount(
      state: json['state'] ?? json['name'] ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'state': state,
        'count': count,
      };
}

class AdminSummaryDto {
  final int states;
  final int managers;
  final int engineers;
  final int openIssues;
  final int activeEngineers;
  final int inactiveEngineers;
  final List<StateEngineerCount> engineersByState;

  const AdminSummaryDto({
    required this.states,
    required this.managers,
    required this.engineers,
    required this.openIssues,
    required this.activeEngineers,
    required this.inactiveEngineers,
    required this.engineersByState,
  });

  factory AdminSummaryDto.fromJson(Map<String, dynamic> json) {
    List<StateEngineerCount> stateCounts = [];
    if (json['engineersByState'] is List) {
      stateCounts = (json['engineersByState'] as List)
          .map((e) => StateEngineerCount.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return AdminSummaryDto(
      states: (json['states'] as num?)?.toInt() ?? 0,
      managers: (json['managers'] as num?)?.toInt() ?? 0,
      engineers: (json['engineers'] as num?)?.toInt() ?? 0,
      openIssues: (json['openIssues'] as num?)?.toInt() ?? 0,
      activeEngineers: (json['activeEngineers'] as num?)?.toInt() ?? 0,
      inactiveEngineers: (json['inactiveEngineers'] as num?)?.toInt() ?? 0,
      engineersByState: stateCounts,
    );
  }

  Map<String, dynamic> toJson() => {
        'states': states,
        'managers': managers,
        'engineers': engineers,
        'openIssues': openIssues,
        'activeEngineers': activeEngineers,
        'inactiveEngineers': inactiveEngineers,
        'engineersByState': engineersByState.map((e) => e.toJson()).toList(),
      };
}
