import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_web_app/image_web_widget.dart';
import 'package:image_web_app/provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
        // MaterialApp(
        //   home:
        MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageWebProvider()),
      ],
      child: const ImageWebWidget(),
    );
    //);
  }
}
