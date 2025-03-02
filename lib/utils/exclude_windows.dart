import 'dart:io';

// Windows platformunda wakelock paketini devre dışı bırakmak için yardımcı fonksiyon
bool get isWindowsPlatform => Platform.isWindows;

// Bu fonksiyon, Windows platformunda wakelock kullanımını engeller
void handleWakelock() {
  // Windows platformunda hiçbir şey yapma
  // Diğer platformlarda wakelock kullanılabilir
}
