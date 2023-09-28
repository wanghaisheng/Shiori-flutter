import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'game_codes_bloc.freezed.dart';
part 'game_codes_event.dart';
part 'game_codes_state.dart';

const _initialState = GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []);

class GameCodesBloc extends Bloc<GameCodesEvent, GameCodesState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final ApiService _apiService;
  final NetworkService _networkService;
  final GenshinService _genshinService;

  GameCodesBloc(
    this._dataService,
    this._telemetryService,
    this._apiService,
    this._networkService,
    this._genshinService,
  ) : super(_initialState);

  @override
  Stream<GameCodesState> mapEventToState(GameCodesEvent event) async* {
    if (event is _Refresh) {
      final isInternetAvailable = await _networkService.isInternetAvailable();
      if (!isInternetAvailable) {
        yield state.copyWith.call(isInternetAvailable: false);
        yield state.copyWith.call(isInternetAvailable: null);
        return;
      }
      yield state.copyWith(isBusy: true);
    }

    final s = await event.maybeWhen(
      init: () async => _init(),
      markAsUsed: (code, wasUsed) async => _markAsUsed(code, wasUsed),
      refresh: () async => _refresh(),
      orElse: () async => _initialState,
    );

    yield s;

    if (s.unknownErrorOccurred == true) {
      yield s.copyWith(unknownErrorOccurred: false, isBusy: false);
    }
  }

  Future<GameCodesState> _init() async {
    await _telemetryService.trackGameCodesOpened();
    return _buildInitialState();
  }

  Future<GameCodesState> _markAsUsed(String code, bool wasUsed) async {
    await _dataService.gameCodes.markCodeAsUsed(code, wasUsed: wasUsed);
    return _buildInitialState();
  }

  Future<GameCodesState> _refresh() async {
    final response = await _apiService.getGameCodes();
    if (!response.succeed) {
      return state.copyWith(unknownErrorOccurred: true);
    }

    final gameCodes = response.result.map((e) {
      return GameCodeModel(
        code: e.code,
        discoveredOn: e.discoveredOn,
        expiredOn: e.expiredOn,
        region: e.region,
        isExpired: e.isExpired,
        isUsed: false,
        rewards: e.rewards.map((r) {
          final key = _getMaterialKey(r.wikiName, r.type);
          final img = _genshinService.materials.getMaterialImg(key);
          return ItemAscensionMaterialModel(quantity: r.quantity, type: r.type, key: key, image: img);
        }).toList(),
      );
    }).toList();
    await _dataService.gameCodes.saveGameCodes(gameCodes);

    await _telemetryService.trackGameCodesOpened();
    return _buildInitialState();
  }

  GameCodesState _buildInitialState() {
    final gameCodes = _dataService.gameCodes.getAllGameCodes();

    return GameCodesState.loaded(
      workingGameCodes: gameCodes.where((code) => !code.isExpired).toList()..sort(_sortGameCodes),
      expiredGameCodes: gameCodes.where((code) => code.isExpired).toList()..sort(_sortGameCodes),
    );
  }

  int _sortGameCodes(GameCodeModel x, GameCodeModel y) {
    if (y.discoveredOn == null && x.discoveredOn == null) {
      return 0;
    }

    if (y.discoveredOn != null && x.discoveredOn != null) {
      return y.discoveredOn!.compareTo(x.discoveredOn!);
    }

    if (y.discoveredOn != null) {
      return 1;
    }

    return -1;
  }

  String _getMaterialKey(String wikiName, MaterialType type) {
    final relatedMaterials = _genshinService.materials.getMaterials(type);

    final map = <String, int>{};
    for (final material in relatedMaterials) {
      var matches = 0;
      final characters = wikiName.toLowerCase().split('');
      for (final char in characters) {
        if (material.key.contains(char)) {
          matches++;
        } else {
          matches--;
        }
      }
      map.putIfAbsent(material.key, () => matches);
    }

    final pickedKey = map.entries.orderBy((el) => el.value).last.key;
    return pickedKey;
  }
}
