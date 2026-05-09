// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'IPOT Order';

  @override
  String get scanTitle => 'Scan untuk pesan';

  @override
  String get scanHint => 'Arahkan kamera ke QR di meja';

  @override
  String get scanInvalid => 'QR tidak dikenali — pastikan dari meja IPOT';

  @override
  String get scanManualEntry => 'Masukkan ID meja manual';

  @override
  String get scanEnterTableId => 'Masukkan ID meja';

  @override
  String get scanTableHint => 'contoh: T001';

  @override
  String get scanCameraUnavailable => 'Kamera tidak tersedia';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionOpenMenu => 'Buka menu';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get actionAddToCart => 'Tambah ke keranjang';

  @override
  String get actionPlaceOrder => 'Pesan sekarang';

  @override
  String get actionClear => 'Kosongkan';

  @override
  String get actionBackToMenu => 'Kembali ke menu';

  @override
  String menuTable(String id) {
    return 'Meja $id';
  }

  @override
  String get menuFailedLoad => 'Gagal memuat menu';

  @override
  String get menuSearchHint => 'Cari menu...';

  @override
  String get menuEmptyCategory => 'Tidak ada item di kategori ini';

  @override
  String get menuNoMatches => 'Tidak ditemukan';

  @override
  String get itemNotes => 'Catatan';

  @override
  String get itemNotesHint => 'contoh: tidak pedas, tanpa bawang';

  @override
  String get itemQuantity => 'Jumlah';

  @override
  String get itemRequired => 'Wajib';

  @override
  String itemMaxSelections(int n) {
    return 'Maks $n';
  }

  @override
  String get itemFree => 'Gratis';

  @override
  String get itemPickRequired => 'Pilih opsi wajib dulu';

  @override
  String get cartTitle => 'Keranjang';

  @override
  String get cartClearTitle => 'Kosongkan keranjang?';

  @override
  String get cartClearBody => 'Hapus semua item dari keranjang.';

  @override
  String get cartNoteHint => 'Catatan untuk dapur (opsional)';

  @override
  String cartSubtotal(int count) {
    return 'Subtotal ($count item)';
  }

  @override
  String get cartEmpty => 'Keranjangmu kosong';

  @override
  String get cartEmptyHint => 'Tambah item dari menu';

  @override
  String cartLineNote(String note) {
    return 'Catatan: $note';
  }

  @override
  String get orderSubmitting => 'Mengirim pesanan...';

  @override
  String get orderSubmitFailed => 'Gagal mengirim pesanan';

  @override
  String get orderConfirmedTitle => 'Pesanan diterima!';

  @override
  String orderConfirmedSubtitle(String id) {
    return 'Order #$id';
  }

  @override
  String get orderTrackTitle => 'Lacak pesanan';

  @override
  String get orderStatusPending => 'Menunggu';

  @override
  String get orderStatusConfirmed => 'Dikonfirmasi';

  @override
  String get orderStatusPreparing => 'Disiapkan';

  @override
  String get orderStatusReady => 'Siap diambil';

  @override
  String get orderStatusServed => 'Sudah disajikan';

  @override
  String orderEta(int minutes) {
    return 'Siap dalam $minutes menit';
  }

  @override
  String get orderBackToScan => 'Kembali ke scan';
}
