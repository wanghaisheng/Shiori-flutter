import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class WishSimulatorDataService implements BaseDataService {
  Future<WishSimulatorBannerCountPerType> getBannerCountPerType(BannerItemType type, Map<int, int> defaultXStarCount);

  Future<void> saveBannerItemPullHistory(String bannerKey, String itemKey, ItemType itemType);

  Future<void> clearBannerItemPullHistory(String bannerKey);

  Future<void> clearAllBannerItemPullHistory();

  List<WishSimulatorBannerItemPullHistoryModel> getBannerItemsPullFlatHistory(String bannerKey);
}
