import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';

class StatesService {
  final ApiClient _apiClient;

  StatesService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StateEntity>> getAllStates() async {
    try {
      final response = await _apiClient.get(ApiConstants.states);
      final rawData = response.data;
      final List<dynamic> listData;
      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        listData = rawData['data'] as List;
      } else {
        listData = [];
      }
      return listData
          .map((json) => StateEntity.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      if (e is DioException) {
        debugPrint('[StatesService] Failed fetching states from ${e.requestOptions.uri} (Status: ${e.response?.statusCode}): ${e.message ?? e.error}');
      } else {
        debugPrint('[StatesService] Failed fetching states: $e');
      }
      rethrow;
    }
  }

  Future<List<DistrictEntity>> getDistricts(String stateId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.states}/$stateId/districts');
      final rawData = response.data;
      final List<dynamic> listData;
      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        listData = rawData['data'] as List;
      } else {
        listData = [];
      }
      return listData
          .map((json) => DistrictEntity.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      if (e is DioException) {
        debugPrint('[StatesService] Failed fetching districts for stateId=$stateId from ${e.requestOptions.uri} (Status: ${e.response?.statusCode}): ${e.message ?? e.error}');
      } else {
        debugPrint('[StatesService] Failed fetching districts for stateId=$stateId: $e');
      }
      rethrow;
    }
  }
}
