import 'dart:convert';

import 'package:delivery_boy/main.export.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageBase {
  LocalStorageBase();

  final SharedPreferences _sp = locate.get<SharedPreferences>();

  @protected
  Future<bool> save<T extends Object>(String key, T value) async {
    try {
      if (value is String) return _sp.setString(key, value);
      if (value is int) return _sp.setInt(key, value);
      if (value is bool) return _sp.setBool(key, value);
      if (value is double) return _sp.setDouble(key, value);
      if (value is List<String>) return _sp.setStringList(key, value);
      if (value is Map) {
        return _sp.setString(key, jsonEncode(value));
      }

      final json = jsonEncode(value);
      return _sp.setString(key, json);
    } catch (e) {
      // Unsupported type
      Logger(e, 'StorageService.save');
      throw Exception('Unsupported type: ${value.runtimeType}');
    }
  }

  Future<bool> appendToList(
    String key,
    String value, {
    bool repositionOnDuplicate = true,
    int limit = 50,
  }) async {
    final list = getStringList(key)?.toList() ?? [];

    if (list.contains(value) && repositionOnDuplicate) list.remove(value);

    if (list.length >= limit) list.removeLast();

    list.insert(0, value);
    return save(key, list);
  }

  String? getString(String key) => _sp.getString(key);

  int? getInt(String key) => _sp.getInt(key);

  bool? getBool(String key) => _sp.getBool(key);

  double? getDouble(String key) => _sp.getDouble(key);

  List<String>? getStringList(String key) => _sp.getStringList(key);

  Map<String, dynamic>? getMap(String key) {
    return Either.tryCatch(
      () {
        final data = _sp.getString(key);
        if (data == null) return null;
        return jsonDecode(data) as Map<String, dynamic>?;
      },
      (o, s) => throw Error.throwWithStackTrace(o, s),
    ).fold((l) => null, (r) => r);
  }

  Future<bool> delete(String key) async => _sp.remove(key);

  Future<bool> clear() async => _sp.clear();

  bool containsKey(String key) => _sp.containsKey(key);

  Set<String> getKeys() => _sp.getKeys();

  Future<void> reload() async => _sp.reload();
}
