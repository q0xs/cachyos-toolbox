# 🔥 Ghost Rider Skull 4K HDR Live Wallpaper for KDE Plasma 6

KDE Plasma 6 (Wayland & X11) için özel olarak optimize edilmiş, temizlenmiş ve kesintisiz döngüye sahip **Ghost Rider Skull 4K 60FPS** canlı masaüstü ve kilit ekranı duvar kağıdı paketi.

Format attıktan sonra **tek bir komutla** hem masaüstü canlı MP4 video duvar kağıdını hem de 4K kilit ekranını otomatik olarak kurar.

---

## ⚡ Hızlı Kurulum (Tek Komut)

Bilgisayarınıza format attığınızda terminali açıp yalnızca şu **tek satırlık** komutu yapıştırmanız yeterlidir:

```bash
curl -sSL https://raw.githubusercontent.com/q0xs/ghost-rider-wallpaper/main/install.sh | bash
```

*Alternatif olarak repoyu manuel klonlayıp kurmak isterseniz:*
```bash
git clone https://github.com/q0xs/ghost-rider-wallpaper.git && cd ghost-rider-wallpaper && ./install.sh
```

---

## ✨ Kurulum Neler Yapar?

1. 🎬 **Masaüstü Canlı MP4 Duvar Kağıdı:**
   - 4K Ultra HD (3840x2160) @ 60 FPS.
   - 0.6x atmosferik hızında pürüzsüz ve sakin alev animasyonu.
   - 20 saniyelik kusursuz ve atlamasız sonsuz döngü (crossfade loop).
   - Sol alttaki müzik çalar ("Rage Sound") ve sağ alttaki saat/tarih bileşenleri tamamen temizlendi.
   - Çift monitör dahil tüm ekranlara otomatik uygulanır.
2. 🔒 **4K Kilit Ekranı (Lock Screen):**
   - Videonun en net ve parıldayan anından 4K çözünürlükte kilit ekranı arka planı ayarlanır.
3. ⏱️ **Ekran Uyku Süresi:**
   - Ekran kapanma süresi otomatik olarak 20 dakika (1200 sn) olarak ayarlanır.
4. 📦 **Gereksinim Yönetimi:**
   - Eksikse `plasma6-wallpapers-wallpaper-engine-git` ve `mpv` paketlerini otomatik tespit eder.

---

## 🗑️ Kaldırma / Revert

Varsayılan KDE Plasma duvar kağıdına geri dönmek isterseniz:

```bash
cd ghost-rider-wallpaper && ./uninstall.sh
```

---

## 📂 Dosya Yapısı

```text
ghost-rider-wallpaper/
├── ghost_rider_clean_loop_06x.mp4  # 4K 60fps 0.6x temizlenmiş döngü video (88 MB)
├── lockscreen_ghost_rider.png      # 4K kilit ekranı görseli (3.6 MB)
├── install.sh                      # Tek tıkla otomatik kurulum betiği
├── uninstall.sh                    # Kaldırma betiği
├── LICENSE                         # MIT Lisansı
└── README.md                       # Dokümantasyon
```

---

## 📄 Lisans / License

Bu proje [MIT Lisansı](LICENSE) ile lisanslanmıştır. Orijinal duvar kağıdı tasarımı ilgili telif hakkı sahiplerine aittir.
