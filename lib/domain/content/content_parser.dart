import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_helpers.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';

/// Parses and validates the bundled content pack without any Flutter or I/O
/// dependency, so it is unit-testable without a widget tree (Phase 2 task 8).
///
/// Invalid records are excluded from the resulting [ContentBank] and reported
/// as [ContentIssue]s rather than crashing the app or silently becoming
/// incorrect questions (PLAN §5.2, Phase 2 acceptance).
class ContentParser {
  const ContentParser._();

  /// Highest score an EQ rubric dimension may carry (PLAN §5.6).
  static const int maxRubricScore = 3;

  static const List<String> _urlPrefixes = <String>['http://', 'https://'];

  /// Parses the manifest envelope, throwing on a structural problem so callers
  /// can translate it into a typed [ContentLoadFailure].
  static ContentManifest parseManifest(String manifestJson) {
    final Map<String, dynamic> json = decodeObject(manifestJson);
    return ContentManifest.fromJson(json);
  }

  /// Parses the full pack from its manifest JSON and the raw JSON of every
  /// content file (path -> JSON string).
  static ContentLoadResult parsePack({
    required String manifestJson,
    required Map<String, String> fileJsons,
    String? expectedLocale,
  }) {
    final List<ContentIssue> issues = <ContentIssue>[];

    late final ContentManifest manifest;
    try {
      manifest = parseManifest(manifestJson);
    } on ContentFieldException catch (e) {
      return ContentLoadFailure(
        issues: <ContentIssue>[
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.manifestInvalid,
            message: 'Manifest is invalid: ${e.field}',
          ),
        ],
      );
    } on FormatException catch (e) {
      return ContentLoadFailure(
        issues: <ContentIssue>[
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.manifestInvalid,
            message: 'Manifest is not valid JSON: ${e.message}',
          ),
        ],
      );
    }

    for (final String file in manifest.files) {
      // Files for other languages are not part of this load, so their absence
      // from [fileJsons] is expected rather than an error.
      if (expectedLocale != null && !file.startsWith('$expectedLocale/')) {
        continue;
      }
      if (!fileJsons.containsKey(file)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.fileMissing,
            message: 'Manifest references missing file: $file',
          ),
        );
      }
    }

    final List<QuestionItem> items = <QuestionItem>[];
    final Set<String> seenIds = <String>{};

    for (final MapEntry<String, String> entry in fileJsons.entries) {
      final String path = entry.key;
      final String raw = entry.value;

      final List<dynamic> rawItems;
      try {
        final Map<String, dynamic> env = decodeObject(raw);
        final dynamic itemsField = env['items'];
        if (itemsField is List<dynamic>) {
          rawItems = itemsField;
        } else {
          rawItems = <dynamic>[];
          issues.add(
            ContentIssue(
              severity: IssueSeverity.warning,
              code: IssueCode.fileInvalid,
              message: 'File $path has no "items" array; skipping.',
            ),
          );
        }
      } on FormatException catch (e) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.fileInvalid,
            message: 'File $path is not valid JSON: ${e.message}',
          ),
        );
        continue;
      }

      for (final dynamic rawItem in rawItems) {
        if (rawItem is! Map<String, dynamic>) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.itemMalformed,
              message: 'A non-object item was found in $path',
            ),
          );
          continue;
        }
        final _ItemOutcome outcome = _parseItem(
          rawItem,
          path,
          manifest.supportedLocales,
        );
        if (outcome.item != null) {
          final String id = outcome.item!.id;
          if (expectedLocale != null &&
              outcome.item!.locale != expectedLocale) {
            issues
              ..add(
                ContentIssue(
                  severity: IssueSeverity.error,
                  code: IssueCode.unsupportedLocale,
                  message:
                      'Item $id declares locale "${outcome.item!.locale}" but '
                      'the pack was loaded for "$expectedLocale".',
                  itemId: id,
                ),
              )
              ..addAll(outcome.issues);
            continue;
          }
          if (seenIds.contains(id)) {
            issues.add(
              ContentIssue(
                severity: IssueSeverity.error,
                code: IssueCode.duplicateId,
                message: 'Duplicate question id: $id',
                itemId: id,
              ),
            );
          } else {
            seenIds.add(id);
            items.add(outcome.item!);
          }
        }
        issues.addAll(outcome.issues);
      }
    }

    _checkExpectedCounts(manifest, items, issues);

    if (items.isEmpty) {
      return ContentLoadFailure(issues: issues);
    }
    return ContentLoadSuccess(
      bank: ContentBank(manifest: manifest, items: items),
      issues: issues,
    );
  }

  static _ItemOutcome _parseItem(
    Map<String, dynamic> json,
    String path,
    List<String> supportedLocales,
  ) {
    final List<ContentIssue> issues = <ContentIssue>[];

    final String? id = readString(json['id']);
    if (id == null || id.isEmpty) {
      return _ItemOutcome(
        issues: <ContentIssue>[
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.missingId,
            message: 'An item in $path is missing a valid "id".',
          ),
        ],
      );
    }

    final ContentDomain? domain = ContentDomainX.tryParse(
      _asRaw(json['domain']),
    );
    if (domain == null) {
      return _ItemOutcome(
        issues: <ContentIssue>[
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.unknownDomain,
            message: 'Item $id has unknown domain: "${json['domain']}".',
            itemId: id,
          ),
        ],
      );
    }

    final ContentType? contentType = ContentTypeX.tryParse(
      _asRaw(json['contentType']),
    );
    if (contentType == null) {
      return _ItemOutcome(
        issues: <ContentIssue>[
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.unknownContentType,
            message:
                'Item $id has unknown contentType: '
                '"${json['contentType']}".',
            itemId: id,
          ),
        ],
      );
    }

    final _Common? common = _parseCommon(
      json,
      id,
      domain,
      contentType,
      supportedLocales,
      issues,
    );
    if (common == null) {
      return _ItemOutcome(issues: issues);
    }

    final QuestionItem? item;
    switch (contentType) {
      case ContentType.multipleChoice:
        item = _parseMultipleChoice(json, id, common, issues);
      case ContentType.scenarioChoice:
        item = _parseEqScenario(json, id, common, issues);
      case ContentType.memorySequence:
      case ContentType.reorderSequence:
      case ContentType.visualPattern:
      case ContentType.oddOneOut:
      case ContentType.matchingPairs:
        item = _parsePuzzle(json, id, common, issues, contentType);
    }

    return _ItemOutcome(item: item, issues: issues);
  }

  static _Common? _parseCommon(
    Map<String, dynamic> json,
    String id,
    ContentDomain domain,
    ContentType contentType,
    List<String> supportedLocales,
    List<ContentIssue> issues,
  ) {
    final Difficulty? difficulty = DifficultyX.tryParse(
      _asRaw(json['difficulty']),
    );
    if (difficulty == null) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.unknownDifficulty,
          message: 'Item $id has unknown difficulty: "${json['difficulty']}".',
          itemId: id,
        ),
      );
      return null;
    }

    final String? prompt = readString(json['prompt']);
    if (prompt == null || prompt.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingPrompt,
          message: 'Item $id is missing a prompt.',
          itemId: id,
        ),
      );
      return null;
    }
    _scanForUrls(prompt, id, issues);

    final String locale = readString(json['locale']) ?? 'en';
    if (!supportedLocales.contains(locale)) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.warning,
          code: IssueCode.unsupportedLocale,
          message:
              'Item $id uses locale "$locale" not in the manifest '
              'locales.',
          itemId: id,
        ),
      );
    }

    final ContentStatus status =
        ContentStatusX.tryParse(_asRaw(json['status'])) ??
        ContentStatus.finalStatus;
    if (status == ContentStatus.draft) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.warning,
          code: IssueCode.draftContent,
          message: 'Item $id is marked as draft.',
          itemId: id,
        ),
      );
    }

    return _Common(
      domain: domain,
      contentType: contentType,
      skill: readString(json['skill']) ?? '',
      difficulty: difficulty,
      locale: locale,
      prompt: prompt,
      instructions: readString(json['instructions']),
      explanation: readString(json['explanation']),
      hint: readString(json['hint']),
      estimatedSeconds: json['estimatedSeconds'] is int
          ? json['estimatedSeconds'] as int
          : null,
      pointsWeight: json['pointsWeight'] is int
          ? json['pointsWeight'] as int
          : null,
      tags: stringList(json['tags']),
      contentVersion: json['contentVersion'] is int
          ? json['contentVersion'] as int
          : null,
      attribution: readString(json['attribution']),
      status: status,
    );
  }

  static QuestionItem? _parseMultipleChoice(
    Map<String, dynamic> json,
    String id,
    _Common common,
    List<ContentIssue> issues,
  ) {
    final List<QuestionOption> options = <QuestionOption>[];
    final Set<String> optionIds = <String>{};

    final List<dynamic>? rawOptions = json['options'] is List<dynamic>
        ? json['options'] as List<dynamic>
        : null;
    if (rawOptions == null || rawOptions.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingOptions,
          message: 'Item $id is missing options.',
          itemId: id,
        ),
      );
      return null;
    }

    for (final dynamic raw in rawOptions) {
      if (raw is! Map<String, dynamic>) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has a malformed option.',
            itemId: id,
          ),
        );
        continue;
      }
      final String? oid = readString(raw['id']);
      final String? otext = readString(raw['text']);
      if (oid == null || oid.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has an option without an id.',
            itemId: id,
          ),
        );
        continue;
      }
      if (otext == null || otext.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingText,
            message: 'Item $id option "$oid" is missing text.',
            itemId: id,
          ),
        );
        continue;
      }
      if (optionIds.contains(oid)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has duplicate option id "$oid".',
            itemId: id,
          ),
        );
        continue;
      }
      optionIds.add(oid);
      options.add(QuestionOption(id: oid, text: otext));
    }

    if (options.length < 2) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingOptions,
          message: 'Item $id needs at least two valid options.',
          itemId: id,
        ),
      );
      return null;
    }

    final String? correctOptionId = readString(json['correctOptionId']);
    if (correctOptionId == null || !optionIds.contains(correctOptionId)) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.invalidCorrectOption,
          message: 'Item $id has an invalid correctOptionId.',
          itemId: id,
        ),
      );
      return null;
    }

    final String? explanation = readString(json['explanation']);
    if (explanation == null || explanation.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingExplanation,
          message: 'Item $id is missing an explanation.',
          itemId: id,
        ),
      );
      return null;
    }

    return MultipleChoiceItem(
      id: id,
      domain: common.domain,
      contentType: common.contentType,
      skill: common.skill,
      difficulty: common.difficulty,
      locale: common.locale,
      prompt: common.prompt,
      instructions: common.instructions,
      explanation: explanation,
      hint: common.hint,
      estimatedSeconds: common.estimatedSeconds,
      pointsWeight: common.pointsWeight,
      tags: common.tags,
      contentVersion: common.contentVersion,
      attribution: common.attribution,
      status: common.status,
      options: options,
      correctOptionId: correctOptionId,
    );
  }

  static QuestionItem? _parsePuzzle(
    Map<String, dynamic> json,
    String id,
    _Common common,
    List<ContentIssue> issues,
    ContentType contentType,
  ) {
    final dynamic rawAnswer = json['expectedAnswer'];
    if (rawAnswer is! List<dynamic> || rawAnswer.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.invalidInteractionConfig,
          message: 'Item $id is missing a non-empty expectedAnswer list.',
          itemId: id,
        ),
      );
      return null;
    }
    final List<dynamic> expectedAnswer = rawAnswer;
    List<QuestionOption> options = const <QuestionOption>[];

    if (contentType == ContentType.memorySequence) {
      for (final dynamic e in expectedAnswer) {
        if (e is! int) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message:
                  'Item $id memory_sequence expectedAnswer must be '
                  'integers.',
              itemId: id,
            ),
          );
          return null;
        }
      }
      final dynamic reveal = _configValue(json, 'revealSequence');
      if (reveal != null) {
        final bool validReveal =
            reveal is List<dynamic> &&
            reveal.isNotEmpty &&
            reveal.every((dynamic e) => e is int);
        if (!validReveal) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message:
                  'Item $id revealSequence must be a non-empty list of '
                  'integers.',
              itemId: id,
            ),
          );
          return null;
        }
      }
    } else if (contentType == ContentType.reorderSequence) {
      for (final dynamic e in expectedAnswer) {
        if (e is! String) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message:
                  'Item $id reorder_sequence expectedAnswer must be '
                  'tile ids (strings).',
              itemId: id,
            ),
          );
          return null;
        }
      }
      final Map<String, dynamic>? config =
          json['interactionConfig'] is Map<String, dynamic>
          ? json['interactionConfig'] as Map<String, dynamic>
          : null;
      final List<String> tiles = config == null
          ? const <String>[]
          : stringList(config['tiles']);
      if (tiles.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.invalidInteractionConfig,
            message: 'Item $id reorder_sequence needs interactionConfig.tiles.',
            itemId: id,
          ),
        );
        return null;
      }
      final Set<String> tileSet = tiles.toSet();
      for (final dynamic e in expectedAnswer) {
        if (!tileSet.contains(e as String)) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message: 'Item $id expectedAnswer references unknown tile "$e".',
              itemId: id,
            ),
          );
          return null;
        }
      }
    } else {
      // Symbol-based mechanics: visual_pattern, odd_one_out, matching_pairs.
      final List<QuestionOption>? parsed = _parseSymbolOptions(
        json,
        id,
        issues,
      );
      if (parsed == null) return null;
      options = parsed;
      final Set<String> symbolIds = options
          .map((QuestionOption o) => o.id)
          .toSet();
      for (final dynamic e in expectedAnswer) {
        if (e is! String || !symbolIds.contains(e)) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message:
                  'Item $id expectedAnswer references unknown symbol "$e".',
              itemId: id,
            ),
          );
          return null;
        }
      }
      if (contentType == ContentType.matchingPairs) {
        if (expectedAnswer.length < 2) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message: 'Item $id needs at least two matching pairs.',
              itemId: id,
            ),
          );
          return null;
        }
        if (expectedAnswer.toSet().length != expectedAnswer.length) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message: 'Item $id repeats a matching pair id.',
              itemId: id,
            ),
          );
          return null;
        }
        final dynamic rawBudget = _configValue(json, 'maxFlips');
        if (rawBudget != null && (rawBudget is! int || rawBudget <= 0)) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.invalidInteractionConfig,
              message: 'Item $id maxFlips must be a positive integer.',
              itemId: id,
            ),
          );
          return null;
        }
      } else if (expectedAnswer.length != 1) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.invalidInteractionConfig,
            message: 'Item $id must reference exactly one symbol.',
            itemId: id,
          ),
        );
        return null;
      }
    }

    final Map<String, dynamic>? interactionConfig =
        json['interactionConfig'] is Map<String, dynamic>
        ? json['interactionConfig'] as Map<String, dynamic>
        : null;

    return PuzzleItem(
      id: id,
      domain: common.domain,
      contentType: common.contentType,
      skill: common.skill,
      difficulty: common.difficulty,
      locale: common.locale,
      prompt: common.prompt,
      instructions: common.instructions,
      explanation: common.explanation,
      hint: common.hint,
      estimatedSeconds: common.estimatedSeconds,
      pointsWeight: common.pointsWeight,
      tags: common.tags,
      contentVersion: common.contentVersion,
      attribution: common.attribution,
      status: common.status,
      expectedAnswer: expectedAnswer,
      options: options,
      interactionConfig: interactionConfig,
    );
  }

  /// Reads the optional `options` array used by symbol-based puzzle mechanics.
  ///
  /// Returns `null` and records an issue when the array is unusable, so the
  /// caller can drop the item instead of shipping a question nobody can solve.
  static List<QuestionOption>? _parseSymbolOptions(
    Map<String, dynamic> json,
    String id,
    List<ContentIssue> issues,
  ) {
    final dynamic rawOptions = json['options'];
    if (rawOptions is! List<dynamic> || rawOptions.length < 2) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingOptions,
          message: 'Item $id needs at least two symbol options.',
          itemId: id,
        ),
      );
      return null;
    }
    final List<QuestionOption> options = <QuestionOption>[];
    final Set<String> optionIds = <String>{};
    for (final dynamic raw in rawOptions) {
      if (raw is! Map<String, dynamic>) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has a malformed symbol option.',
            itemId: id,
          ),
        );
        return null;
      }
      final String? optionId = readString(raw['id']);
      final String? text = readString(raw['text']);
      if (optionId == null ||
          optionId.isEmpty ||
          text == null ||
          text.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingText,
            message: 'Item $id has a symbol option without id or text.',
            itemId: id,
          ),
        );
        return null;
      }
      if (!optionIds.add(optionId)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has duplicate symbol id "$optionId".',
            itemId: id,
          ),
        );
        return null;
      }
      options.add(QuestionOption(id: optionId, text: text));
    }
    return options;
  }

  static dynamic _configValue(Map<String, dynamic> json, String key) {
    final dynamic config = json['interactionConfig'];
    if (config is! Map<String, dynamic>) return null;
    return config[key];
  }

  static QuestionItem? _parseEqScenario(
    Map<String, dynamic> json,
    String id,
    _Common common,
    List<ContentIssue> issues,
  ) {
    final String? scenarioContext = readString(json['scenarioContext']);
    if (scenarioContext == null || scenarioContext.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingScenarioContext,
          message: 'Item $id is missing scenarioContext.',
          itemId: id,
        ),
      );
      return null;
    }
    _scanForUrls(scenarioContext, id, issues);

    final List<QuestionOption> options = <QuestionOption>[];
    final Set<String> optionIds = <String>{};

    final List<dynamic>? rawOptions = json['options'] is List<dynamic>
        ? json['options'] as List<dynamic>
        : null;
    if (rawOptions == null || rawOptions.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingOptions,
          message: 'Item $id is missing options.',
          itemId: id,
        ),
      );
      return null;
    }
    for (final dynamic raw in rawOptions) {
      if (raw is! Map<String, dynamic>) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has a malformed option.',
            itemId: id,
          ),
        );
        continue;
      }
      final String? oid = readString(raw['id']);
      final String? otext = readString(raw['text']);
      if (oid == null || oid.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has an option without an id.',
            itemId: id,
          ),
        );
        continue;
      }
      if (otext == null || otext.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingText,
            message: 'Item $id option "$oid" is missing text.',
            itemId: id,
          ),
        );
        continue;
      }
      if (optionIds.contains(oid)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.optionMissingId,
            message: 'Item $id has duplicate option id "$oid".',
            itemId: id,
          ),
        );
        continue;
      }
      optionIds.add(oid);
      options.add(QuestionOption(id: oid, text: otext));
    }
    if (options.isEmpty) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingOptions,
          message: 'Item $id has no valid options.',
          itemId: id,
        ),
      );
      return null;
    }

    final dynamic rawRubric = json['rubricByOption'];
    final Map<String, dynamic>? rubricMap = rawRubric is Map<String, dynamic>
        ? rawRubric
        : null;
    if (rubricMap == null) {
      issues.add(
        ContentIssue(
          severity: IssueSeverity.error,
          code: IssueCode.missingRubric,
          message: 'Item $id is missing rubricByOption.',
          itemId: id,
        ),
      );
      return null;
    }

    final Map<String, RubricEntry> rubricByOption = <String, RubricEntry>{};
    for (final MapEntry<String, dynamic> entry in rubricMap.entries) {
      final String optId = entry.key;
      if (!optionIds.contains(optId)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.missingRubric,
            message: 'Item $id rubric references unknown option "$optId".',
            itemId: id,
          ),
        );
        return null;
      }
      final dynamic rawEntry = entry.value;
      if (rawEntry is! Map<String, dynamic>) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.missingRubric,
            message: 'Item $id rubric for "$optId" is malformed.',
            itemId: id,
          ),
        );
        return null;
      }
      final String? feedback = readString(rawEntry['feedback']);
      if (feedback == null || feedback.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.rubricMissingFeedback,
            message: 'Item $id rubric for "$optId" is missing feedback.',
            itemId: id,
          ),
        );
        return null;
      }
      final dynamic rawScores = rawEntry['scores'];
      final Map<String, dynamic>? scoresMap = rawScores is Map<String, dynamic>
          ? rawScores
          : null;
      if (scoresMap == null) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.rubricMissingFeedback,
            message: 'Item $id rubric for "$optId" is missing scores.',
            itemId: id,
          ),
        );
        return null;
      }
      final Map<EqDimension, int> scores = <EqDimension, int>{};
      for (final MapEntry<String, dynamic> sEntry in scoresMap.entries) {
        final EqDimension? dim = EqDimensionX.tryParse(sEntry.key);
        if (dim == null) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.warning,
              code: IssueCode.unknownRubricDimension,
              message:
                  'Item $id rubric uses unknown dimension '
                  '"${sEntry.key}".',
              itemId: id,
            ),
          );
          continue;
        }
        final int? val = sEntry.value is int ? sEntry.value as int : null;
        if (val == null || val < 0 || val > maxRubricScore) {
          issues.add(
            ContentIssue(
              severity: IssueSeverity.error,
              code: IssueCode.rubricScoreOutOfRange,
              message:
                  'Item $id rubric dimension "${sEntry.key}" score out of '
                  'range (0..$maxRubricScore).',
              itemId: id,
            ),
          );
          return null;
        }
        scores[dim] = val;
      }
      if (scores.isEmpty) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.rubricMissingFeedback,
            message:
                'Item $id rubric for "$optId" has no valid dimension '
                'scores.',
            itemId: id,
          ),
        );
        return null;
      }
      _scanForUrls(feedback, id, issues);
      rubricByOption[optId] = RubricEntry(scores: scores, feedback: feedback);
    }

    // Every selectable option must carry a rubric so no choice scores silently
    // (PLAN §5.6). This also keeps the score denominator honest.
    for (final String optId in optionIds) {
      if (!rubricByOption.containsKey(optId)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.missingRubric,
            message: 'Item $id is missing a rubric for option "$optId".',
            itemId: id,
          ),
        );
        return null;
      }
    }

    final List<dynamic>? rawDims = json['skillDimensions'] is List<dynamic>
        ? json['skillDimensions'] as List<dynamic>
        : null;
    final List<EqDimension> skillDimensions = <EqDimension>[];
    if (rawDims != null) {
      for (final dynamic d in rawDims) {
        if (d is String) {
          final EqDimension? dim = EqDimensionX.tryParse(d);
          if (dim != null) skillDimensions.add(dim);
        }
      }
    }

    final String? followUpReflection = readString(json['followUpReflection']);

    return EqScenarioItem(
      id: id,
      domain: common.domain,
      contentType: common.contentType,
      skill: common.skill,
      difficulty: common.difficulty,
      locale: common.locale,
      prompt: common.prompt,
      instructions: common.instructions,
      explanation: common.explanation,
      hint: common.hint,
      estimatedSeconds: common.estimatedSeconds,
      pointsWeight: common.pointsWeight,
      tags: common.tags,
      contentVersion: common.contentVersion,
      attribution: common.attribution,
      status: common.status,
      options: options,
      scenarioContext: scenarioContext,
      rubricByOption: rubricByOption,
      skillDimensions: skillDimensions,
      followUpReflection: followUpReflection,
    );
  }

  static void _checkExpectedCounts(
    ContentManifest manifest,
    List<QuestionItem> items,
    List<ContentIssue> issues,
  ) {
    final Map<String, int>? expected = manifest.expectedItemCounts;
    if (expected == null) return;
    for (final MapEntry<String, int> entry in expected.entries) {
      final String domainKey = entry.key;
      final int expectedCount = entry.value;
      final int actual = items
          .where((QuestionItem i) => i.domain.name == domainKey)
          .length;
      if (actual < expectedCount) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.warning,
            code: IssueCode.insufficientCount,
            message:
                'Domain "$domainKey" has $actual items but the manifest '
                'expects at least $expectedCount.',
          ),
        );
      }
    }
  }

  static void _scanForUrls(String text, String id, List<ContentIssue> issues) {
    final String lowered = text.toLowerCase();
    for (final String prefix in _urlPrefixes) {
      if (lowered.contains(prefix)) {
        issues.add(
          ContentIssue(
            severity: IssueSeverity.warning,
            code: IssueCode.unexpectedUrl,
            message: 'Item $id contains a remote URL; content must be offline.',
            itemId: id,
          ),
        );
        return;
      }
    }
  }

  static String _asRaw(dynamic value) => value is String ? value : '';
}

/// Internal holder for the shared fields already validated for one item.
class _Common {
  const _Common({
    required this.domain,
    required this.contentType,
    required this.skill,
    required this.difficulty,
    required this.locale,
    required this.prompt,
    this.instructions,
    this.explanation,
    this.hint,
    this.estimatedSeconds,
    this.pointsWeight,
    required this.tags,
    this.contentVersion,
    this.attribution,
    required this.status,
  });

  final ContentDomain domain;
  final ContentType contentType;
  final String skill;
  final Difficulty difficulty;
  final String locale;
  final String prompt;
  final String? instructions;
  final String? explanation;
  final String? hint;
  final int? estimatedSeconds;
  final int? pointsWeight;
  final List<String> tags;
  final int? contentVersion;
  final String? attribution;
  final ContentStatus status;
}

class _ItemOutcome {
  const _ItemOutcome({this.item, this.issues = const <ContentIssue>[]});

  final QuestionItem? item;
  final List<ContentIssue> issues;
}
