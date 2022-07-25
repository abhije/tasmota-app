import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tasmota/screens/home_screen.dart';
import 'data/objectbox_store.dart';

late ObjectBox objectbox;

//------------------------------------------------------------------------------
//-- PROVIDERS --
//------------------------------------------------------------------------------

final wifiProvider = StreamProvider.autoDispose<ConnectivityResult>((ref) {
  var _connectivity = Connectivity();
  return _connectivity.onConnectivityChanged;
});

final objectboxProvider =
    Provider<ObjectBox>((ref) => throw UnimplementedError());

//------------------------------------------------------------------------------
//-- MAIN --
//------------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  runApp(ProviderScope(
      overrides: [objectboxProvider.overrideWithValue(objectbox)],
      child: const TasmotaApp()));
}

//------------------------------------------------------------------------------
//-- TASMOTA APP --
//------------------------------------------------------------------------------

class TasmotaApp extends ConsumerWidget {
  const TasmotaApp({Key? key}) : super(key: key);

//-- BUILD ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var hasWifi = ref.watch(wifiProvider);
    return MaterialApp(
      title: "Tasmota",
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [FormBuilderLocalizations.delegate],
      theme: FlexThemeData.light(scheme: FlexScheme.outerSpace)
          .copyWith(useMaterial3: true),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.outerSpace)
          .copyWith(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: hasWifi.when(
        loading: () {
          var widget = const CircularProgressIndicator();
          return _appBody(context, widget);
        },
        error: (error, stack) {
          var widget = const Text('Oops');
          return _appBody(context, widget);
        },
        data: (value) {
          if (value == ConnectivityResult.wifi) {
            return const HomeScreen();
          }

          var widget = const Center(
            child: Text("No Wifi!"),
          );

          return _appBody(context, widget);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

//-- APP BODY ------------------------------------------------------------------

  Widget _appBody(BuildContext context, Widget widget) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasmota"),
      ),
      body: widget,
    );
  }
}
