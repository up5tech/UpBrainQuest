// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppMetadataEntriesTable extends AppMetadataEntries
    with TableInfo<$AppMetadataEntriesTable, AppMetadataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppMetadataEntriesTable createAlias(String alias) {
    return $AppMetadataEntriesTable(attachedDatabase, alias);
  }
}

class AppMetadataEntry extends DataClass
    implements Insertable<AppMetadataEntry> {
  /// Primary key of the metadata row.
  final String key;

  /// Free-form value stored for [key].
  final String value;

  /// When the row was last written (UTC).
  final DateTime updatedAt;
  const AppMetadataEntry({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppMetadataEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppMetadataEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppMetadataEntry copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AppMetadataEntry(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppMetadataEntry copyWithCompanion(AppMetadataEntriesCompanion data) {
    return AppMetadataEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppMetadataEntriesCompanion extends UpdateCompanion<AppMetadataEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppMetadataEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataEntriesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<AppMetadataEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppMetadataEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredCountMeta = const VerificationMeta(
    'answeredCount',
  );
  @override
  late final GeneratedColumn<int> answeredCount = GeneratedColumn<int>(
    'answered_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iqScoreMeta = const VerificationMeta(
    'iqScore',
  );
  @override
  late final GeneratedColumn<int> iqScore = GeneratedColumn<int>(
    'iq_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eqScoreMeta = const VerificationMeta(
    'eqScore',
  );
  @override
  late final GeneratedColumn<int> eqScore = GeneratedColumn<int>(
    'eq_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _earnedPointsMeta = const VerificationMeta(
    'earnedPoints',
  );
  @override
  late final GeneratedColumn<int> earnedPoints = GeneratedColumn<int>(
    'earned_points',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _possiblePointsMeta = const VerificationMeta(
    'possiblePoints',
  );
  @override
  late final GeneratedColumn<int> possiblePoints = GeneratedColumn<int>(
    'possible_points',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreAlgorithmVersionMeta =
      const VerificationMeta('scoreAlgorithmVersion');
  @override
  late final GeneratedColumn<int> scoreAlgorithmVersion = GeneratedColumn<int>(
    'score_algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentPackVersionMeta =
      const VerificationMeta('contentPackVersion');
  @override
  late final GeneratedColumn<String> contentPackVersion =
      GeneratedColumn<String>(
        'content_pack_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _dailyLocalDateMeta = const VerificationMeta(
    'dailyLocalDate',
  );
  @override
  late final GeneratedColumn<String> dailyLocalDate = GeneratedColumn<String>(
    'daily_local_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    status,
    startedAt,
    completedAt,
    durationMs,
    questionCount,
    answeredCount,
    iqScore,
    eqScore,
    earnedPoints,
    possiblePoints,
    scoreAlgorithmVersion,
    contentPackVersion,
    dailyLocalDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionCountMeta);
    }
    if (data.containsKey('answered_count')) {
      context.handle(
        _answeredCountMeta,
        answeredCount.isAcceptableOrUnknown(
          data['answered_count']!,
          _answeredCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answeredCountMeta);
    }
    if (data.containsKey('iq_score')) {
      context.handle(
        _iqScoreMeta,
        iqScore.isAcceptableOrUnknown(data['iq_score']!, _iqScoreMeta),
      );
    }
    if (data.containsKey('eq_score')) {
      context.handle(
        _eqScoreMeta,
        eqScore.isAcceptableOrUnknown(data['eq_score']!, _eqScoreMeta),
      );
    }
    if (data.containsKey('earned_points')) {
      context.handle(
        _earnedPointsMeta,
        earnedPoints.isAcceptableOrUnknown(
          data['earned_points']!,
          _earnedPointsMeta,
        ),
      );
    }
    if (data.containsKey('possible_points')) {
      context.handle(
        _possiblePointsMeta,
        possiblePoints.isAcceptableOrUnknown(
          data['possible_points']!,
          _possiblePointsMeta,
        ),
      );
    }
    if (data.containsKey('score_algorithm_version')) {
      context.handle(
        _scoreAlgorithmVersionMeta,
        scoreAlgorithmVersion.isAcceptableOrUnknown(
          data['score_algorithm_version']!,
          _scoreAlgorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scoreAlgorithmVersionMeta);
    }
    if (data.containsKey('content_pack_version')) {
      context.handle(
        _contentPackVersionMeta,
        contentPackVersion.isAcceptableOrUnknown(
          data['content_pack_version']!,
          _contentPackVersionMeta,
        ),
      );
    }
    if (data.containsKey('daily_local_date')) {
      context.handle(
        _dailyLocalDateMeta,
        dailyLocalDate.isAcceptableOrUnknown(
          data['daily_local_date']!,
          _dailyLocalDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      answeredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_count'],
      )!,
      iqScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iq_score'],
      ),
      eqScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eq_score'],
      ),
      earnedPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_points'],
      ),
      possiblePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}possible_points'],
      ),
      scoreAlgorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_algorithm_version'],
      )!,
      contentPackVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_pack_version'],
      )!,
      dailyLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_local_date'],
      ),
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSession extends DataClass implements Insertable<GameSession> {
  /// Locally generated primary key.
  final int id;

  /// Stable mode key (`quick`, `iq`, `eq`, `puzzle`, `daily`).
  final String mode;

  /// `completed` or `abandoned`; unfinished sessions are never scored as
  /// completed (PLAN §7.2).
  final String status;

  /// Session start, stored in UTC (PLAN §7.3).
  final DateTime startedAt;

  /// Completion time in UTC, nullable while a session is unfinished.
  final DateTime? completedAt;

  /// Elapsed duration in milliseconds, when known.
  final int? durationMs;
  final int questionCount;
  final int answeredCount;

  /// In-game IQ Challenge Score (0–100), or `null` when not applicable.
  final int? iqScore;

  /// In-game EQ Practice Score (0–100), or `null` when not applicable.
  final int? eqScore;
  final int? earnedPoints;
  final int? possiblePoints;

  /// Score algorithm version so historical scores stay interpretable
  /// (PLAN §4.5).
  final int scoreAlgorithmVersion;
  final String contentPackVersion;

  /// ISO local date for daily challenges, or `null` for other modes.
  final String? dailyLocalDate;
  const GameSession({
    required this.id,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.durationMs,
    required this.questionCount,
    required this.answeredCount,
    this.iqScore,
    this.eqScore,
    this.earnedPoints,
    this.possiblePoints,
    required this.scoreAlgorithmVersion,
    required this.contentPackVersion,
    this.dailyLocalDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mode'] = Variable<String>(mode);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['question_count'] = Variable<int>(questionCount);
    map['answered_count'] = Variable<int>(answeredCount);
    if (!nullToAbsent || iqScore != null) {
      map['iq_score'] = Variable<int>(iqScore);
    }
    if (!nullToAbsent || eqScore != null) {
      map['eq_score'] = Variable<int>(eqScore);
    }
    if (!nullToAbsent || earnedPoints != null) {
      map['earned_points'] = Variable<int>(earnedPoints);
    }
    if (!nullToAbsent || possiblePoints != null) {
      map['possible_points'] = Variable<int>(possiblePoints);
    }
    map['score_algorithm_version'] = Variable<int>(scoreAlgorithmVersion);
    map['content_pack_version'] = Variable<String>(contentPackVersion);
    if (!nullToAbsent || dailyLocalDate != null) {
      map['daily_local_date'] = Variable<String>(dailyLocalDate);
    }
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      id: Value(id),
      mode: Value(mode),
      status: Value(status),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      questionCount: Value(questionCount),
      answeredCount: Value(answeredCount),
      iqScore: iqScore == null && nullToAbsent
          ? const Value.absent()
          : Value(iqScore),
      eqScore: eqScore == null && nullToAbsent
          ? const Value.absent()
          : Value(eqScore),
      earnedPoints: earnedPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(earnedPoints),
      possiblePoints: possiblePoints == null && nullToAbsent
          ? const Value.absent()
          : Value(possiblePoints),
      scoreAlgorithmVersion: Value(scoreAlgorithmVersion),
      contentPackVersion: Value(contentPackVersion),
      dailyLocalDate: dailyLocalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyLocalDate),
    );
  }

  factory GameSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      id: serializer.fromJson<int>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      answeredCount: serializer.fromJson<int>(json['answeredCount']),
      iqScore: serializer.fromJson<int?>(json['iqScore']),
      eqScore: serializer.fromJson<int?>(json['eqScore']),
      earnedPoints: serializer.fromJson<int?>(json['earnedPoints']),
      possiblePoints: serializer.fromJson<int?>(json['possiblePoints']),
      scoreAlgorithmVersion: serializer.fromJson<int>(
        json['scoreAlgorithmVersion'],
      ),
      contentPackVersion: serializer.fromJson<String>(
        json['contentPackVersion'],
      ),
      dailyLocalDate: serializer.fromJson<String?>(json['dailyLocalDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(mode),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'durationMs': serializer.toJson<int?>(durationMs),
      'questionCount': serializer.toJson<int>(questionCount),
      'answeredCount': serializer.toJson<int>(answeredCount),
      'iqScore': serializer.toJson<int?>(iqScore),
      'eqScore': serializer.toJson<int?>(eqScore),
      'earnedPoints': serializer.toJson<int?>(earnedPoints),
      'possiblePoints': serializer.toJson<int?>(possiblePoints),
      'scoreAlgorithmVersion': serializer.toJson<int>(scoreAlgorithmVersion),
      'contentPackVersion': serializer.toJson<String>(contentPackVersion),
      'dailyLocalDate': serializer.toJson<String?>(dailyLocalDate),
    };
  }

  GameSession copyWith({
    int? id,
    String? mode,
    String? status,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    int? questionCount,
    int? answeredCount,
    Value<int?> iqScore = const Value.absent(),
    Value<int?> eqScore = const Value.absent(),
    Value<int?> earnedPoints = const Value.absent(),
    Value<int?> possiblePoints = const Value.absent(),
    int? scoreAlgorithmVersion,
    String? contentPackVersion,
    Value<String?> dailyLocalDate = const Value.absent(),
  }) => GameSession(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    questionCount: questionCount ?? this.questionCount,
    answeredCount: answeredCount ?? this.answeredCount,
    iqScore: iqScore.present ? iqScore.value : this.iqScore,
    eqScore: eqScore.present ? eqScore.value : this.eqScore,
    earnedPoints: earnedPoints.present ? earnedPoints.value : this.earnedPoints,
    possiblePoints: possiblePoints.present
        ? possiblePoints.value
        : this.possiblePoints,
    scoreAlgorithmVersion: scoreAlgorithmVersion ?? this.scoreAlgorithmVersion,
    contentPackVersion: contentPackVersion ?? this.contentPackVersion,
    dailyLocalDate: dailyLocalDate.present
        ? dailyLocalDate.value
        : this.dailyLocalDate,
  );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      answeredCount: data.answeredCount.present
          ? data.answeredCount.value
          : this.answeredCount,
      iqScore: data.iqScore.present ? data.iqScore.value : this.iqScore,
      eqScore: data.eqScore.present ? data.eqScore.value : this.eqScore,
      earnedPoints: data.earnedPoints.present
          ? data.earnedPoints.value
          : this.earnedPoints,
      possiblePoints: data.possiblePoints.present
          ? data.possiblePoints.value
          : this.possiblePoints,
      scoreAlgorithmVersion: data.scoreAlgorithmVersion.present
          ? data.scoreAlgorithmVersion.value
          : this.scoreAlgorithmVersion,
      contentPackVersion: data.contentPackVersion.present
          ? data.contentPackVersion.value
          : this.contentPackVersion,
      dailyLocalDate: data.dailyLocalDate.present
          ? data.dailyLocalDate.value
          : this.dailyLocalDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('questionCount: $questionCount, ')
          ..write('answeredCount: $answeredCount, ')
          ..write('iqScore: $iqScore, ')
          ..write('eqScore: $eqScore, ')
          ..write('earnedPoints: $earnedPoints, ')
          ..write('possiblePoints: $possiblePoints, ')
          ..write('scoreAlgorithmVersion: $scoreAlgorithmVersion, ')
          ..write('contentPackVersion: $contentPackVersion, ')
          ..write('dailyLocalDate: $dailyLocalDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    status,
    startedAt,
    completedAt,
    durationMs,
    questionCount,
    answeredCount,
    iqScore,
    eqScore,
    earnedPoints,
    possiblePoints,
    scoreAlgorithmVersion,
    contentPackVersion,
    dailyLocalDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.durationMs == this.durationMs &&
          other.questionCount == this.questionCount &&
          other.answeredCount == this.answeredCount &&
          other.iqScore == this.iqScore &&
          other.eqScore == this.eqScore &&
          other.earnedPoints == this.earnedPoints &&
          other.possiblePoints == this.possiblePoints &&
          other.scoreAlgorithmVersion == this.scoreAlgorithmVersion &&
          other.contentPackVersion == this.contentPackVersion &&
          other.dailyLocalDate == this.dailyLocalDate);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<int> id;
  final Value<String> mode;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int?> durationMs;
  final Value<int> questionCount;
  final Value<int> answeredCount;
  final Value<int?> iqScore;
  final Value<int?> eqScore;
  final Value<int?> earnedPoints;
  final Value<int?> possiblePoints;
  final Value<int> scoreAlgorithmVersion;
  final Value<String> contentPackVersion;
  final Value<String?> dailyLocalDate;
  const GameSessionsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.answeredCount = const Value.absent(),
    this.iqScore = const Value.absent(),
    this.eqScore = const Value.absent(),
    this.earnedPoints = const Value.absent(),
    this.possiblePoints = const Value.absent(),
    this.scoreAlgorithmVersion = const Value.absent(),
    this.contentPackVersion = const Value.absent(),
    this.dailyLocalDate = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String mode,
    this.status = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int questionCount,
    required int answeredCount,
    this.iqScore = const Value.absent(),
    this.eqScore = const Value.absent(),
    this.earnedPoints = const Value.absent(),
    this.possiblePoints = const Value.absent(),
    required int scoreAlgorithmVersion,
    this.contentPackVersion = const Value.absent(),
    this.dailyLocalDate = const Value.absent(),
  }) : mode = Value(mode),
       startedAt = Value(startedAt),
       questionCount = Value(questionCount),
       answeredCount = Value(answeredCount),
       scoreAlgorithmVersion = Value(scoreAlgorithmVersion);
  static Insertable<GameSession> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? durationMs,
    Expression<int>? questionCount,
    Expression<int>? answeredCount,
    Expression<int>? iqScore,
    Expression<int>? eqScore,
    Expression<int>? earnedPoints,
    Expression<int>? possiblePoints,
    Expression<int>? scoreAlgorithmVersion,
    Expression<String>? contentPackVersion,
    Expression<String>? dailyLocalDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (questionCount != null) 'question_count': questionCount,
      if (answeredCount != null) 'answered_count': answeredCount,
      if (iqScore != null) 'iq_score': iqScore,
      if (eqScore != null) 'eq_score': eqScore,
      if (earnedPoints != null) 'earned_points': earnedPoints,
      if (possiblePoints != null) 'possible_points': possiblePoints,
      if (scoreAlgorithmVersion != null)
        'score_algorithm_version': scoreAlgorithmVersion,
      if (contentPackVersion != null)
        'content_pack_version': contentPackVersion,
      if (dailyLocalDate != null) 'daily_local_date': dailyLocalDate,
    });
  }

  GameSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? mode,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int?>? durationMs,
    Value<int>? questionCount,
    Value<int>? answeredCount,
    Value<int?>? iqScore,
    Value<int?>? eqScore,
    Value<int?>? earnedPoints,
    Value<int?>? possiblePoints,
    Value<int>? scoreAlgorithmVersion,
    Value<String>? contentPackVersion,
    Value<String?>? dailyLocalDate,
  }) {
    return GameSessionsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMs: durationMs ?? this.durationMs,
      questionCount: questionCount ?? this.questionCount,
      answeredCount: answeredCount ?? this.answeredCount,
      iqScore: iqScore ?? this.iqScore,
      eqScore: eqScore ?? this.eqScore,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      possiblePoints: possiblePoints ?? this.possiblePoints,
      scoreAlgorithmVersion:
          scoreAlgorithmVersion ?? this.scoreAlgorithmVersion,
      contentPackVersion: contentPackVersion ?? this.contentPackVersion,
      dailyLocalDate: dailyLocalDate ?? this.dailyLocalDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (answeredCount.present) {
      map['answered_count'] = Variable<int>(answeredCount.value);
    }
    if (iqScore.present) {
      map['iq_score'] = Variable<int>(iqScore.value);
    }
    if (eqScore.present) {
      map['eq_score'] = Variable<int>(eqScore.value);
    }
    if (earnedPoints.present) {
      map['earned_points'] = Variable<int>(earnedPoints.value);
    }
    if (possiblePoints.present) {
      map['possible_points'] = Variable<int>(possiblePoints.value);
    }
    if (scoreAlgorithmVersion.present) {
      map['score_algorithm_version'] = Variable<int>(
        scoreAlgorithmVersion.value,
      );
    }
    if (contentPackVersion.present) {
      map['content_pack_version'] = Variable<String>(contentPackVersion.value);
    }
    if (dailyLocalDate.present) {
      map['daily_local_date'] = Variable<String>(dailyLocalDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('questionCount: $questionCount, ')
          ..write('answeredCount: $answeredCount, ')
          ..write('iqScore: $iqScore, ')
          ..write('eqScore: $eqScore, ')
          ..write('earnedPoints: $earnedPoints, ')
          ..write('possiblePoints: $possiblePoints, ')
          ..write('scoreAlgorithmVersion: $scoreAlgorithmVersion, ')
          ..write('contentPackVersion: $contentPackVersion, ')
          ..write('dailyLocalDate: $dailyLocalDate')
          ..write(')'))
        .toString();
  }
}

