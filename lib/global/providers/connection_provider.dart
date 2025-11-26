import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/* 
Ini adalah pendekatan yang sangat tepat untuk aplikasi yang internet-heavy. Daripada menangani koneksi di 
setiap halaman satu per satu (yang akan sangat repot dan rawan bug), kita akan membuat mekanisme Global Handler.

Konsepnya adalah:

  1. Kita butuh "Satpam Global" (Provider) yang tugasnya cuma satu: 
  memantau status internet terus-menerus di latar belakang.

  2. Kita butuh "Tirai Penutup" (Widget Wrapper) yang akan membungkus seluruh aplikasi. 
  Jika "Satpam" bilang internet mati, "Tirai" akan turun menutupi layar dan menampilkan loading.
    
 */
class ConnectionProvider extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  late StreamSubscription<InternetStatus> _listener;

  ConnectionProvider() {
    // Saat provider dibuat, langsung mulai mendengarkan status internet
    _startMonitoring();
  }

  void _startMonitoring() {
    _listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          _isConnected = true;
          notifyListeners(); // Beri tahu semua widget yang mendengarkan
          break;
        case InternetStatus.disconnected:
          _isConnected = false;
          notifyListeners(); // Beri tahu semua widget yang mendengarkan
          break;
      }
    });
  }

  @override
  void dispose() {
    // Matikan listener saat aplikasi ditutup agar hemat memori
    _listener.cancel();
    super.dispose();
  }
}