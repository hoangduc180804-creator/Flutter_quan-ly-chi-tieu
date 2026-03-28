import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chi_tieu.dart';

class ChiTieuProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ChiTieu> _danhSach = [];
  List<ChiTieu> get danhSach => _danhSach;

  StreamSubscription<QuerySnapshot>? _subscription;
  String get _userId => _auth.currentUser?.uid ?? "";

  // QUẢN LÝ THEO THÁNG & SO SÁNH
  int _thangHienTai = DateTime.now().month;
  int _namHienTai = DateTime.now().year;

  int get thangHienTai => _thangHienTai;
  int get namHienTai => _namHienTai;

  void setThang(int month) {
    _thangHienTai = month;
    notifyListeners();
  }

  // Lọc danh sách chi tiêu chỉ cho tháng/năm đang chọn
  List<ChiTieu> get danhSachTheoThang {
    return _danhSach.where((item) {
      return item.thoiGian.month == _thangHienTai &&
          item.thoiGian.year == _namHienTai;
    }).toList();
  }

  double get tongChiThangNay {
    return danhSachTheoThang.fold(0.0, (sum, item) => sum + item.soTien);
  }

  double tinhTongChoThang(int month, int year) {
    return _danhSach
        .where(
          (item) => item.thoiGian.month == month && item.thoiGian.year == year,
        )
        .fold(0.0, (sum, item) => sum + item.soTien);
  }

  // --- TỰ ĐỘNG ĐÁNH GIÁ ---
  Map<String, dynamic> get layNhanXetThongMinh {
    double hienTai = tongChiThangNay;
    int mTruoc = _thangHienTai == 1 ? 12 : _thangHienTai - 1;
    int yTruoc = _thangHienTai == 1 ? _namHienTai - 1 : _namHienTai;
    double truoc = tinhTongChoThang(mTruoc, yTruoc);

    if (hienTai == 0) return {"txt": "Tháng này chưa chi tiêu gì.", "color": Colors.blueAccent};
    if (truoc == 0) return {"txt": "Tháng đầu tiên, hãy chi tiêu hợp lý!", "color": Colors.orangeAccent};

    double phanTram = ((hienTai - truoc) / truoc) * 100;

    if (phanTram < 0) {
      return {"txt": "Giảm ${phanTram.abs().toStringAsFixed(0)}% so với tháng trước.", "color": Colors.greenAccent};
    } else if (phanTram > 20) {
      return {"txt": "Cảnh báo: Tăng ${phanTram.toStringAsFixed(0)}% so với tháng trước!", "color": Colors.redAccent};
    } else {
      return {"txt": "Chi tiêu ổn định.", "color": Colors.white70};
    }
  }

  void chuyenThang(int delta) {
    DateTime current = DateTime(_namHienTai, _thangHienTai);
    DateTime next = DateTime(current.year, current.month + delta);
    _thangHienTai = next.month;
    _namHienTai = next.year;
    notifyListeners();
  }

  // CRUD FIREBASE
  double get tongChiTieu {
    return _danhSach.fold(0, (sum, item) => sum + item.soTien);
  }

  void layDuLieu() {
    if (_userId.isEmpty) return;
    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .orderBy('thoiGian', descending: false)
        .snapshots()
        .listen((snapshot) {
          _danhSach = snapshot.docs.map((doc) {
            return ChiTieu.fromFirestore(doc.id, doc.data());
          }).toList();
          notifyListeners();
        });
  }

  // --- [QUAN TRỌNG] HÀM THÊM MỚI (ĐÃ SỬA ĐỂ CHỌN NGÀY) ---
  Future<void> themChiTieu({
    required String ten,
    required double soTien,
    DateTime? ngayChon, 
  }) async {
    if (_userId.isEmpty) return;
    
    // Nếu có ngày chọn thì dùng, không thì dùng hiện tại
    DateTime thoiGianLuu = ngayChon ?? DateTime.now();

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .add({
          'ten': ten,
          'soTien': soTien,
          'thoiGian': thoiGianLuu, 
        });
  }

  Future<void> xoaChiTieu(String id) async {
    if (_userId.isEmpty) return;
    try {
      await _firestore.collection('users').doc(_userId).collection('expenses').doc(id).delete();
    } catch (e) {
      debugPrint("Lỗi xóa: $e");
    }
  }

  Future<void> suaChiTieu({
    required String id,
    required String tenMoi,
    required double soTienMoi,
  }) async {
    if (_userId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .doc(id)
          .update({'ten': tenMoi, 'soTien': soTienMoi});
    } catch (e) {
       debugPrint("Lỗi sửa: $e");
    }
  }

Future<void> xoaChiTieuTheoThang(int thang, int nam) async {
    if (_userId.isEmpty) return;

    try {
      DateTime startOfMonth = DateTime(nam, thang, 1);
      DateTime startOfNextMonth = DateTime(nam, thang + 1, 1);

      final collection = _firestore.collection('users').doc(_userId).collection('expenses');

      // --- SỬA LỖI 1: Tên trường trong Firestore là 'thoiGian' ---
      final snapshot = await collection
          .where('thoiGian', isGreaterThanOrEqualTo: startOfMonth)
          .where('thoiGian', isLessThan: startOfNextMonth)
          .get();

      print("Tìm thấy ${snapshot.docs.length} mục cần xóa.");

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // --- SỬA LỖI 2 & 3: Tên biến list là '_danhSach' và thuộc tính là 'thoiGian' ---
      
      // Lưu ý: Vì bạn đang dùng Stream (hàm layDuLieu), danh sách sẽ tự cập nhật.
      // Tuy nhiên, dòng code dưới đây giúp UI cập nhật NGAY LẬP TỨC mà không cần chờ mạng.
      _danhSach.removeWhere((item) {
         return item.thoiGian.month == thang && item.thoiGian.year == nam;
      });
      
      notifyListeners();
      
    } catch (e) {
      print("Lỗi khi xóa chi tiêu tháng $thang/$nam: $e");
      rethrow;
    }
  }

  void clearLocalData() {
    _subscription?.cancel();
    _subscription = null;
    _danhSach = [];
    notifyListeners();
  }
}