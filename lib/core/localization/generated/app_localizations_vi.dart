// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'UpBrainQuest';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navExplore => 'Khám phá';

  @override
  String get navProgress => 'Tiến độ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get homeGreeting => 'Rèn luyện trí óc, mỗi ngày một thử thách';

  @override
  String get homeStartQuickQuest => 'Bắt đầu Thử thách nhanh';

  @override
  String get homeStartIqChallenge => 'Bắt đầu Thử thách IQ';

  @override
  String get homeProgressSummary => 'Tiến độ của bạn';

  @override
  String get homeNoProgress =>
      'Chưa hoàn thành thử thách nào. Kết quả của bạn sẽ xuất hiện ở đây.';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get notAvailableYet => 'Chế độ này chưa khả dụng.';

  @override
  String get exploreTitle => 'Khám phá chế độ';

  @override
  String get exploreSubtitle =>
      'Chọn loại thử thách. Việc chọn độ khó và độ dài sẽ có trong phiên bản sau.';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get progressEmpty =>
      'Chưa có phiên chơi nào. Hoàn thành một thử thách để xem lịch sử ở đây.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsPreferences => 'Tùy chọn';

  @override
  String get settingReducedMotion => 'Giảm chuyển động';

  @override
  String get settingReducedMotionHint =>
      'Hạn chế hiệu ứng động trong toàn ứng dụng.';

  @override
  String get settingSound => 'Hiệu ứng âm thanh';

  @override
  String get settingHaptics => 'Phản hồi rung';

  @override
  String get settingAbout => 'Giới thiệu & lưu ý về điểm số';

  @override
  String get settingsLoadError => 'Không tải được cài đặt.';

  @override
  String get settingLanguage => 'Ngôn ngữ';

  @override
  String get settingLanguageHint => 'Chọn ngôn ngữ cho giao diện và câu hỏi.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get aboutTitle => 'Giới thiệu UpBrainQuest';

  @override
  String get aboutClose => 'Đóng';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutLicenses => 'Giấy phép';

  @override
  String get aboutOffline =>
      'Hoạt động hoàn toàn ngoại tuyến. Không tài khoản, không mạng, không phân tích, không quảng cáo. Mọi nội dung và tiến độ đều lưu trên thiết bị này.';

  @override
  String get aboutDisclaimer =>
      'Điểm của UpBrainQuest tóm tắt kết quả của bạn trong các thử thách trò chơi này. Đây không phải điểm IQ chuẩn hóa, không phải đánh giá EQ lâm sàng, không phải chẩn đoán và không phải thước đo trí tuệ hay năng lực cảm xúc đã được kiểm định. Kết quả có thể thay đổi tùy theo mức độ quen thuộc, sự chú ý, bối cảnh, ngôn ngữ và các câu hỏi trong phiên chơi.';

  @override
  String get modeQuickQuest => 'Thử thách nhanh';

  @override
  String get modeQuickQuestDesc =>
      'Kết hợp cân bằng giữa lập luận, trí nhớ và tình huống EQ.';

  @override
  String get modeIqChallenge => 'Thử thách IQ';

  @override
  String get modeIqChallengeDesc =>
      'Câu đố lập luận: dãy số, quy luật và logic.';

  @override
  String get modePuzzleSprint => 'Giải đố nhanh';

  @override
  String get modePuzzleSprintDesc => 'Các dạng câu đố tương tác ngắn.';

  @override
  String get modeEqChallenge => 'Thử thách EQ';

  @override
  String get modeEqChallengeDesc =>
      'Các lựa chọn tình huống giúp luyện phản tư và giao tiếp.';

  @override
  String get modeDailyChallenge => 'Thử thách hằng ngày';

  @override
  String get modeDailyChallengeDesc =>
      'Thử thách 5 câu chọn theo ngày hôm nay, chạy trên máy.';

  @override
  String get sessionUntimedNote =>
      'Chế độ này không tính giờ — cứ thong thả suy nghĩ.';

  @override
  String get sessionTimedNote => 'Phiên bản tính giờ chưa có trong bản này.';

  @override
  String get sessionStart => 'Bắt đầu phiên';

  @override
  String get sessionSubmit => 'Gửi';

  @override
  String get sessionContinue => 'Tiếp tục';

  @override
  String get sessionCorrect => 'Đúng';

  @override
  String get sessionIncorrect => 'Chưa đúng';

  @override
  String get sessionExplanation => 'Giải thích';

  @override
  String get sessionHint => 'Gợi ý';

  @override
  String get sessionResultTitle => 'Hoàn thành phiên chơi';

  @override
  String get sessionIqScoreLabel => 'Điểm Thử thách IQ';

  @override
  String get sessionScoreDisclaimer =>
      'Đây là điểm trong trò chơi dựa trên các câu hỏi của phiên này. Đây không phải kết quả IQ chuẩn hóa, không phải thước đo lâm sàng và không phải chẩn đoán.';

  @override
  String get sessionAccuracy => 'Độ chính xác';

  @override
  String get sessionReview => 'Xem lại câu trả lời';

  @override
  String get sessionPlayAgain => 'Chơi lại';

  @override
  String get sessionBackHome => 'Về Trang chủ';

  @override
  String get sessionAbandonTitle => 'Rời phiên chơi này?';

  @override
  String get sessionAbandonBody =>
      'Tiến độ của bạn trong phiên này sẽ mất nếu rời đi ngay bây giờ.';

  @override
  String get sessionAbandonConfirm => 'Rời đi';

  @override
  String get sessionAbandonCancel => 'Chơi tiếp';

  @override
  String get sessionNotAvailable => 'Chế độ này chưa khả dụng.';

  @override
  String get sessionNoContent => 'Chế độ này chưa có đủ câu hỏi.';

  @override
  String get sessionMemoryReady => 'Tôi đã nhớ';

  @override
  String get sessionMemoryRecall => 'Nhập lại dãy';

  @override
  String get sessionMemoryClear => 'Xóa';

  @override
  String get sessionReorderHint => 'Kéo các ô vào đúng thứ tự.';

  @override
  String get sessionQuestionOf => 'Câu';

  @override
  String get sessionEqScenarioContext => 'Tình huống';

  @override
  String get sessionEqReflection => 'Phản tư';

  @override
  String get sessionEqFollowUp => 'Suy ngẫm thêm';

  @override
  String get sessionYourResponse => 'Câu trả lời của bạn';

  @override
  String get sessionEqScoreLabel => 'Điểm Luyện EQ';

  @override
  String get sessionEqScoreDisclaimer =>
      'Đây là điểm luyện tập trong trò chơi dựa trên bảng điểm của phiên này. Đây không phải đánh giá EQ lâm sàng, không phải chẩn đoán và không phải thước đo năng lực cảm xúc đã được kiểm định.';

  @override
  String get sessionEqDimensionsTitle => 'Bạn đã tập trung vào đâu';

  @override
  String get sessionEqNoScore => 'Chưa có điểm luyện tập';

  @override
  String get sessionEqReviewHeading => 'Phản tư của bạn';

  @override
  String get sessionYourAnswer => 'Câu trả lời của bạn';

  @override
  String get sessionCorrectAnswer => 'Đáp án đúng';

  @override
  String get sessionNotAnswered => 'Chưa trả lời';

  @override
  String get sessionRubricSummary => 'Tiêu chí';

  @override
  String get sessionResultStatus => 'Kết quả';

  @override
  String get sessionQuestionsCompleted => 'Số câu đã hoàn thành';

  @override
  String get sessionIncompleteNote => 'Một số câu chưa được trả lời.';

  @override
  String get sessionResultError => 'Không thể hiển thị kết quả này.';

  @override
  String get sessionQuickQuestMixUnavailable =>
      'Chưa đủ câu hỏi để tạo Thử thách nhanh cân bằng.';

  @override
  String get sessionSaving => 'Đang lưu vào lịch sử…';

  @override
  String get sessionSaved => 'Đã lưu vào lịch sử';

  @override
  String get sessionSaveFailed => 'Không thể lưu phiên này.';

  @override
  String get sessionSaveRetry => 'Thử lại';

  @override
  String get progressLoadError => 'Không tải được tiến độ của bạn.';

  @override
  String get progressSessionsCompleted => 'Số phiên đã hoàn thành';

  @override
  String get progressBestIq => 'Điểm Thử thách IQ cao nhất';

  @override
  String get progressBestEq => 'Điểm Luyện EQ cao nhất';

  @override
  String get progressRecentTitle => 'Kết quả gần đây';

  @override
  String get homeProgressError => 'Không tải được tiến độ của bạn.';

  @override
  String get resetLocalData => 'Xóa dữ liệu cục bộ';

  @override
  String get resetLocalDataBody =>
      'Thao tác này xóa vĩnh viễn lịch sử phiên chơi, thành tựu và chuỗi ngày trên thiết bị này. Tùy chọn của bạn được giữ nguyên.';

  @override
  String get resetLocalDataConfirm => 'Xóa';

  @override
  String get resetLocalDataCancel => 'Hủy';

  @override
  String get resetLocalDataDone => 'Đã xóa lịch sử cục bộ.';

  @override
  String get resetLocalDataFailed => 'Không thể xóa dữ liệu cục bộ.';

  @override
  String get dailyDoneToday => 'Đã làm hôm nay';

  @override
  String get dailyLocalNote =>
      'Tạo trên thiết bị này — không phải cuộc thi toàn cầu.';

  @override
  String get achievementsTitle => 'Thành tựu';

  @override
  String get achievementUnlocked => 'Đã mở khóa';

  @override
  String get achievementsLoadError => 'Không tải được thành tựu.';

  @override
  String get streakDaySuffix => 'ngày liên tiếp';

  @override
  String get streakNone => 'Chưa có chuỗi ngày';

  @override
  String get streakLocalNote =>
      'Chỉ trên thiết bị này — không được máy chủ xác nhận.';

  @override
  String get achievementFirstQuestTitle => 'Thử thách đầu tiên';

  @override
  String get achievementFirstQuestDesc => 'Hoàn thành phiên chơi đầu tiên.';

  @override
  String get achievementFiveQuestsTitle => 'Năm thử thách hoàn thành';

  @override
  String get achievementFiveQuestsDesc => 'Hoàn thành năm phiên chơi.';

  @override
  String get achievementReasoningTitle => 'Nhà khám phá lập luận';

  @override
  String get achievementReasoningDesc => 'Hoàn thành ba phiên lập luận.';

  @override
  String get achievementReflectionTitle => 'Nhà khám phá phản tư';

  @override
  String get achievementReflectionDesc => 'Hoàn thành ba phiên EQ.';

  @override
  String get achievementConsistentTitle => 'Người chơi bền bỉ';

  @override
  String get achievementConsistentDesc => 'Chơi vào ba ngày liên tiếp.';

  @override
  String get retry => 'Thử lại';

  @override
  String get sessionMemoryDelete => 'Xóa';

  @override
  String get sessionCorrectSequence => 'Dãy đúng';

  @override
  String get sessionYourSequence => 'Dãy của bạn';

  @override
  String get sessionCorrectOrder => 'Thứ tự đúng';

  @override
  String get eqDimEmotionAwareness => 'Nhận biết cảm xúc';

  @override
  String get eqDimSelfRegulation => 'Điều chỉnh cảm xúc';

  @override
  String get eqDimPerspectiveTaking => 'Đặt mình vào vị trí người khác';

  @override
  String get eqDimConstructiveCommunication => 'Giao tiếp mang tính xây dựng';

  @override
  String get eqDimBoundariesAndAgency => 'Ranh giới & quyền tự quyết';

  @override
  String correctOutOf(int correct, int total) {
    return '$correct / $total đúng';
  }

  @override
  String fractionOf(int value, int total) {
    return '$value / $total';
  }
}
