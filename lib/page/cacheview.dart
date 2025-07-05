import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/fileHandler.dart';

class ICCacheView extends StatelessWidget {
  String _cacheId;
  ICCacheView({super.key, required String cacheId}) : _cacheId = cacheId;
  void changeCacheId(String cacheId) {
    _cacheId = cacheId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(_cacheId)]);
  }
}
