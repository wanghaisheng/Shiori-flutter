import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/material_type.dart';

part 'material_card_model.freezed.dart';

@freezed
abstract class MaterialCardModel implements _$MaterialCardModel {
  const factory MaterialCardModel.item({
    @required String key,
    @required String name,
    @required int rarity,
    @required String image,
    @required MaterialType type,
    @Default(0) int quantity,
  }) = _Item;
}