class $QuestionAttemptsTable extends QuestionAttempts
    with TableInfo<$QuestionAttemptsTable, QuestionAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionOrderMeta = const VerificationMeta(
    'questionOrder',
  );
  @override
  late final GeneratedColumn<int> questionOrder = GeneratedColumn<int>(
    'question_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submittedAnswerJsonMeta =
      const VerificationMeta('submittedAnswerJson');
  @override
  late final GeneratedColumn<String> submittedAnswerJson =
      GeneratedColumn<String>(
        'submitted_answer_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('null'),
      );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _earnedPointsMeta = const VerificationMeta(
    'earnedPoints',
  );
  @override
  late final GeneratedColumn<int> earnedPoints = GeneratedColumn<int>(
    'earned_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _possiblePointsMeta = const VerificationMeta(
    'possiblePoints',
  );
  @override
  late final GeneratedColumn<int> possiblePoints = GeneratedColumn<int>(
    'possible_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rubricScoresJsonMeta = const VerificationMeta(
    'rubricScoresJson',
  );
  @override
  late final GeneratedColumn<String> rubricScoresJson = GeneratedColumn<String>(
    'rubric_scores_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hintUsedMeta = const VerificationMeta(
    'hintUsed',
  );
  @override
  late final GeneratedColumn<bool> hintUsed = GeneratedColumn<bool>(
    'hint_used',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hint_used" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    questionId,
    domain,
    skill,
    questionOrder,
    submittedAnswerJson,
    isCorrect,
    earnedPoints,
    possiblePoints,
    rubricScoresJson,
    elapsedMs,
    hintUsed,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('skill')) {
      context.handle(
        _skillMeta,
        skill.isAcceptableOrUnknown(data['skill']!, _skillMeta),
      );
    } else if (isInserting) {
      context.missing(_skillMeta);
    }
    if (data.containsKey('question_order')) {
      context.handle(
        _questionOrderMeta,
        questionOrder.isAcceptableOrUnknown(
          data['question_order']!,
          _questionOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionOrderMeta);
    }
    if (data.containsKey('submitted_answer_json')) {
      context.handle(
        _submittedAnswerJsonMeta,
        submittedAnswerJson.isAcceptableOrUnknown(
          data['submitted_answer_json']!,
          _submittedAnswerJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('earned_points')) {
      context.handle(
        _earnedPointsMeta,
        earnedPoints.isAcceptableOrUnknown(
          data['earned_points']!,
          _earnedPointsMeta,
        ),
      );
    }
    if (data.containsKey('possible_points')) {
      context.handle(
        _possiblePointsMeta,
        possiblePoints.isAcceptableOrUnknown(
          data['possible_points']!,
          _possiblePointsMeta,
        ),
      );
    }
    if (data.containsKey('rubric_scores_json')) {
      context.handle(
        _rubricScoresJsonMeta,
        rubricScoresJson.isAcceptableOrUnknown(
          data['rubric_scores_json']!,
          _rubricScoresJsonMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    }
    if (data.containsKey('hint_used')) {
      context.handle(
        _hintUsedMeta,
        hintUsed.isAcceptableOrUnknown(data['hint_used']!, _hintUsedMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      skill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill'],
      )!,
      questionOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_order'],
      )!,
      submittedAnswerJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submitted_answer_json'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      ),
      earnedPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_points'],
      )!,
      possiblePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}possible_points'],
      )!,
      rubricScoresJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rubric_scores_json'],
      ),
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      ),
      hintUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hint_used'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      ),
    );
  }

  @override
  $QuestionAttemptsTable createAlias(String alias) {
    return $QuestionAttemptsTable(attachedDatabase, alias);
  }
}

