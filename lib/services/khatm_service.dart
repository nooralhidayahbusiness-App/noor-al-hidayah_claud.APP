import '../services/user_service.dart';

class KhatmPlan {
  final bool active;
  final String startDate;   // yyyy-mm-dd
  final String endDate;     // yyyy-mm-dd
  final int totalPages;     // 604
  final int pagesPerDay;
  final int pagesRead;
  final String lastReadDate;
  final int lastReadPage;
  final int streak;
  final List<Map<String, dynamic>> history;
  final int completedKhatmas;

  const KhatmPlan({
    required this.active,
    required this.startDate,
    required this.endDate,
    required this.totalPages,
    required this.pagesPerDay,
    required this.pagesRead,
    required this.lastReadDate,
    required this.lastReadPage,
    required this.streak,
    required this.history,
    required this.completedKhatmas,
  });

  static const empty = KhatmPlan(
    active: false,
    startDate: '',
    endDate: '',
    totalPages: 604,
    pagesPerDay: 20,
    pagesRead: 0,
    lastReadDate: '',
    lastReadPage: 0,
    streak: 0,
    history: [],
    completedKhatmas: 0,
  );

  int get remainingPages => (totalPages - pagesRead).clamp(0, totalPages);
  double get progress =>
      totalPages == 0 ? 0 : (pagesRead / totalPages).clamp(0.0, 1.0);
  bool get isComplete => pagesRead >= totalPages;

  int get daysLeft {
    if (endDate.isEmpty) return 0;
    final end = DateTime.tryParse(endDate);
    if (end == null) return 0;
    final now = DateTime.now();
    final diff = end.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// الصفحات المطلوبة اليوم.
  int get todayWard => pagesPerDay;

  int get todayRead {
    if (history.isEmpty) return 0;
    final today = _todayKey();
    for (final h in history.reversed) {
      if (h['date'] == today) {
        return (h['pages'] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }

  int get todayRemaining =>
      (todayWard - todayRead).clamp(0, todayWard);

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static KhatmPlan fromMap(Map<String, dynamic> m) {
    final history = (m['history'] as List?) ?? [];
    return KhatmPlan(
      active: (m['khatmActive'] as bool?) ?? false,
      startDate: (m['startDate'] as String?) ?? '',
      endDate: (m['endDate'] as String?) ?? '',
      totalPages: (m['totalPages'] as num?)?.toInt() ?? 604,
      pagesPerDay: (m['pagesPerDay'] as num?)?.toInt() ?? 20,
      pagesRead: (m['pagesRead'] as num?)?.toInt() ?? 0,
      lastReadDate: (m['lastReadDate'] as String?) ?? '',
      lastReadPage: (m['lastReadPage'] as num?)?.toInt() ?? 0,
      streak: (m['streak'] as num?)?.toInt() ?? 0,
      history: history
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      completedKhatmas: (m['completedKhatmas'] as num?)?.toInt() ?? 0,
    );
  }
}

class KhatmService {
  KhatmService._();
  static final KhatmService instance = KhatmService._();

  Future<KhatmPlan> load() async {
    try {
      final p = await userService.loadProgress('quran');
      return KhatmPlan.fromMap(p);
    } catch (_) {
      return KhatmPlan.empty;
    }
  }

  Future<void> startPlan({
    required int days,
    required int pagesPerDay,
  }) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: days - 1));
    await userService.saveProgress('quran', {
      'khatmActive': true,
      'startDate': KhatmPlan.dateKey(now),
      'endDate': KhatmPlan.dateKey(end),
      'totalPages': 604,
      'pagesPerDay': pagesPerDay,
      'pagesRead': 0,
      'lastReadDate': '',
      'lastReadPage': 0,
      'streak': 0,
      'history': [],
    });
  }

  /// يحدّث رقم الصفحة الحالي.
  /// يرجع: (هل زاد؟ كم صفحة؟). null إذا لم يتغير.
  Future<int> updatePage({
    required KhatmPlan plan,
    required int newPage,
  }) async {
    final old = plan.lastReadPage;
    if (newPage <= old) return 0;
    final delta = newPage - old;
    final today = KhatmPlan.dateKey(DateTime.now());

    // تحديث الـ streak
    final yesterday = KhatmPlan.dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    int newStreak = plan.streak;
    if (plan.lastReadDate == today) {
      // نفس اليوم، الـ streak لا يتغير
    } else if (plan.lastReadDate == yesterday) {
      newStreak = plan.streak + 1;
    } else {
      newStreak = 1;
    }

    // تحديث الـ history
    final history = List<Map<String, dynamic>>.from(plan.history);
    final idx = history.indexWhere((h) => h['date'] == today);
    if (idx >= 0) {
      history[idx] = {
        'date': today,
        'pages': ((history[idx]['pages'] as num?)?.toInt() ?? 0) + delta,
      };
    } else {
      history.add({'date': today, 'pages': delta});
    }

    // الحد الأقصى 30 يوم
    while (history.length > 30) {
      history.removeAt(0);
    }

    final total = plan.pagesRead + delta;

    await userService.saveProgress('quran', {
      'pagesRead': total,
      'lastReadPage': newPage,
      'lastReadDate': today,
      'streak': newStreak,
      'history': history,
      'khatmActive': total < plan.totalPages,
    });

    return delta;
  }

  Future<void> completeKhatma(KhatmPlan plan) async {
    await userService.saveProgress('quran', {
      'khatmActive': false,
      'completedKhatmas': plan.completedKhatmas + 1,
      'pagesRead': 604,
      'lastReadPage': 604,
    });
  }

  Future<void> reset() async {
    await userService.saveProgress('quran', {
      'khatmActive': false,
      'startDate': '',
      'endDate': '',
      'pagesRead': 0,
      'lastReadPage': 0,
      'lastReadDate': '',
      'streak': 0,
      'history': [],
    });
  }
}

final khatmService = KhatmService.instance;
