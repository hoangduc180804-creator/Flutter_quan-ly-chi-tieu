import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'providers/dang_nhap_provider.dart';
import 'providers/chi_tieu_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase trước khi runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Run app với MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DangNhapProvider()),
        ChangeNotifierProvider(create: (_) => ChiTieuProvider()),
      ],
      child: const QuanLyChiTieuApp(),
    ),
  );
}
