import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_lms/features/courses/domain/entities/course.dart';
import 'package:thaheen_lms/features/courses/domain/entities/lesson.dart';
import 'package:thaheen_lms/features/courses/domain/entities/section.dart';
import 'package:thaheen_lms/features/progress/domain/entities/lesson_progress.dart';
import 'package:thaheen_lms/features/progress/domain/services/progress_service.dart';

void main() {
  late ProgressService progressService;

  final testCourse = Course(
    id: 'course-1',
    title: 'مقدمة في التشريح',
    instructor: 'د. سارة',
    thumbnail: 'assets/images/anatomy.jpg',
    sections: [
      Section(
        id: 's1',
        title: 'الوحدة الأولى',
        lessons: [
          const Lesson(
            id: 'l1',
            title: 'الدرس الأول',
            durationSec: 100,
            video: 'assets/videos/lesson1.mp4',
          ),
          const Lesson(
            id: 'l2',
            title: 'الدرس الثاني',
            durationSec: 100,
            video: 'assets/videos/lesson2.mp4',
          ),
        ],
      ),
      Section(
        id: 's2',
        title: 'الوحدة الثانية',
        lessons: [
          const Lesson(
            id: 'l3',
            title: 'الدرس الثالث',
            durationSec: 100,
            video: 'assets/videos/lesson3.mp4',
          ),
          const Lesson(
            id: 'l4',
            title: 'الدرس الرابع',
            durationSec: 100,
            video: 'assets/videos/lesson1.mp4',
          ),
        ],
      ),
    ],
  );

  setUp(() {
    progressService = const ProgressService();
  });

  group('ProgressService Tests', () {
    group('1. 90% Completion Rule (shouldComplete)', () {
      test('should return false when watched position is under 90%', () {
        expect(
          progressService.shouldComplete(
            currentPositionSec: 89,
            totalDurationSec: 100,
          ),
          isFalse,
        );

        expect(
          progressService.shouldComplete(
            currentPositionSec: 45,
            totalDurationSec: 100,
          ),
          isFalse,
        );

        expect(
          progressService.shouldComplete(
            currentPositionSec: 0,
            totalDurationSec: 100,
          ),
          isFalse,
        );
      });

      test('should return true when watched position is exactly or over 90%', () {
        expect(
          progressService.shouldComplete(
            currentPositionSec: 90,
            totalDurationSec: 100,
          ),
          isTrue,
        );

        expect(
          progressService.shouldComplete(
            currentPositionSec: 95,
            totalDurationSec: 100,
          ),
          isTrue,
        );

        expect(
          progressService.shouldComplete(
            currentPositionSec: 100,
            totalDurationSec: 100,
          ),
          isTrue,
        );
      });

      test('should handle edge cases like totalDuration <= 0 gracefully', () {
        expect(
          progressService.shouldComplete(
            currentPositionSec: 50,
            totalDurationSec: 0,
          ),
          isFalse,
        );

        expect(
          progressService.shouldComplete(
            currentPositionSec: -10,
            totalDurationSec: 100,
          ),
          isFalse,
        );
      });
    });

    group('2. Sequential Unlock Rule (isLessonUnlocked)', () {
      test('the first lesson of the course should always be unlocked', () {
        final isUnlocked = progressService.isLessonUnlocked(
          lessonId: 'l1',
          course: testCourse,
          completedLessonIds: {}, // no lessons completed
        );

        expect(isUnlocked, isTrue);
      });

      test('a subsequent lesson is locked if the previous lesson is not completed', () {
        final isL2Unlocked = progressService.isLessonUnlocked(
          lessonId: 'l2',
          course: testCourse,
          completedLessonIds: {},
        );

        expect(isL2Unlocked, isFalse);

        final isL3Unlocked = progressService.isLessonUnlocked(
          lessonId: 'l3',
          course: testCourse,
          completedLessonIds: {'l1'}, // l2 is not completed yet
        );

        expect(isL3Unlocked, isFalse);
      });

      test('a subsequent lesson is unlocked once the previous lesson is completed', () {
        final isL2Unlocked = progressService.isLessonUnlocked(
          lessonId: 'l2',
          course: testCourse,
          completedLessonIds: {'l1'},
        );

        expect(isL2Unlocked, isTrue);

        final isL3Unlocked = progressService.isLessonUnlocked(
          lessonId: 'l3',
          course: testCourse,
          completedLessonIds: {'l1', 'l2'},
        );

        expect(isL3Unlocked, isTrue);
      });

      test('returns false for unknown lesson id', () {
        expect(
          progressService.isLessonUnlocked(
            lessonId: 'non-existent',
            course: testCourse,
            completedLessonIds: {'l1', 'l2', 'l3', 'l4'},
          ),
          isFalse,
        );
      });
    });

    group('3. Course Progress % Calculation (calculateCourseProgress)', () {
      test('should return 0.0 when no lessons are completed', () {
        final progress = progressService.calculateCourseProgress(
          course: testCourse,
          completedLessonIds: {},
        );

        expect(progress, 0.0);
      });

      test('should calculate correct fraction of completed lessons', () {
        // 1 out of 4 lessons completed = 0.25 (25%)
        final progress1 = progressService.calculateCourseProgress(
          course: testCourse,
          completedLessonIds: {'l1'},
        );
        expect(progress1, 0.25);

        // 2 out of 4 lessons completed = 0.50 (50%)
        final progress2 = progressService.calculateCourseProgress(
          course: testCourse,
          completedLessonIds: {'l1', 'l2'},
        );
        expect(progress2, 0.50);

        // All 4 lessons completed = 1.0 (100%)
        final progressFull = progressService.calculateCourseProgress(
          course: testCourse,
          completedLessonIds: {'l1', 'l2', 'l3', 'l4'},
        );
        expect(progressFull, 1.0);
      });
    });

    group('4. Continue Watching Item Selection (getContinueWatching)', () {
      test('should return null when no lessons are in progress', () {
        final item = progressService.getContinueWatching(
          courses: [testCourse],
          progressMap: {},
        );

        expect(item, isNull);
      });

      test('should return the lesson with progress that is not completed', () {
        final now = DateTime.now();
        final item = progressService.getContinueWatching(
          courses: [testCourse],
          progressMap: {
            'l1': LessonProgress(
              lessonId: 'l1',
              courseId: testCourse.id,
              lastPositionSeconds: 40,
              totalDurationSeconds: 100,
              isCompleted: false,
              updatedAt: now,
            ),
          },
        );

        expect(item, isNotNull);
        expect(item!.lesson.id, 'l1');
        expect(item.progress.lastPositionSeconds, 40);
      });

      test('should pick the most recently updated lesson when multiple are in progress', () {
        final olderTime = DateTime(2026, 1, 1, 10, 0);
        final newerTime = DateTime(2026, 1, 1, 12, 0);

        final item = progressService.getContinueWatching(
          courses: [testCourse],
          progressMap: {
            'l1': LessonProgress(
              lessonId: 'l1',
              courseId: testCourse.id,
              lastPositionSeconds: 20,
              totalDurationSeconds: 100,
              isCompleted: false,
              updatedAt: olderTime,
            ),
            'l2': LessonProgress(
              lessonId: 'l2',
              courseId: testCourse.id,
              lastPositionSeconds: 50,
              totalDurationSeconds: 100,
              isCompleted: false,
              updatedAt: newerTime,
            ),
          },
        );

        expect(item, isNotNull);
        expect(item!.lesson.id, 'l2');
      });
    });
  });
}
