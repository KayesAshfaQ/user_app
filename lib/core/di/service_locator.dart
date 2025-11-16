import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../db/hive_database.dart';
import '../event/app_event_bus.dart';
import '../network/network_info.dart';
import '../services/app_config_service.dart';
import '../services/cache_service.dart';

final sl = GetIt.instance;

/// Registers all dependencies for the app
Future<void> initServiceLocator() async {
  // Core - Hive Database (must be initialized first)
  final hiveDatabase = HiveDatabase();
  await hiveDatabase.initialize();
  sl.registerLazySingleton<HiveDatabase>(() => hiveDatabase);

  // Core - Services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => AppEventBus());
  sl.registerLazySingleton<CacheService>(
    () => CacheService(hiveDatabase: sl()),
  );
  sl.registerLazySingleton<AppConfigService>(
    () => AppConfigService(hiveDatabase: sl()),
  );

  // API client with Dio
  final dio = Dio();
  // You can add interceptors here
  // dio.interceptors.add(LogInterceptor(responseBody: true));

  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<ApiClient>(
      () => ApiClient(dio: sl(), baseUrl: 'https://yourapi.com/api'));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());

  // Data sources
  /* sl.registerLazySingleton<PurchaseDataSource>(
    () => PurchaseLocalDataSourceImpl(purchaseDao: database.purchaseDao),
  ); */

  // Repositories
  /* sl.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(dataSource: sl()),
  ); */

  // Use cases
  /* sl.registerLazySingleton(() => GetPurchaseListUsecase(sl())); */

  // Services (for easy access across the app)
  /* sl.registerLazySingleton(() => UserSettingsService(
        getUserSettingsUsecase: sl(),
        updateDefaultCurrencyUsecase: sl(),
      )); */

  // Blocs/Cubits
  /* sl.registerFactory(() => PurchaseListBloc(
        getAllPurchaseListUseCase: sl(),
        addPurchaseListUsecase: sl(),
        removePurchaseListUsecase: sl(),
        updatePurchaseListUsecase: sl(),
        eventBus: sl(),
      )); */
}
