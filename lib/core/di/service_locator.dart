import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/user/data/datasources/user_local_data_source.dart';
import '../../features/user/data/datasources/user_remote_data_source.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/usecases/get_user_by_id_usecase.dart';
import '../../features/user/domain/usecases/get_users_usecase.dart';
import '../../features/user/domain/usecases/search_users_usecase.dart';
import '../../features/user/presentation/blocs/user_detail/user_detail_bloc.dart';
import '../../features/user/presentation/blocs/user_list/user_list_bloc.dart';
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
      () => ApiClient(dio: sl(), baseUrl: 'https://reqres.in/api'));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());

  // ============ User Feature ============

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(cacheService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUsersUsecase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUsecase(sl()));
  sl.registerLazySingleton(() => SearchUsersUsecase());

  // BLoCs
  sl.registerFactory(
    () => UserListBloc(
      getUsersUsecase: sl(),
      searchUsersUsecase: sl(),
      eventBus: sl(),
    ),
  );
  sl.registerFactory(
    () => UserDetailBloc(getUserByIdUsecase: sl()),
  );
}
