import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'demo.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
    );

    return MaterialApp(
      title: 'Particle Swipe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme:
            const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
        canvasColor: const Color(0xFF161719),
        textTheme: Theme.of(context)
            .textTheme
            .apply(bodyColor: Colors.white, fontFamily: 'OpenSans'),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xffc932d9),
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: const [
              // ParticleAppBar(),
              Flexible(
                child: ParticleSwipeDemo(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
