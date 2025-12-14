import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/domain/entities/video.dart';

void main() {
  group('Video', () {
    test('should create Video from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'key': 'abc123',
        'name': 'Trailer',
        'site': 'YouTube',
        'type': 'Trailer',
        'official': true,
        'published_at': '2023-01-01',
      };

      // Act
      final video = Video.fromJson(json);

      // Assert
      expect(video.id, '1');
      expect(video.key, 'abc123');
      expect(video.name, 'Trailer');
      expect(video.site, 'YouTube');
      expect(video.type, 'Trailer');
      expect(video.official, true);
      expect(video.publishedAt, '2023-01-01');
    });

    test('should handle int id in JSON', () {
      // Arrange
      final json = {
        'id': 123,
        'key': 'abc123',
        'name': 'Trailer',
        'site': 'YouTube',
        'type': 'Trailer',
        'official': false,
      };

      // Act
      final video = Video.fromJson(json);

      // Assert
      expect(video.id, '123');
    });

    test('isYouTubeTrailer should return true for YouTube trailer', () {
      // Arrange
      final video = Video(
        id: '1',
        key: 'abc123',
        name: 'Trailer',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTubeTrailer, true);
    });

    test('isYouTubeTrailer should return true for YouTube teaser', () {
      // Arrange
      final video = Video(
        id: '1',
        key: 'abc123',
        name: 'Teaser',
        site: 'YouTube',
        type: 'Teaser',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTubeTrailer, true);
    });

    test('isYouTubeTrailer should return false for non-YouTube video', () {
      // Arrange
      final video = Video(
        id: '1',
        key: 'abc123',
        name: 'Trailer',
        site: 'Vimeo',
        type: 'Trailer',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTubeTrailer, false);
    });

    test('isYouTubeTrailer should return false for empty key', () {
      // Arrange
      final video = Video(
        id: '1',
        key: '',
        name: 'Trailer',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTubeTrailer, false);
    });

    test('isYouTube should return true for YouTube video with key', () {
      // Arrange
      final video = Video(
        id: '1',
        key: 'abc123',
        name: 'Video',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTube, true);
    });

    test('isYouTube should return false for non-YouTube video', () {
      // Arrange
      final video = Video(
        id: '1',
        key: 'abc123',
        name: 'Video',
        site: 'Vimeo',
        type: 'Trailer',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTube, false);
    });

    test('isYouTube should return false for empty key', () {
      // Arrange
      final video = Video(
        id: '1',
        key: '',
        name: 'Video',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      );

      // Act & Assert
      expect(video.isYouTube, false);
    });
  });
}
