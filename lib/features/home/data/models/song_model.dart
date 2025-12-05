
import 'package:equatable/equatable.dart';

int _safeIntParse(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

class SongModel extends Equatable {
  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName; 
  final String artworkUrl100;    
  final String previewUrl;      

  final int artistId;
  final int collectionId;

  const SongModel({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.artworkUrl100,
    required this.previewUrl,
    required this.artistId,
    required this.collectionId,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      trackId: _safeIntParse(json['trackId']),
      artistId: _safeIntParse(json['artistId']),
      collectionId: _safeIntParse(json['collectionId']),

      trackName: json['trackName'] as String? ?? 'Unknown Song',
      artistName: json['artistName'] as String? ?? 'Unknown Artist',
      collectionName: json['collectionName'] as String? ?? 'Unknown Album',
      artworkUrl100: json['artworkUrl100'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'artistId': artistId,
      'collectionId': collectionId,
      'trackName': trackName,
      'artistName': artistName,
      'collectionName': collectionName,
      'artworkUrl100': artworkUrl100,
      'previewUrl': previewUrl,
    };
  }

  String get highResArtworkUrl {
    return artworkUrl100.replaceAll('100x100bb', '600x600bb');
  }

  @override
  List<Object?> get props => [
    trackId,
    trackName,
    artistName,
    collectionName,
    artworkUrl100,
    previewUrl,
    artistId,
    collectionId,
  ];
}
