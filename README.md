WM Teknoloji Haber Uygulaması
Geliştirici: Celal Dinç
Teknoloji: Flutter + Dart + Firebase
Backend: Firebase + WordPress REST API
Platformlar: iOS & Android

1. Proje Amacı
WM Teknoloji Haber Uygulaması, teknoloji meraklılarının wm.org.tr sitesindeki en güncel haberleri kolayca takip etmesini sağlamak için tasarlanmıştır. Kullanıcıların özelleştirilmiş haber akışı, arama, bildirimler ve interaktif içeriklerle keyifli bir deneyim yaşaması hedeflenmektedir.

2. Temel Özellikler
A) Haber Çekme ve Görüntüleme
WordPress API Entegrasyonu: Haberleri çekmek için https://wm.org.tr/wp-json/wp/v2/posts API kullanılır.
Kategoriye Göre Haberler: Kullanıcılar haberleri belirli kategorilere (Yapay Zeka, Oyun, Mobil, Donanım vb.) göre filtreleyebilir.
Haber Detay Sayfası: Tüm haberler detaylı bir sayfada başlık, içerik, görseller, yorumlar ve paylaşım butonlarıyla gösterilir.
Görsel Ağırlıklı Akış: Haber listesi, büyük görseller ve özet metinlerle zenginleştirilerek kullanıcı deneyimi artırılır.
B) Kullanıcı Etkileşimi ve Özelleştirme
Kullanıcı Kaydı & Girişi (Firebase Authentication)
Google, Apple ID veya e-posta ile giriş yapılabilir.
Kullanıcı bilgileri Firebase Firestore’da saklanır.
Kullanıcı Tercihlerine Göre Haber Akışı
Kullanıcı, favori kategorilerini seçerek haber akışını kişiselleştirebilir.
Makine öğrenimi ile ilgilendiği haber türlerine göre öneriler alabilir.
Beğeni & Kaydetme Sistemi
Kullanıcılar haberleri beğenebilir veya daha sonra okumak için kaydedebilir.
Kaydedilen haberler profil sayfasında listelenir.
C) Arama ve Filtreleme
Anahtar Kelime ile Arama (https://wm.org.tr/wp-json/wp/v2/posts?search=yapay%20zeka)
Tarih, Kategori ve Popülerliğe Göre Filtreleme
Hızlı Erişim İçin Son Zamanlarda Okunan Haberler
D) Bildirimler ve Güncellemeler
Gerçek Zamanlı Bildirimler (Firebase Cloud Messaging)
Öne çıkan haberler, özel bültenler veya acil teknoloji haberleri için anlık bildirimler gönderilir.
Kullanıcılar belirli kategoriler için bildirim açıp kapatabilir.
Günlük / Haftalık Özet Bildirimleri
Kullanıcı, haber özetlerini belirli zaman aralıklarında almayı seçebilir.
E) Sosyal Paylaşım ve Topluluk
Yorum Yapma & Beğeni
Firebase Firestore kullanarak kullanıcıların haberler hakkında yorum yapmasına izin verilir.
Haber Paylaşımı
Kullanıcılar haberleri Twitter, Instagram, WhatsApp vb. sosyal medya platformlarında paylaşabilir.
3. Kullanıcı Arayüzü (UI) & Deneyimi (UX)
Ana Sayfa (Home)
En güncel haberler kayan manşet (carousel) tasarımıyla öne çıkarılır.
Kullanıcının önceki tercihleri baz alınarak önerilen haberler gösterilir.
Hızlı filtre butonları ile popüler kategorilere ulaşım sağlanır.
Haber Detay Sayfası
Büyük başlık ve öne çıkan görsel
İçerik bölümü (HTML desteğiyle zengin metin)
Beğen, Kaydet, Paylaş butonları
Kullanıcı yorumları & puanlama sistemi
Arama ve Filtreleme Sayfası
Gelişmiş arama: Anahtar kelime + kategori + popülerlik
Son aramalar: Kullanıcı daha önce yaptığı aramalara kolayca ulaşabilir.
Profil Sayfası
Favori Kategoriler: Kullanıcı ilgi alanlarını değiştirebilir.
Kaydedilen Haberler: Daha sonra okumak için kaydedilen haberler burada listelenir.
Ayarlar: Bildirim tercihlerinin değiştirilmesi, karanlık mod seçeneği vb.
4. Teknik Yapı
Bileşen	Teknoloji
Mobil Uygulama	Flutter (Dart)
Backend	Firebase Firestore & WordPress API
Auth	Firebase Authentication (Google, Apple, E-posta)
Bildirimler	Firebase Cloud Messaging
Haber Çekme	WordPress REST API
Depolama	Firebase Firestore
Durum Yönetimi	Provider / Riverpod (tercihe göre)
Hata Yönetimi	Flutter Error Handling
UI/UX Tasarım	Material Design + Custom Animations