import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
// import 'package:stms/data/api/local/master/master_location_repository.dart';
// import 'package:stms/data/api/repositories/master/location_repository.dart';
import 'package:stms/data/api/repositories/remote_license_repository.dart';
import 'package:stms/data/api/repositories/remote_transfer_repository.dart';
import 'package:stms/data/api/repositories/remote_user_repository.dart';
import 'package:stms/data/network/network_status.dart';
import 'package:stms/data/repositories/abstract/license_repository.dart';
import 'package:stms/data/repositories/abstract/user_repository.dart';
import 'package:stms/data/repositories/license_repository_impl.dart';
import 'package:stms/data/repositories/user_repository_impl.dart';

// final sl = GetIt.instance;
// This is our global ServiceLocator
final sl = GetIt.instance;

Future<void> init() async {
  //Singleton for NetworkStatus identification
  sl.registerLazySingleton<NetworkStatus>(
      () => NetworkStatusImpl(Connectivity()));

  // // Global
  // sl.registerLazySingleton<GlobalCountriesGetUseCase>(
  //     () => GlobalCountriesGetUseCaseImpl());
  // sl.registerLazySingleton<GlobalGetUseCase>(() => GlobalGetUseCaseImpl());

  //Singleton for HTTP request
  sl.registerLazySingleton(() => http.Client);

  // sl.registerLazySingleton<RemoteGlobalRepository>(
  //     () => RemoteGlobalRepository());
  // sl.registerLazySingleton<GlobalRepository>(
  //     () => GlobalRepositoryImpl(remoteGlobalRepository: sl()));

  sl.registerLazySingleton<RemoteUserRepository>(() => RemoteUserRepository());
  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteUserRepository: sl()));

  sl.registerLazySingleton<RemoteLicenseRepository>(
      () => RemoteLicenseRepository());
  sl.registerLazySingleton<LicenseRepository>(
      () => LicenseRepositoryImpl(remoteLicenseRepository: sl()));

  sl.registerLazySingleton<RemoteTransferRepository>(
      () => RemoteTransferRepository());

  // sl.registerLazySingleton<LocationRepository>(
  //     () => MasterLocationRepository());
  // sl.registerLazySingleton<TransferRepository>(
  //     () => TransferRepositoryImpl(remoteTransferRepository: sl()));

  // sl.registerLazySingleton<TransactionCreateUseCase>(
  //     () => TransactionCreateUseCaseImpl());

  // sl.registerLazySingleton<RemoteTransactionRepository>(
  //     () => RemoteTransactionRepository());
  // sl.registerLazySingleton<TransactionRepository>(
  //     () => TransactionRepositoryImpl(remoteTransactionRepository: sl()));
}
