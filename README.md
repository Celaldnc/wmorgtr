# WM Teknoloji Haber Uygulaması

Bu uygulama, WM.ORG.TR için geliştirilmiş bir Flutter tabanlı teknoloji haber uygulamasıdır.

## Kurulum Adımları

### 1. Gerekli Paketlerin Yüklenmesi

Projeyi klonladıktan sonra, aşağıdaki komutu çalıştırarak gerekli tüm paketleri yükleyin:

```bash
flutter pub get
```

### 2. Firebase Kurulumu

Bu uygulama Firebase servislerini kullanmaktadır. Firebase'i projenize entegre etmek için şu adımları izleyin:

#### 2.1. Firebase CLI'ı Yükleyin

```bash
npm install -g firebase-tools
```

#### 2.2. Firebase'e Giriş Yapın

```bash
firebase login
```

#### 2.3. FlutterFire CLI'ı Yükleyin

```bash
dart pub global activate flutterfire_cli
```

#### 2.4. Firebase Projenizi Yapılandırın

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Yeni bir proje oluşturun (veya mevcut projenizi seçin)
3. Flutter uygulamanızı projeye ekleyin

#### 2.5. FlutterFire CLI ile Yapılandırma

Proje dizininde şu komutu çalıştırın:

```bash
flutterfire configure --project=your-firebase-project-id
```

Bu komut, `firebase_options.dart` dosyasını otomatik olarak oluşturacaktır.

### 3. Uygulama Konfigürasyonu

Projenin kök dizininde `.env` dosyası oluşturun (opsiyonel):

```
API_KEY=your_api_key_here
API_URL=your_api_url_here
```

### 4. Uygulamayı Çalıştırın

```bash
flutter run
```

## Özellikler

- Kullanıcı kaydı ve girişi
- Teknoloji haberleri listesi
- Haber detay sayfası
- Kullanıcı profil yönetimi

## Proje Yapısı

- `/lib/screens` - Uygulama ekranları
- `/lib/services` - Firebase ve API servisleri
- `/lib/models` - Veri modelleri
- `/lib/widgets` - Yeniden kullanılabilir widget'lar

## Katkıda Bulunma

Lütfen geliştirme için pull request göndermeden önce test ettiğinizden emin olun.

## Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.