class QuestionAttempt extends DataClass implements Insertable<QuestionAttempt> {
  final int id;

  /// Owning session; deleting the session removes its attempts.
  final int sessionId;

  /// Stable question ID from the bundled content.
  final String questionId;

  /// Domain and skill snapshots for historical reporting.
  final String domain;
  final String skill;

  /// Zero-based order within the session.
  final int questionOrder;

  /// Typed answer snapshot encoded as JSON (never free-form personal text).
  final String submittedAnswerJson;

  /// `null` for EQ items (non-binary) or unattempted questions.
  final bool? isCorrect;
  final int earnedPoints;
  final int possiblePoints;

  /// Optional EQ dimension scores encoded as JSON.
  final String? rubricScoresJson;
  final int? elapsedMs;
  final bool hintUsed;
  final DateTime? answeredAt;
  const QuestionAttempt({
    required this.id,
    required this.sessionId,
    required this.questionId,
    required this.domain,
    required this.skill,
    required this.questionOrder,
    required this.submittedAnswerJson,
    this.isCorrect,
    required this.earnedPoints,
    required this.possiblePoints,
    this.rubricScoresJson,
    this.elapsedMs,
    required this.hintUsed,
    this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['question_id'] = Variable<String>(questionId);
    map['domain'] = Variable<String>(domain);
    map['skill'] = Variable<String>(skill);
    map['question_order'] = Variable<int>(questionOrder);
    map['submitted_answer_json'] = Variable<String>(submittedAnswerJson);
    if (!nullToAbsent || isCorrect != null) {
      map['is_correct'] = Variable<bool>(isCorrect);
    }
    map['earned_points'] = Variable<int>(earnedPoints);
    map['possible_points'] = Variable<int>(possiblePoints);
    if (!nullToAbsent || rubricScoresJson != null) {
      map['rubric_scores_json'] = Variable<String>(rubricScoresJson);
    }
    if (!nullToAbsent || elapsedMs != null) {
      map['elapsed_ms'] = Variable<int>(elapsedMs);
    }
    map['hint_used'] = Variable<bool>(hintUsed);
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    return map;
  }

  QuestionAttemptsCompanion toCompanion(bool nullToAbsent) {
    return QuestionAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      questionId: Value(questionId),
      domain: Value(domain),
      skill: Value(skill),
      questionOrder: Value(questionOrder),
      submittedAnswerJson: Value(submittedAnswerJson),
      isCorrect: isCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(isCorrect),
      earnedPoints: Value(earnedPoints),
      possiblePoints: Value(possiblePoints),
      rubricScoresJson: rubricScoresJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rubricScoresJson),
      elapsedMs: elapsedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(elapsedMs),
      hintUsed: Value(hintUsed),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
    );
  }

  factory QuestionAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionAttempt(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      domain: serializer.fromJson<String>(json['domain']),
      skill: serializer.fromJson<String>(json['skill']),
      questionOrder: serializer.fromJson<int>(json['questionOrder']),
      submittedAnswerJson: serializer.fromJson<String>(
        json['submittedAnswerJson'],
      ),
      isCorrect: serializer.fromJson<bool?>(json['isCorrect']),
      earnedPoints: serializer.fromJson<int>(json['earnedPoints']),
      possiblePoints: serializer.fromJson<int>(json['possiblePoints']),
      rubricScoresJson: serializer.fromJson<String?>(json['rubricScoresJson']),
      elapsedMs: serializer.fromJson<int?>(json['elapsedMs']),
      hintUsed: serializer.fromJson<bool>(json['hintUsed']),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'questionId': serializer.toJson<String>(questionId),
      'domain': serializer.toJson<String>(domain),
      'skill': serializer.toJson<String>(skill),
      'questionOrder': serializer.toJson<int>(questionOrder),
      'submittedAnswerJson': serializer.toJson<String>(submittedAnswerJson),
      'isCorrect': serializer.toJson<bool?>(isCorrect),
      'earnedPoints': serializer.toJson<int>(earnedPoints),
      'possiblePoints': serializer.toJson<int>(possiblePoints),
      'rubricScoresJson': serializer.toJson<String?>(rubricScoresJson),
      'elapsedMs': serializer.toJson<int?>(elapsedMs),
      'hintUsed': serializer.toJson<bool>(hintUsed),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
    };
  }

  QuestionAttempt copyWith({
    int? id,
    int? sessionId,
    String? questionId,
    String? domain,
    String? skill,
    int? questionOrder,
    String? submittedAnswerJson,
    Value<bool?> isCorrect = const Value.absent(),
    int? earnedPoints,
    int? possiblePoints,
    Value<String?> rubricScoresJson = const Value.absent(),
    Value<int?> elapsedMs = const Value.absent(),
    bool? hintUsed,
    Value<DateTime?> answeredAt = const Value.absent(),
  }) => QuestionAttempt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    questionId: questionId ?? this.questionId,
    domain: domain ?? this.domain,
    skill: skill ?? this.skill,
    questionOrder: questionOrder ?? this.questionOrder,
    submittedAnswerJson: submittedAnswerJson ?? this.submittedAnswerJson,
    isCorrect: isCorrect.present ? isCorrect.value : this.isCorrect,
    earnedPoints: earnedPoints ?? this.earnedPoints,
    possiblePoints: possiblePoints ?? this.possiblePoints,
    rubricScoresJson: rubricScoresJson.present
        ? rubricScoresJson.value
        : this.rubricScoresJson,
    elapsedMs: elapsedMs.present ? elapsedMs.value : this.elapsedMs,
    hintUsed: hintUsed ?? this.hintUsed,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
  );
  QuestionAttempt copyWithCompanion(QuestionAttemptsCompanion data) {
    return QuestionAttempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      domain: data.domain.present ? data.domain.value : this.domain,
      skill: data.skill.present ? data.skill.value : this.skill,
      questionOrder: data.questionOrder.present
          ? data.questionOrder.value
          : this.questionOrder,
      submittedAnswerJson: data.submittedAnswerJson.present
          ? data.submittedAnswerJson.value
          : this.submittedAnswerJson,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      earnedPoints: data.earnedPoints.present
          ? data.earnedPoints.value
          : this.earnedPoints,
      possiblePoints: data.possiblePoints.present
          ? data.possiblePoints.value
          : this.possiblePoints,
      rubricScoresJson: data.rubricScoresJson.present
          ? data.rubricScoresJson.value
          : this.rubricScoresJson,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      hintUsed: data.hintUsed.present ? data.hintUsed.value : this.hintUsed,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionAttempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('domain: $domain, ')
          ..write('skill: $skill, ')
          ..write('questionOrder: $questionOrder, ')
          ..write('submittedAnswerJson: $submittedAnswerJson, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('earnedPoints: $earnedPoints, ')
          ..write('possiblePoints: $possiblePoints, ')
          ..write('rubricScoresJson: $rubricScoresJson, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('hintUsed: $hintUsed, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    questionId,
    domain,
    skill,
    questionOrder,
    submittedAnswerJson,
    isCorrect,
    earnedPoints,
    possiblePoints,
    rubricScoresJson,
    elapsedMs,
    hintUsed,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionAttempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.questionId == this.questionId &&
          other.domain == this.domain &&
          other.skill == this.skill &&
          other.questionOrder == this.questionOrder &&
          other.submittedAnswerJson == this.submittedAnswerJson &&
          other.isCorrect == this.isCorrect &&
          other.earnedPoints == this.earnedPoints &&
          other.possiblePoints == this.possiblePoints &&
          other.rubricScoresJson == this.rubricScoresJson &&
          other.elapsedMs == this.elapsedMs &&
          other.hintUsed == this.hintUsed &&
          other.answeredAt == this.answeredAt);
}

class QuestionAttemptsCompanion extends UpdateCompanion<QuestionAttempt> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> questionId;
  final Value<String> domain;
  final Value<String> skill;
  final Value<int> questionOrder;
  final Value<String> submittedAnswerJson;
  final Value<bool?> isCorrect;
  final Value<int> earnedPoints;
  final Value<int> possiblePoints;
  final Value<String?> rubricScoresJson;
  final Value<int?> elapsedMs;
  final Value<bool> hintUsed;
  final Value<DateTime?> answeredAt;
  const QuestionAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.domain = const Value.absent(),
    this.skill = const Value.absent(),
    this.questionOrder = const Value.absent(),
    this.submittedAnswerJson = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.earnedPoints = const Value.absent(),
    this.possiblePoints = const Value.absent(),
    this.rubricScoresJson = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.hintUsed = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  QuestionAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String questionId,
    required String domain,
    required String skill,
    required int questionOrder,
    this.submittedAnswerJson = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.earnedPoints = const Value.absent(),
    this.possiblePoints = const Value.absent(),
    this.rubricScoresJson = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.hintUsed = const Value.absent(),
    this.answeredAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       questionId = Value(questionId),
       domain = Value(domain),
       skill = Value(skill),
       questionOrder = Value(questionOrder);
  static Insertable<QuestionAttempt> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? questionId,
    Expression<String>? domain,
    Expression<String>? skill,
    Expression<int>? questionOrder,
    Expression<String>? submittedAnswerJson,
    Expression<bool>? isCorrect,
    Expression<int>? earnedPoints,
    Expression<int>? possiblePoints,
    Expression<String>? rubricScoresJson,
    Expression<int>? elapsedMs,
    Expression<bool>? hintUsed,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (questionId != null) 'question_id': questionId,
      if (domain != null) 'domain': domain,
      if (skill != null) 'skill': skill,
      if (questionOrder != null) 'question_order': questionOrder,
      if (submittedAnswerJson != null)
        'submitted_answer_json': submittedAnswerJson,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (earnedPoints != null) 'earned_points': earnedPoints,
      if (possiblePoints != null) 'possible_points': possiblePoints,
      if (rubricScoresJson != null) 'rubric_scores_json': rubricScoresJson,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (hintUsed != null) 'hint_used': hintUsed,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  QuestionAttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? questionId,
    Value<String>? domain,
    Value<String>? skill,
    Value<int>? questionOrder,
    Value<String>? submittedAnswerJson,
    Value<bool?>? isCorrect,
    Value<int>? earnedPoints,
    Value<int>? possiblePoints,
    Value<String?>? rubricScoresJson,
    Value<int?>? elapsedMs,
    Value<bool>? hintUsed,
    Value<DateTime?>? answeredAt,
  }) {
    return QuestionAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionId: questionId ?? this.questionId,
      domain: domain ?? this.domain,
      skill: skill ?? this.skill,
      questionOrder: questionOrder ?? this.questionOrder,
      submittedAnswerJson: submittedAnswerJson ?? this.submittedAnswerJson,
      isCorrect: isCorrect ?? this.isCorrect,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      possiblePoints: possiblePoints ?? this.possiblePoints,
      rubricScoresJson: rubricScoresJson ?? this.rubricScoresJson,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      hintUsed: hintUsed ?? this.hintUsed,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (questionOrder.present) {
      map['question_order'] = Variable<int>(questionOrder.value);
    }
    if (submittedAnswerJson.present) {
      map['submitted_answer_json'] = Variable<String>(
        submittedAnswerJson.value,
      );
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (earnedPoints.present) {
      map['earned_points'] = Variable<int>(earnedPoints.value);
    }
    if (possiblePoints.present) {
      map['possible_points'] = Variable<int>(possiblePoints.value);
    }
    if (rubricScoresJson.present) {
      map['rubric_scores_json'] = Variable<String>(rubricScoresJson.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (hintUsed.present) {
      map['hint_used'] = Variable<bool>(hintUsed.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('domain: $domain, ')
          ..write('skill: $skill, ')
          ..write('questionOrder: $questionOrder, ')
          ..write('submittedAnswerJson: $submittedAnswerJson, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('earnedPoints: $earnedPoints, ')
          ..write('possiblePoints: $possiblePoints, ')
          ..write('rubricScoresJson: $rubricScoresJson, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('hintUsed: $hintUsed, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressValueMeta = const VerificationMeta(
    'progressValue',
  );
  @override
  late final GeneratedColumn<int> progressValue = GeneratedColumn<int>(
    'progress_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _definitionVersionMeta = const VerificationMeta(
    'definitionVersion',
  );
  @override
  late final GeneratedColumn<int> definitionVersion = GeneratedColumn<int>(
    'definition_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unlockedAt,
    progressValue,
    targetValue,
    definitionVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('progress_value')) {
      context.handle(
        _progressValueMeta,
        progressValue.isAcceptableOrUnknown(
          data['progress_value']!,
          _progressValueMeta,
        ),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('definition_version')) {
      context.handle(
        _definitionVersionMeta,
        definitionVersion.isAcceptableOrUnknown(
          data['definition_version']!,
          _definitionVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      progressValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_value'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_value'],
      )!,
      definitionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}definition_version'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  /// Stable achievement key (see `AchievementId.key`).
  final String id;

  /// When the achievement first unlocked, or `null` while locked.
  final DateTime? unlockedAt;

  /// Current local progress value.
  final int progressValue;

  /// Target value for progressive achievements.
  final int targetValue;

  /// Version of the achievement rules that produced this row.
  final int definitionVersion;
  const Achievement({
    required this.id,
    this.unlockedAt,
    required this.progressValue,
    required this.targetValue,
    required this.definitionVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['progress_value'] = Variable<int>(progressValue);
    map['target_value'] = Variable<int>(targetValue);
    map['definition_version'] = Variable<int>(definitionVersion);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      progressValue: Value(progressValue),
      targetValue: Value(targetValue),
      definitionVersion: Value(definitionVersion),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<String>(json['id']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      progressValue: serializer.fromJson<int>(json['progressValue']),
      targetValue: serializer.fromJson<int>(json['targetValue']),
      definitionVersion: serializer.fromJson<int>(json['definitionVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'progressValue': serializer.toJson<int>(progressValue),
      'targetValue': serializer.toJson<int>(targetValue),
      'definitionVersion': serializer.toJson<int>(definitionVersion),
    };
  }

  Achievement copyWith({
    String? id,
    Value<DateTime?> unlockedAt = const Value.absent(),
    int? progressValue,
    int? targetValue,
    int? definitionVersion,
  }) => Achievement(
    id: id ?? this.id,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    progressValue: progressValue ?? this.progressValue,
    targetValue: targetValue ?? this.targetValue,
    definitionVersion: definitionVersion ?? this.definitionVersion,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      progressValue: data.progressValue.present
          ? data.progressValue.value
          : this.progressValue,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      definitionVersion: data.definitionVersion.present
          ? data.definitionVersion.value
          : this.definitionVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progressValue: $progressValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('definitionVersion: $definitionVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unlockedAt,
    progressValue,
    targetValue,
    definitionVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.unlockedAt == this.unlockedAt &&
          other.progressValue == this.progressValue &&
          other.targetValue == this.targetValue &&
          other.definitionVersion == this.definitionVersion);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> id;
  final Value<DateTime?> unlockedAt;
  final Value<int> progressValue;
  final Value<int> targetValue;
  final Value<int> definitionVersion;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.progressValue = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.definitionVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    this.unlockedAt = const Value.absent(),
    this.progressValue = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.definitionVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Achievement> custom({
    Expression<String>? id,
    Expression<DateTime>? unlockedAt,
    Expression<int>? progressValue,
    Expression<int>? targetValue,
    Expression<int>? definitionVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (progressValue != null) 'progress_value': progressValue,
      if (targetValue != null) 'target_value': targetValue,
      if (definitionVersion != null) 'definition_version': definitionVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? id,
    Value<DateTime?>? unlockedAt,
    Value<int>? progressValue,
    Value<int>? targetValue,
    Value<int>? definitionVersion,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progressValue: progressValue ?? this.progressValue,
      targetValue: targetValue ?? this.targetValue,
      definitionVersion: definitionVersion ?? this.definitionVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (progressValue.present) {
      map['progress_value'] = Variable<int>(progressValue.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (definitionVersion.present) {
      map['definition_version'] = Variable<int>(definitionVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progressValue: $progressValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyActivityTable extends DailyActivity
    with TableInfo<$DailyActivityTable, DailyActivityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyActivityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDailyChallengeMeta =
      const VerificationMeta('completedDailyChallenge');
  @override
  late final GeneratedColumn<bool> completedDailyChallenge =
      GeneratedColumn<bool>(
        'completed_daily_challenge',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("completed_daily_challenge" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _completedSessionsCountMeta =
      const VerificationMeta('completedSessionsCount');
  @override
  late final GeneratedColumn<int> completedSessionsCount = GeneratedColumn<int>(
    'completed_sessions_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localDate,
    completedDailyChallenge,
    completedSessionsCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_activity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyActivityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('completed_daily_challenge')) {
      context.handle(
        _completedDailyChallengeMeta,
        completedDailyChallenge.isAcceptableOrUnknown(
          data['completed_daily_challenge']!,
          _completedDailyChallengeMeta,
        ),
      );
    }
    if (data.containsKey('completed_sessions_count')) {
      context.handle(
        _completedSessionsCountMeta,
        completedSessionsCount.isAcceptableOrUnknown(
          data['completed_sessions_count']!,
          _completedSessionsCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localDate};
  @override
  DailyActivityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyActivityData(
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      completedDailyChallenge: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed_daily_challenge'],
      )!,
      completedSessionsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_sessions_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyActivityTable createAlias(String alias) {
    return $DailyActivityTable(attachedDatabase, alias);
  }
}

class DailyActivityData extends DataClass
    implements Insertable<DailyActivityData> {
  /// Local ISO date (`yyyy-MM-dd`).
  final String localDate;

  /// Whether the Daily Challenge was completed on this date.
  final bool completedDailyChallenge;

  /// How many sessions were completed on this date.
  final int completedSessionsCount;

  /// When this row was first created (UTC).
  final DateTime createdAt;
  const DailyActivityData({
    required this.localDate,
    required this.completedDailyChallenge,
    required this.completedSessionsCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_date'] = Variable<String>(localDate);
    map['completed_daily_challenge'] = Variable<bool>(completedDailyChallenge);
    map['completed_sessions_count'] = Variable<int>(completedSessionsCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyActivityCompanion toCompanion(bool nullToAbsent) {
    return DailyActivityCompanion(
      localDate: Value(localDate),
      completedDailyChallenge: Value(completedDailyChallenge),
      completedSessionsCount: Value(completedSessionsCount),
      createdAt: Value(createdAt),
    );
  }

  factory DailyActivityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyActivityData(
      localDate: serializer.fromJson<String>(json['localDate']),
      completedDailyChallenge: serializer.fromJson<bool>(
        json['completedDailyChallenge'],
      ),
      completedSessionsCount: serializer.fromJson<int>(
        json['completedSessionsCount'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localDate': serializer.toJson<String>(localDate),
      'completedDailyChallenge': serializer.toJson<bool>(
        completedDailyChallenge,
      ),
      'completedSessionsCount': serializer.toJson<int>(completedSessionsCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyActivityData copyWith({
    String? localDate,
    bool? completedDailyChallenge,
    int? completedSessionsCount,
    DateTime? createdAt,
  }) => DailyActivityData(
    localDate: localDate ?? this.localDate,
    completedDailyChallenge:
        completedDailyChallenge ?? this.completedDailyChallenge,
    completedSessionsCount:
        completedSessionsCount ?? this.completedSessionsCount,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyActivityData copyWithCompanion(DailyActivityCompanion data) {
    return DailyActivityData(
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      completedDailyChallenge: data.completedDailyChallenge.present
          ? data.completedDailyChallenge.value
          : this.completedDailyChallenge,
      completedSessionsCount: data.completedSessionsCount.present
          ? data.completedSessionsCount.value
          : this.completedSessionsCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityData(')
          ..write('localDate: $localDate, ')
          ..write('completedDailyChallenge: $completedDailyChallenge, ')
          ..write('completedSessionsCount: $completedSessionsCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localDate,
    completedDailyChallenge,
    completedSessionsCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyActivityData &&
          other.localDate == this.localDate &&
          other.completedDailyChallenge == this.completedDailyChallenge &&
          other.completedSessionsCount == this.completedSessionsCount &&
          other.createdAt == this.createdAt);
}

class DailyActivityCompanion extends UpdateCompanion<DailyActivityData> {
  final Value<String> localDate;
  final Value<bool> completedDailyChallenge;
  final Value<int> completedSessionsCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyActivityCompanion({
    this.localDate = const Value.absent(),
    this.completedDailyChallenge = const Value.absent(),
    this.completedSessionsCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActivityCompanion.insert({
    required String localDate,
    this.completedDailyChallenge = const Value.absent(),
    this.completedSessionsCount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : localDate = Value(localDate),
       createdAt = Value(createdAt);
  static Insertable<DailyActivityData> custom({
    Expression<String>? localDate,
    Expression<bool>? completedDailyChallenge,
    Expression<int>? completedSessionsCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localDate != null) 'local_date': localDate,
      if (completedDailyChallenge != null)
        'completed_daily_challenge': completedDailyChallenge,
      if (completedSessionsCount != null)
        'completed_sessions_count': completedSessionsCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyActivityCompanion copyWith({
    Value<String>? localDate,
    Value<bool>? completedDailyChallenge,
    Value<int>? completedSessionsCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyActivityCompanion(
      localDate: localDate ?? this.localDate,
      completedDailyChallenge:
          completedDailyChallenge ?? this.completedDailyChallenge,
      completedSessionsCount:
          completedSessionsCount ?? this.completedSessionsCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (completedDailyChallenge.present) {
      map['completed_daily_challenge'] = Variable<bool>(
        completedDailyChallenge.value,
      );
    }
    if (completedSessionsCount.present) {
      map['completed_sessions_count'] = Variable<int>(
        completedSessionsCount.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityCompanion(')
          ..write('localDate: $localDate, ')
          ..write('completedDailyChallenge: $completedDailyChallenge, ')
          ..write('completedSessionsCount: $completedSessionsCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppMetadataEntriesTable appMetadataEntries =
      $AppMetadataEntriesTable(this);
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $QuestionAttemptsTable questionAttempts = $QuestionAttemptsTable(
    this,
  );
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $DailyActivityTable dailyActivity = $DailyActivityTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appMetadataEntries,
    gameSessions,
    questionAttempts,
    achievements,
    dailyActivity,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('question_attempts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AppMetadataEntriesTableCreateCompanionBuilder =
    AppMetadataEntriesCompanion Function({
      required String key,
      Value<String> value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppMetadataEntriesTableUpdateCompanionBuilder =
    AppMetadataEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppMetadataEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetadataEntriesTable> {
  $$AppMetadataEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetadataEntriesTable> {
  $$AppMetadataEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetadataEntriesTable> {
  $$AppMetadataEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppMetadataEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetadataEntriesTable,
          AppMetadataEntry,
          $$AppMetadataEntriesTableFilterComposer,
          $$AppMetadataEntriesTableOrderingComposer,
          $$AppMetadataEntriesTableAnnotationComposer,
          $$AppMetadataEntriesTableCreateCompanionBuilder,
          $$AppMetadataEntriesTableUpdateCompanionBuilder,
          (
            AppMetadataEntry,
            BaseReferences<
              _$AppDatabase,
              $AppMetadataEntriesTable,
              AppMetadataEntry
            >,
          ),
          AppMetadataEntry,
          PrefetchHooks Function()
        > {
  $$AppMetadataEntriesTableTableManager(
    _$AppDatabase db,
    $AppMetadataEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataEntriesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String> value = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataEntriesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetadataEntriesTable, AppMetadataEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AppMetadataEntriesTable,
                    AppMetadataEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetadataEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetadataEntriesTable,
      AppMetadataEntry,
      $$AppMetadataEntriesTableFilterComposer,
      $$AppMetadataEntriesTableOrderingComposer,
      $$AppMetadataEntriesTableAnnotationComposer,
      $$AppMetadataEntriesTableCreateCompanionBuilder,
      $$AppMetadataEntriesTableUpdateCompanionBuilder,
      (
        AppMetadataEntry,
        BaseReferences<
          _$AppDatabase,
          $AppMetadataEntriesTable,
          AppMetadataEntry
        >,
      ),
      AppMetadataEntry,
      PrefetchHooks Function()
    >;
typedef $$GameSessionsTableCreateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<int> id,
      required String mode,
      Value<String> status,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int?> durationMs,
      required int questionCount,
      required int answeredCount,
      Value<int?> iqScore,
      Value<int?> eqScore,
      Value<int?> earnedPoints,
      Value<int?> possiblePoints,
      required int scoreAlgorithmVersion,
      Value<String> contentPackVersion,
      Value<String?> dailyLocalDate,
    });
typedef $$GameSessionsTableUpdateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<int> id,
      Value<String> mode,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int?> durationMs,
      Value<int> questionCount,
      Value<int> answeredCount,
      Value<int?> iqScore,
      Value<int?> eqScore,
      Value<int?> earnedPoints,
      Value<int?> possiblePoints,
      Value<int> scoreAlgorithmVersion,
      Value<String> contentPackVersion,
      Value<String?> dailyLocalDate,
    });

final class $$GameSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession> {
  $$GameSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionAttemptsTable, List<QuestionAttempt>>
  _questionAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionAttempts,
    aliasName: 'game_sessions__id__question_attempts__session_id',
  );

  $$QuestionAttemptsTableProcessedTableManager get questionAttemptsRefs {
    final manager = $$QuestionAttemptsTableTableManager(
      $_db,
      $_db.questionAttempts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionAttemptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iqScore => $composableBuilder(
    column: $table.iqScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eqScore => $composableBuilder(
    column: $table.eqScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnedPoints => $composableBuilder(
    column: $table.earnedPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get possiblePoints => $composableBuilder(
    column: $table.possiblePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreAlgorithmVersion => $composableBuilder(
    column: $table.scoreAlgorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentPackVersion => $composableBuilder(
    column: $table.contentPackVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyLocalDate => $composableBuilder(
    column: $table.dailyLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questionAttemptsRefs(
    Expression<bool> Function($$QuestionAttemptsTableFilterComposer f) f,
  ) {
    final $$QuestionAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.questionAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iqScore => $composableBuilder(
    column: $table.iqScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eqScore => $composableBuilder(
    column: $table.eqScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnedPoints => $composableBuilder(
    column: $table.earnedPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get possiblePoints => $composableBuilder(
    column: $table.possiblePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreAlgorithmVersion => $composableBuilder(
    column: $table.scoreAlgorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentPackVersion => $composableBuilder(
    column: $table.contentPackVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyLocalDate => $composableBuilder(
    column: $table.dailyLocalDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iqScore =>
      $composableBuilder(column: $table.iqScore, builder: (column) => column);

  GeneratedColumn<int> get eqScore =>
      $composableBuilder(column: $table.eqScore, builder: (column) => column);

  GeneratedColumn<int> get earnedPoints => $composableBuilder(
    column: $table.earnedPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get possiblePoints => $composableBuilder(
    column: $table.possiblePoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreAlgorithmVersion => $composableBuilder(
    column: $table.scoreAlgorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentPackVersion => $composableBuilder(
    column: $table.contentPackVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyLocalDate => $composableBuilder(
    column: $table.dailyLocalDate,
    builder: (column) => column,
  );

  Expression<T> questionAttemptsRefs<T extends Object>(
    Expression<T> Function($$QuestionAttemptsTableAnnotationComposer a) f,
  ) {
    final $$QuestionAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsTable,
          GameSession,
          $$GameSessionsTableFilterComposer,
          $$GameSessionsTableOrderingComposer,
          $$GameSessionsTableAnnotationComposer,
          $$GameSessionsTableCreateCompanionBuilder,
          $$GameSessionsTableUpdateCompanionBuilder,
          (GameSession, $$GameSessionsTableReferences),
          GameSession,
          PrefetchHooks Function({bool questionAttemptsRefs})
        > {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<int> answeredCount = const Value.absent(),
                Value<int?> iqScore = const Value.absent(),
                Value<int?> eqScore = const Value.absent(),
                Value<int?> earnedPoints = const Value.absent(),
                Value<int?> possiblePoints = const Value.absent(),
                Value<int> scoreAlgorithmVersion = const Value.absent(),
                Value<String> contentPackVersion = const Value.absent(),
                Value<String?> dailyLocalDate = const Value.absent(),
              }) => GameSessionsCompanion(
                id: id,
                mode: mode,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                durationMs: durationMs,
                questionCount: questionCount,
                answeredCount: answeredCount,
                iqScore: iqScore,
                eqScore: eqScore,
                earnedPoints: earnedPoints,
                possiblePoints: possiblePoints,
                scoreAlgorithmVersion: scoreAlgorithmVersion,
                contentPackVersion: contentPackVersion,
                dailyLocalDate: dailyLocalDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mode,
                Value<String> status = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required int questionCount,
                required int answeredCount,
                Value<int?> iqScore = const Value.absent(),
                Value<int?> eqScore = const Value.absent(),
                Value<int?> earnedPoints = const Value.absent(),
                Value<int?> possiblePoints = const Value.absent(),
                required int scoreAlgorithmVersion,
                Value<String> contentPackVersion = const Value.absent(),
                Value<String?> dailyLocalDate = const Value.absent(),
              }) => GameSessionsCompanion.insert(
                id: id,
                mode: mode,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                durationMs: durationMs,
                questionCount: questionCount,
                answeredCount: answeredCount,
                iqScore: iqScore,
                eqScore: eqScore,
                earnedPoints: earnedPoints,
                possiblePoints: possiblePoints,
                scoreAlgorithmVersion: scoreAlgorithmVersion,
                contentPackVersion: contentPackVersion,
                dailyLocalDate: dailyLocalDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSessionsTable, GameSession>(table),
                  $$GameSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionAttemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (questionAttemptsRefs) db.questionAttempts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionAttemptsRefs)
                    await $_getPrefetchedDataByColumns<
                      GameSession,
                      $GameSessionsTable,
                      QuestionAttempt,
                      $QuestionAttemptsTable
                    >(
                      currentTable: table,
                      referencedTable: $$GameSessionsTableReferences
                          ._questionAttemptsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GameSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).questionAttemptsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GameSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsTable,
      GameSession,
      $$GameSessionsTableFilterComposer,
      $$GameSessionsTableOrderingComposer,
      $$GameSessionsTableAnnotationComposer,
      $$GameSessionsTableCreateCompanionBuilder,
      $$GameSessionsTableUpdateCompanionBuilder,
      (GameSession, $$GameSessionsTableReferences),
      GameSession,
      PrefetchHooks Function({bool questionAttemptsRefs})
    >;
typedef $$QuestionAttemptsTableCreateCompanionBuilder =
    QuestionAttemptsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String questionId,
      required String domain,
      required String skill,
      required int questionOrder,
      Value<String> submittedAnswerJson,
      Value<bool?> isCorrect,
      Value<int> earnedPoints,
      Value<int> possiblePoints,
      Value<String?> rubricScoresJson,
      Value<int?> elapsedMs,
      Value<bool> hintUsed,
      Value<DateTime?> answeredAt,
    });
typedef $$QuestionAttemptsTableUpdateCompanionBuilder =
    QuestionAttemptsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> questionId,
      Value<String> domain,
      Value<String> skill,
      Value<int> questionOrder,
      Value<String> submittedAnswerJson,
      Value<bool?> isCorrect,
      Value<int> earnedPoints,
      Value<int> possiblePoints,
      Value<String?> rubricScoresJson,
      Value<int?> elapsedMs,
      Value<bool> hintUsed,
      Value<DateTime?> answeredAt,
    });

final class $$QuestionAttemptsTableReferences
    extends
        BaseReferences<_$AppDatabase, $QuestionAttemptsTable, QuestionAttempt> {
  $$QuestionAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GameSessionsTable _sessionIdTable(_$AppDatabase db) => db.gameSessions
      .createAlias('question_attempts__session_id__game_sessions__id');

  $$GameSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$GameSessionsTableTableManager(
      $_db,
      $_db.gameSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestionAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionAttemptsTable> {
  $$QuestionAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionOrder => $composableBuilder(
    column: $table.questionOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submittedAnswerJson => $composableBuilder(
    column: $table.submittedAnswerJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnedPoints => $composableBuilder(
    column: $table.earnedPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get possiblePoints => $composableBuilder(
    column: $table.possiblePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rubricScoresJson => $composableBuilder(
    column: $table.rubricScoresJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hintUsed => $composableBuilder(
    column: $table.hintUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameSessionsTableFilterComposer get sessionId {
    final $$GameSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableFilterComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionAttemptsTable> {
  $$QuestionAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionOrder => $composableBuilder(
    column: $table.questionOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submittedAnswerJson => $composableBuilder(
    column: $table.submittedAnswerJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnedPoints => $composableBuilder(
    column: $table.earnedPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get possiblePoints => $composableBuilder(
    column: $table.possiblePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rubricScoresJson => $composableBuilder(
    column: $table.rubricScoresJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hintUsed => $composableBuilder(
    column: $table.hintUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameSessionsTableOrderingComposer get sessionId {
    final $$GameSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionAttemptsTable> {
  $$QuestionAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<int> get questionOrder => $composableBuilder(
    column: $table.questionOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get submittedAnswerJson => $composableBuilder(
    column: $table.submittedAnswerJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get earnedPoints => $composableBuilder(
    column: $table.earnedPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get possiblePoints => $composableBuilder(
    column: $table.possiblePoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rubricScoresJson => $composableBuilder(
    column: $table.rubricScoresJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<bool> get hintUsed =>
      $composableBuilder(column: $table.hintUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$GameSessionsTableAnnotationComposer get sessionId {
    final $$GameSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionAttemptsTable,
          QuestionAttempt,
          $$QuestionAttemptsTableFilterComposer,
          $$QuestionAttemptsTableOrderingComposer,
          $$QuestionAttemptsTableAnnotationComposer,
          $$QuestionAttemptsTableCreateCompanionBuilder,
          $$QuestionAttemptsTableUpdateCompanionBuilder,
          (QuestionAttempt, $$QuestionAttemptsTableReferences),
          QuestionAttempt,
          PrefetchHooks Function({bool sessionId})
        > {
  $$QuestionAttemptsTableTableManager(
    _$AppDatabase db,
    $QuestionAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> skill = const Value.absent(),
                Value<int> questionOrder = const Value.absent(),
                Value<String> submittedAnswerJson = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                Value<int> earnedPoints = const Value.absent(),
                Value<int> possiblePoints = const Value.absent(),
                Value<String?> rubricScoresJson = const Value.absent(),
                Value<int?> elapsedMs = const Value.absent(),
                Value<bool> hintUsed = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
              }) => QuestionAttemptsCompanion(
                id: id,
                sessionId: sessionId,
                questionId: questionId,
                domain: domain,
                skill: skill,
                questionOrder: questionOrder,
                submittedAnswerJson: submittedAnswerJson,
                isCorrect: isCorrect,
                earnedPoints: earnedPoints,
                possiblePoints: possiblePoints,
                rubricScoresJson: rubricScoresJson,
                elapsedMs: elapsedMs,
                hintUsed: hintUsed,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String questionId,
                required String domain,
                required String skill,
                required int questionOrder,
                Value<String> submittedAnswerJson = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                Value<int> earnedPoints = const Value.absent(),
                Value<int> possiblePoints = const Value.absent(),
                Value<String?> rubricScoresJson = const Value.absent(),
                Value<int?> elapsedMs = const Value.absent(),
                Value<bool> hintUsed = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
              }) => QuestionAttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                questionId: questionId,
                domain: domain,
                skill: skill,
                questionOrder: questionOrder,
                submittedAnswerJson: submittedAnswerJson,
                isCorrect: isCorrect,
                earnedPoints: earnedPoints,
                possiblePoints: possiblePoints,
                rubricScoresJson: rubricScoresJson,
                elapsedMs: elapsedMs,
                hintUsed: hintUsed,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestionAttemptsTable, QuestionAttempt>(table),
                  $$QuestionAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$QuestionAttemptsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$QuestionAttemptsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestionAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionAttemptsTable,
      QuestionAttempt,
      $$QuestionAttemptsTableFilterComposer,
      $$QuestionAttemptsTableOrderingComposer,
      $$QuestionAttemptsTableAnnotationComposer,
      $$QuestionAttemptsTableCreateCompanionBuilder,
      $$QuestionAttemptsTableUpdateCompanionBuilder,
      (QuestionAttempt, $$QuestionAttemptsTableReferences),
      QuestionAttempt,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String id,
      Value<DateTime?> unlockedAt,
      Value<int> progressValue,
      Value<int> targetValue,
      Value<int> definitionVersion,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> id,
      Value<DateTime?> unlockedAt,
      Value<int> progressValue,
      Value<int> targetValue,
      Value<int> definitionVersion,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressValue => $composableBuilder(
    column: $table.progressValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get definitionVersion => $composableBuilder(
    column: $table.definitionVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressValue => $composableBuilder(
    column: $table.progressValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get definitionVersion => $composableBuilder(
    column: $table.definitionVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressValue => $composableBuilder(
    column: $table.progressValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get definitionVersion => $composableBuilder(
    column: $table.definitionVersion,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> progressValue = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<int> definitionVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                unlockedAt: unlockedAt,
                progressValue: progressValue,
                targetValue: targetValue,
                definitionVersion: definitionVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> progressValue = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<int> definitionVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                unlockedAt: unlockedAt,
                progressValue: progressValue,
                targetValue: targetValue,
                definitionVersion: definitionVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTable, Achievement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AchievementsTable,
                    Achievement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$DailyActivityTableCreateCompanionBuilder =
    DailyActivityCompanion Function({
      required String localDate,
      Value<bool> completedDailyChallenge,
      Value<int> completedSessionsCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DailyActivityTableUpdateCompanionBuilder =
    DailyActivityCompanion Function({
      Value<String> localDate,
      Value<bool> completedDailyChallenge,
      Value<int> completedSessionsCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DailyActivityTableFilterComposer
    extends Composer<_$AppDatabase, $DailyActivityTable> {
  $$DailyActivityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completedDailyChallenge => $composableBuilder(
    column: $table.completedDailyChallenge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedSessionsCount => $composableBuilder(
    column: $table.completedSessionsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyActivityTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyActivityTable> {
  $$DailyActivityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completedDailyChallenge => $composableBuilder(
    column: $table.completedDailyChallenge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedSessionsCount => $composableBuilder(
    column: $table.completedSessionsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyActivityTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyActivityTable> {
  $$DailyActivityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<bool> get completedDailyChallenge => $composableBuilder(
    column: $table.completedDailyChallenge,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedSessionsCount => $composableBuilder(
    column: $table.completedSessionsCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyActivityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyActivityTable,
          DailyActivityData,
          $$DailyActivityTableFilterComposer,
          $$DailyActivityTableOrderingComposer,
          $$DailyActivityTableAnnotationComposer,
          $$DailyActivityTableCreateCompanionBuilder,
          $$DailyActivityTableUpdateCompanionBuilder,
          (
            DailyActivityData,
            BaseReferences<
              _$AppDatabase,
              $DailyActivityTable,
              DailyActivityData
            >,
          ),
          DailyActivityData,
          PrefetchHooks Function()
        > {
  $$DailyActivityTableTableManager(_$AppDatabase db, $DailyActivityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyActivityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyActivityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyActivityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localDate = const Value.absent(),
                Value<bool> completedDailyChallenge = const Value.absent(),
                Value<int> completedSessionsCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityCompanion(
                localDate: localDate,
                completedDailyChallenge: completedDailyChallenge,
                completedSessionsCount: completedSessionsCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localDate,
                Value<bool> completedDailyChallenge = const Value.absent(),
                Value<int> completedSessionsCount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityCompanion.insert(
                localDate: localDate,
                completedDailyChallenge: completedDailyChallenge,
                completedSessionsCount: completedSessionsCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyActivityTable, DailyActivityData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyActivityTable,
                    DailyActivityData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyActivityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyActivityTable,
      DailyActivityData,
      $$DailyActivityTableFilterComposer,
      $$DailyActivityTableOrderingComposer,
      $$DailyActivityTableAnnotationComposer,
      $$DailyActivityTableCreateCompanionBuilder,
      $$DailyActivityTableUpdateCompanionBuilder,
      (
        DailyActivityData,
        BaseReferences<_$AppDatabase, $DailyActivityTable, DailyActivityData>,
      ),
      DailyActivityData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppMetadataEntriesTableTableManager get appMetadataEntries =>
      $$AppMetadataEntriesTableTableManager(_db, _db.appMetadataEntries);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$QuestionAttemptsTableTableManager get questionAttempts =>
      $$QuestionAttemptsTableTableManager(_db, _db.questionAttempts);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$DailyActivityTableTableManager get dailyActivity =>
      $$DailyActivityTableTableManager(_db, _db.dailyActivity);
}
