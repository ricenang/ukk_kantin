import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukk_kantin/components/admin_components/admin_hint.dart';
import 'package:ukk_kantin/components/admin_components/hello_admin_logout.dart';
import 'package:ukk_kantin/components/admin_components/order_box.dart';
import 'package:ukk_kantin/components/admin_components/pemasukan.dart';
import 'package:ukk_kantin/pages/admin/home/histori.dart';
import 'package:ukk_kantin/pages/admin/menu_admin/edit_stan.dart';
import 'package:ukk_kantin/services/api_services.dart';

class HomeAdminContent extends StatefulWidget {
  const HomeAdminContent({super.key});

  @override
  State<HomeAdminContent> createState() => _HomeAdminContentState();
}

class _HomeAdminContentState extends State<HomeAdminContent> {
  String kantinName = "Loading...";
  int _pemasukan = 0;
  List<Map<String, dynamic>> _stanList = [];
  int _countOrderBelum = 0;
  int _countOrderSelesai = 0;

  @override
  void initState() {
    super.initState();
    loadAdminData();
    fetchPemasukan();
    _fetchOrderBelum();
    _fetchOrderSelesai();
  }

  Future<void> loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username") ?? "Kantin";
    final apiService = ApiService();

    final List<Map<String, dynamic>> stanList =
        List<Map<String, dynamic>>.from(await apiService.getStan());

    setState(() {
      _stanList = stanList;
      kantinName = stanList.isNotEmpty
          ? stanList[0]["nama_pemilik"] ?? username
          : username;
    });
  }

  String getCurrentMonth() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM').format(now);
  }

  Future<void> fetchPemasukan() async {
    final apiService = ApiService();
    String bulanIni = getCurrentMonth();
    final pemasukanList = await apiService.getPemasukan(bulanIni);

    if (pemasukanList.isNotEmpty) {
      int totalPemasukan = 0;

      for (var item in pemasukanList) {
        if (item is Map<String, dynamic> &&
            item.containsKey("total_pemasukan")) {
          totalPemasukan +=
              int.tryParse(item["total_pemasukan"].toString()) ?? 0;
        }
      }

      setState(() {
        _pemasukan = totalPemasukan;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login_admin");
    }
  }

  void _editStan() async {
    if (_stanList.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditStan(stanData: _stanList[0]),
        ),
      );

      if (result == true) {
        loadAdminData();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromRGBO(240, 94, 94, 1),
            content: Text(
          'Data stan tidak ditemukan',
          style: GoogleFonts.nunitoSans(),
        )),
      );
    }
  }

  Future<void> _fetchOrderBelum() async {
    final orderList = await ApiService().getOrderAdminBelum();
    setState(() {
      _countOrderBelum = orderList.length;
    });
  }

  Future<void> _fetchOrderSelesai() async {
    final orderList = await ApiService().getOrderAdminSelesai();
    setState(() {
      _countOrderSelesai = orderList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        "Hello ${kantinName[0].toUpperCase()}${kantinName.substring(1)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelloAdminLogout(
                kantin: displayName,
                icon: Icons.person,
                iconColor: Colors.red,
                onEdit: _editStan, // Panggil fungsi _editStan
                onLogout: logout,
              ),
              const SizedBox(height: 16),
              OrderBox(running: _countOrderBelum, request: _countOrderSelesai),
              const SizedBox(height: 16),
              Pemasukan(penghasilan: _pemasukan),
              const SizedBox(height: 34),
              const AdminHint(hint: "Histori Transaksi"),
              const SizedBox(height: 12),
              HistoriTransaksiPage()
            ],
          ),
        ),
      ),
    );
  }
}
