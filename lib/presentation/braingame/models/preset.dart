// model untuk preset game settings
import 'dart:convert';

class Preset {
  String id;
  String name;
  int nLevel; // 1-100, berapa langkah sebelumnya yang diingat
  int targetWins; // 0 = unlimited, >0 = game selesai saat tercapai
  int timeLimitSeconds; // 0 = unlimited, >0 = game selesai saat waktu habis
  int sessionLength; // jumlah trial per sesi (10-9999)
  double intervalSeconds; // 1.0 - 10.0 detik, atau 0 = manual advance

  Preset({
    required this.id,
    required this.name,
    this.nLevel = 2,
    this.targetWins = 10,
    this.timeLimitSeconds = 0,
    this.sessionLength = 20,
    this.intervalSeconds = 5.0,
  });

  Preset copyWith({
    String? id,
    String? name,
    int? nLevel,
    int? targetWins,
    int? timeLimitSeconds,
    int? sessionLength,
    double? intervalSeconds,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      nLevel: nLevel ?? this.nLevel,
      targetWins: targetWins ?? this.targetWins,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      sessionLength: sessionLength ?? this.sessionLength,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nLevel': nLevel,
    'targetWins': targetWins,
    'timeLimitSeconds': timeLimitSeconds,
    'sessionLength': sessionLength,
    'intervalSeconds': intervalSeconds,
  };

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
    id: json['id'] as String,
    name: json['name'] as String,
    nLevel: json['nLevel'] as int,
    targetWins: json['targetWins'] as int,
    timeLimitSeconds: json['timeLimitSeconds'] as int,
    sessionLength: json['sessionLength'] as int,
    intervalSeconds: (json['intervalSeconds'] as num?)?.toDouble() ?? 5.0,
  );

  String toJsonString() => jsonEncode(toJson());

  factory Preset.fromJsonString(String jsonString) =>
      Preset.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  // default preset
  factory Preset.defaultPreset(int index) => Preset(
    id: 'preset_$index',
    name: 'Preset $index',
    nLevel: 2,
    targetWins: 10,
    timeLimitSeconds: 0,
    sessionLength: 20,
    intervalSeconds: 5.0,
  );
}
