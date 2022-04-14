import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/repositories/abstract/license_repository.dart';
import 'package:stms/data/repositories/abstract/user_repository.dart';
import 'package:stms/presentation/features/authentication/authentication.dart';
import 'package:stms/presentation/features/count/count_screen.dart';
import 'package:stms/presentation/features/count/view/count_listItem.dart';
import 'package:stms/presentation/features/count/view/count_manual.dart';
import 'package:stms/presentation/features/count/view/count_viewItem.dart';
import 'package:stms/presentation/features/home/home_screen.dart';
import 'package:stms/presentation/features/incoming/incoming.dart';
import 'package:stms/presentation/features/incoming/incoming_screen.dart';
import 'package:stms/presentation/features/login/login.dart';
import 'package:stms/presentation/features/master/master_screen.dart';
import 'package:stms/presentation/features/outgoing/outgoing.dart';
import 'package:stms/presentation/features/outgoing/outgoing_screen.dart';
import 'package:stms/presentation/features/register/register.dart';
import 'package:stms/presentation/features/splash/splash.dart';
import 'package:stms/presentation/features/transfer/transfer.dart';
import 'package:stms/presentation/features/transfer/transfer_screen.dart';

import 'locator.dart' as service_locator;
import 'locator.dart';
import 'presentation/features/profile/profile.dart';

class SimpleBlocDelegate extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print(error);
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // HttpOverrides.global = MyHttpOverrides();
  await service_locator.init();
  // await Hive.initFlutter();
  // await Init.initialize();

  // var delegate = await LocalizationDelegate.create(
  //   fallbackLocale: 'en_US',
  //   supportedLocales: ['en_US'],
  // );

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(InventoryHiveAdapter());
  await Hive.openBox<InventoryHive>('inventory');

  // await Firebase.initializeApp();

  // if (kDebugMode) {
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // }

  // Set the background messaging handler early on, as a named top-level function
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // RegisterBloc registerBloc = RegisterBloc(licenseRepository: sl());
  ProfileBloc profileBloc = ProfileBloc(userRepository: sl());

  Bloc.observer = SimpleBlocDelegate();
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profileBloc),
        BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
                  // registerBloc: BlocProvider.of<RegisterBloc>(context),
                  profileBloc: BlocProvider.of<ProfileBloc>(context),
                  userRepository: sl(),
                  licenseRepository: sl(),
                )
            // ..add(AuthenticationAppStarted()),
            ),
      ],
      child: MultiRepositoryProvider(providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => sl(),
        ),
        RepositoryProvider<LicenseRepository>(
          create: (context) => sl(),
        ),
      ], child: StmsApp())));
}

