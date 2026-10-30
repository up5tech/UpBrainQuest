/// Thrown when the installed content bank cannot satisfy a requested session.
///
/// Per PLAN §5.7 the engine must never silently return fewer questions than
/// requested; it reports the problem instead so the UI can show a clear,
/// recoverable message.
class QuestionSelectionFailure implements Exception {
  const QuestionSelectionFailure(this.message);

  final String message;

  @override
  String toString() => 'QuestionSelectionFailure: $message';
}
