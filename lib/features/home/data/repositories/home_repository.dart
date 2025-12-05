
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:music_explorer_app/core/constants/api_constants.dart';
import '../models/song_model.dart';

class HomeRepository {
  HomeRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            responseType: ResponseType.json,
          ),
        );

  final Dio _dio;

  Future<List<SongModel>> fetchSongs({
    required String term,
    required int offset,
  }) async {
    final effectiveTerm = term.isEmpty ? ApiConstants.defaultSearchTerm : term;

    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'term': effectiveTerm,
          'entity': 'song',
          'limit': ApiConstants.pageSize,
          'offset': offset,
          'country': 'US', 
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load songs: HTTP ${response.statusCode}');
      }

      dynamic rawData = response.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData) as Map<String, dynamic>;
      }

      if (rawData is! Map<String, dynamic>) {
        throw Exception('Unexpected response format from iTunes API.');
      }

      final results = rawData['results'];
      if (results is! List) {
        return const []; 
      }

      return results
          .where((item) =>
              item is Map<String, dynamic> && item['kind']?.toString() == 'song')
          .map<SongModel>((json) => SongModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'Network Error: Failed to connect to iTunes API. Details: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unexpected error occurred during API fetch: ${e.toString()}');
    }
  }
}