class StmsApp extends StatelessWidget {
  // final ProfileBloc profileBloc = ProfileBloc(userRepository: sl());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // onGenerateRoute: _registerRoutesWithParameters,
      // supportedLocales: localizationDelegate.supportedLocales,
      // locale: localizationDelegate.currentLocale,
      title: 'IQeS-STMS',
      // theme: JomNGoTheme.of(context),
      routes: _registerRoutes(),
      //     ),
      //   ),
    );
  }

  Map<String, WidgetBuilder> _registerRoutes() {
    return <String, WidgetBuilder>{
      StmsRoutes.splash: (context) => _buildSplashBloc(context),
      StmsRoutes.register: (context) => _buildRegisterBloc(),
      StmsRoutes.login: (context) => _buildLogInBloc(),
      StmsRoutes.home: (context) => _buildScreen(StmsRoutes.home),
      StmsRoutes.master: (context) => _buildScreen(StmsRoutes.master),
      StmsRoutes.incoming: (context) => _buildScreen(StmsRoutes.incoming),
      StmsRoutes.outgoing: (context) => _buildScreen(StmsRoutes.outgoing),
      StmsRoutes.transfer: (context) => _buildScreen(StmsRoutes.transfer),
      StmsRoutes.stockCount: (context) => _buildScreen(StmsRoutes.stockCount),

      // IN - Purchase Order
      StmsRoutes.purchaseOrder: (context) =>
          _buildScreen(StmsRoutes.purchaseOrder),
      StmsRoutes.poItemManual: (context) =>
          _buildScreen(StmsRoutes.poItemManual),
      StmsRoutes.poItemList: (context) => _buildScreen(StmsRoutes.poItemList),
      StmsRoutes.poItemDetail: (context) =>
          _buildScreen(StmsRoutes.poItemDetail),

      // IN - PAIV
      StmsRoutes.paivView: (context) => _buildScreen(StmsRoutes.paivView),
      StmsRoutes.paivItemManual: (context) =>
          _buildScreen(StmsRoutes.paivItemManual),
      StmsRoutes.paivItemList: (context) =>
          _buildScreen(StmsRoutes.paivItemList),
      StmsRoutes.paivItemDetail: (context) =>
          _buildScreen(StmsRoutes.paivItemDetail),

      // IN - Sales Return
      StmsRoutes.srView: (context) => _buildScreen(StmsRoutes.srView),
      StmsRoutes.srItemManual: (context) =>
          _buildScreen(StmsRoutes.srItemManual),
      StmsRoutes.srItemList: (context) => _buildScreen(StmsRoutes.srItemList),
      StmsRoutes.srItemDetail: (context) =>
          _buildScreen(StmsRoutes.srItemDetail),

      // IN - Adjustment Inventory In
      StmsRoutes.adjustIn: (context) => _buildScreen(StmsRoutes.adjustIn),
      StmsRoutes.aiItemCreate: (context) =>
          _buildScreen(StmsRoutes.aiItemCreate),
      StmsRoutes.aiItemList: (context) => _buildScreen(StmsRoutes.aiItemList),

      // IN - Item Modification
      StmsRoutes.itemModify: (context) => _buildScreen(StmsRoutes.itemModify),
      StmsRoutes.imItemCreate: (context) =>
          _buildScreen(StmsRoutes.imItemCreate),
      StmsRoutes.imItemList: (context) => _buildScreen(StmsRoutes.imItemList),

      // IN - Return from Customer
      StmsRoutes.returnCustomer: (context) =>
          _buildScreen(StmsRoutes.returnCustomer),
      StmsRoutes.crItemCreate: (context) =>
          _buildScreen(StmsRoutes.crItemCreate),
      StmsRoutes.crItemList: (context) => _buildScreen(StmsRoutes.crItemList),

      // IN - Vendor Stock Replacement
      StmsRoutes.replaceSupplier: (context) =>
          _buildScreen(StmsRoutes.replaceSupplier),
      StmsRoutes.vsrItemCreate: (context) =>
          _buildScreen(StmsRoutes.vsrItemCreate),
      StmsRoutes.vsrItemList: (context) => _buildScreen(StmsRoutes.vsrItemList),

      // OUT - Sales Invoice
      StmsRoutes.siView: (context) => _buildScreen(StmsRoutes.siView),
      StmsRoutes.siItemManual: (context) =>
          _buildScreen(StmsRoutes.siItemManual),
      StmsRoutes.siItemList: (context) => _buildScreen(StmsRoutes.siItemList),
      StmsRoutes.siItemDetail: (context) =>
          _buildScreen(StmsRoutes.siItemDetail),

      // OUT - PAIV Transfer
      StmsRoutes.paivtView: (context) => _buildScreen(StmsRoutes.paivtView),
      StmsRoutes.paivtItemManual: (context) =>
          _buildScreen(StmsRoutes.paivtItemManual),
      StmsRoutes.paivtItemList: (context) =>
          _buildScreen(StmsRoutes.paivtItemList),
      StmsRoutes.paivtItemDetail: (context) =>
          _buildScreen(StmsRoutes.paivtItemDetail),

      // OUT - Purchase Return
      StmsRoutes.prView: (context) => _buildScreen(StmsRoutes.prView),
      StmsRoutes.prItemManual: (context) =>
          _buildScreen(StmsRoutes.prItemManual),
      StmsRoutes.prItemList: (context) => _buildScreen(StmsRoutes.prItemList),
      StmsRoutes.prItemDetail: (context) =>
          _buildScreen(StmsRoutes.prItemDetail),

      // OUT - Adjustment Inventory Out
      StmsRoutes.adjustOut: (context) => _buildScreen(StmsRoutes.adjustOut),
      StmsRoutes.aoItemCreate: (context) =>
          _buildScreen(StmsRoutes.aoItemCreate),
      StmsRoutes.aoItemList: (context) => _buildScreen(StmsRoutes.aoItemList),

      // OUT - Return to Vendor
      StmsRoutes.returnSupplier: (context) =>
          _buildScreen(StmsRoutes.returnSupplier),
      StmsRoutes.rvItemCreate: (context) =>
          _buildScreen(StmsRoutes.rvItemCreate),
      StmsRoutes.rvItemList: (context) => _buildScreen(StmsRoutes.rvItemList),

      // OUT - Replace Item to Customer
      StmsRoutes.repairCustomer: (context) =>
          _buildScreen(StmsRoutes.repairCustomer),
      StmsRoutes.rcItemCreate: (context) =>
          _buildScreen(StmsRoutes.rcItemCreate),
      StmsRoutes.rcItemList: (context) => _buildScreen(StmsRoutes.rcItemList),

      // TRANSFER
      StmsRoutes.transferItem: (context) =>
          _buildScreen(StmsRoutes.transferItem),
      StmsRoutes.stItemList: (context) => _buildScreen(StmsRoutes.stItemList),
      StmsRoutes.stItemCreate: (context) =>
          _buildScreen(StmsRoutes.stItemCreate),

      // STOCK COUNT
      StmsRoutes.countItemList: (context) =>
          _buildScreen(StmsRoutes.countItemList),
      StmsRoutes.countItemDetail: (context) =>
          _buildScreen(StmsRoutes.countItemDetail),
    };
  }

  BlocBuilder<AuthenticationBloc, AuthenticationState> _buildScreen(
      String route) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is AuthenticationAuthenticated) {
        switch (route) {
          case StmsRoutes.home:
            return HomeScreen();
          case StmsRoutes.master:
            return MasterScreen();
          case StmsRoutes.incoming:
            return IncomingScreen();
          case StmsRoutes.outgoing:
            return OutgoingScreen();
          case StmsRoutes.transferItem:
            return TransferScreen();
          case StmsRoutes.stockCount:
            return CountScreen();
          // IN - PO
          case StmsRoutes.purchaseOrder:
            return PoScreen();
          case StmsRoutes.poItemManual:
            return PoManual();
          case StmsRoutes.poItemList:
            return PoItemListView();
          case StmsRoutes.poItemDetail:
            return PoItemDetails();
          // IN - PAIV
          case StmsRoutes.paivView:
            return PaivScreen();
          case StmsRoutes.paivItemManual:
            return PaivManual();
          case StmsRoutes.paivItemList:
            return PaivItemListView();
          case StmsRoutes.paivItemDetail:
            return PaivItemDetails();
          // IN - Sales Return
          case StmsRoutes.srView:
            return SaleReturnScreen();
          case StmsRoutes.srItemManual:
            return SrManual();
          case StmsRoutes.srItemList:
            return SrItemListView();
          case StmsRoutes.srItemDetail:
            return SrItemDetails();
          // IN - Adjust in
          case StmsRoutes.adjustIn:
            return AdjustInScreen();
          case StmsRoutes.aiItemCreate:
            return AiCreateItem();
          case StmsRoutes.aiItemList:
            return AiListItem();
          // IN - Item Modification
          case StmsRoutes.itemModify:
            return ItemModifyScreen();
          case StmsRoutes.imItemCreate:
            return ImCreateItem();
          case StmsRoutes.imItemList:
            return ImListItem();
          // IN - Return from Customer
          case StmsRoutes.returnCustomer:
            return CustReturnScreen();
          case StmsRoutes.crItemCreate:
            return CrCreateItem();
          case StmsRoutes.crItemList:
            return CrListItem();
          // IN - Vendor Stock Replacement
          case StmsRoutes.replaceSupplier:
            return VendorReplaceScreen();
          case StmsRoutes.vsrItemCreate:
            return VsrCreateItem();
          case StmsRoutes.vsrItemList:
            return VsrListItem();
          // OUT - Sales Invoice
          case StmsRoutes.siView:
            return SaleInvoiceScreen();
          case StmsRoutes.siItemManual:
            return SiManual();
          case StmsRoutes.siItemList:
            return SiItemListView();
          case StmsRoutes.siItemDetail:
            return SiItemDetails();
          // OUT - PAIV Transfer
          case StmsRoutes.paivtView:
            return PaivtScreen();
          case StmsRoutes.paivtItemManual:
            return PaivtManual();
          case StmsRoutes.paivtItemList:
            return PaivtItemListView();
          case StmsRoutes.paivtItemDetail:
            return PaivtItemDetails();
          // OUT - Purchase Return
          case StmsRoutes.prView:
            return PurchaseReturnScreen();
          case StmsRoutes.prItemManual:
            return PrManual();
          case StmsRoutes.prItemList:
            return PrItemListView();
          case StmsRoutes.prItemDetail:
            return PrItemDetails();
          // OUT - Adjust out
          case StmsRoutes.adjustOut:
            return AdjustOutScreen();
          case StmsRoutes.aoItemCreate:
            return AoCreateItem();
          case StmsRoutes.aoItemList:
            return AoListItem();
          // OUT - Return to Vendor
          case StmsRoutes.returnSupplier:
            return ReturnVendorScreen();
          case StmsRoutes.rvItemCreate:
            return RvCreateItem();
          case StmsRoutes.rvItemList:
            return RvListItem();
          // OUT - Repair Customer
          case StmsRoutes.repairCustomer:
            return ReplaceCustScreen();
          case StmsRoutes.rcItemCreate:
            return RcCreateItem();
          case StmsRoutes.rcItemList:
            return RcListItem();

          case StmsRoutes.transfer:
            return TransferInScreen();
          case StmsRoutes.stItemList:
            return StListItem();
          case StmsRoutes.stItemCreate:
            return StCreateItem();

          case StmsRoutes.countItemList:
            return CountItemListView();
          case StmsRoutes.countItemManual:
            return CountManual();
          case StmsRoutes.countItemDetail:
            return CountItemDetails();
        }
        return _buildLogInBloc();
      } else if (state is AuthenticationUnauthenticated) {
        switch (route) {
          case StmsRoutes.login:
            return LoginScreen();
        }
        return _buildRegisterBloc();
      } else {
        return _buildSplashBloc(context);
      }
    });
  }

  BlocProvider<RegisterBloc> _buildRegisterBloc() {
    return BlocProvider<RegisterBloc>(
      create: (context) => RegisterBloc(
        licenseRepository: RepositoryProvider.of<LicenseRepository>(context),
      ),
      child: RegisterScreen(),
    );
  }

  BlocProvider<LoginBloc> _buildLogInBloc() {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      ),
      child: LoginScreen(),
    );
  }

  BlocProvider<SplashBloc> _buildSplashBloc(BuildContext context) {
    var splashBloc = SplashBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context));
    splashBloc.add(SplashStart());

    return BlocProvider<SplashBloc>(
      create: (context) => splashBloc,
      child: SplashScreen(),
    );
  }
}
