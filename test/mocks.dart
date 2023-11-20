import 'package:mockito/annotations.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/game_code_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/persistence/calculator_asc_materials_data_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';
import 'package:shiori/domain/services/persistence/game_codes_data_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';
import 'package:shiori/domain/services/persistence/notifications_data_service.dart';
import 'package:shiori/domain/services/persistence/tier_list_data_service.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

@GenerateMocks([
  SettingsService,
  LoggingService,
  TelemetryService,
  DeviceInfoService,
  NetworkService,
  GameCodeService,
  NotificationService,
  PurchaseService,
  ResourceService,
  ApiService,
  BackupRestoreService,
  //data service mocks
  DataService,
  CalculatorAscMaterialsDataService,
  InventoryDataService,
  CustomBuildsDataService,
  NotificationsDataService,
  GameCodesDataService,
  TierListDataService,
  WishSimulatorDataService,
])
void main() {}
