class AssetException implements Exception {
  final String message;
  const AssetException([this.message = 'فشل في قراءة بيانات الدورة']);

  @override
  String toString() => 'AssetException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'فشل في حفظ أو قراءة تقدم الطالب']);

  @override
  String toString() => 'StorageException: $message';
}

class VideoPlayerException implements Exception {
  final String message;
  const VideoPlayerException([this.message = 'تعذر تشغيل ملف الفيديو']);

  @override
  String toString() => 'VideoPlayerException: $message';
}
