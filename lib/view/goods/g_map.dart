import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:xyz_project_01/controller/store_controller.dart';
import 'package:xyz_project_01/model/branch.dart';
import 'package:xyz_project_01/vm/database/branch_database.dart';

class GMap extends StatefulWidget {
  final String userid;
  final bool popOnSelect; // ✅ PayPage에서 선택 후 결과를 돌려줄 때 사용

  const GMap({
    super.key,
    required this.userid,
    this.popOnSelect = false,
  });

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  // --- 컨트롤러 및 상태 변수 ---
  final LatLng gangnamStation = const LatLng(37.4981, 127.0276);
  final Distance distance = const Distance();

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final StoreController storeController = Get.find<StoreController>();

  final BranchDatabase _branchDB = BranchDatabase();

  int _currentTab = 0; // 0: 목록, 1: 지도
  String _currentSearchQuery = '';
  String? _selectedDistrict;

  // 지도 이동 관련 상태
  LatLng? _pendingCenter;
  bool _mapReady = false;

  // 화면에 표시할 매장 목록
  List<Map<String, dynamic>> allStores = [];

  // --- 기타 데이터 정의 ---
  final List<String> seoulDistricts = const [
    '강남구',
    '강동구',
    '강북구',
    '강서구',
    '관악구',
    '광진구',
    '구로구',
    '금천구',
    '노원구',
    '도봉구',
    '동대문구',
    '동작구',
    '마포구',
    '서대문구',
    '서초구',
    '성동구',
    '성북구',
    '송파구',
    '양천구',
    '영등포구',
    '용산구',
    '은평구',
    '종로구',
    '중구',
    '중랑구',
  ];

  final Map<String, LatLng> seoulDistrictCenters = const {
    '강남구': LatLng(37.5175, 127.0475),
    '강동구': LatLng(37.5301, 127.1238),
    '강북구': LatLng(37.6398, 127.0255),
    '강서구': LatLng(37.5509, 126.8496),
    '관악구': LatLng(37.4783, 126.9515),
    '광진구': LatLng(37.5385, 127.0827),
    '구로구': LatLng(37.4954, 126.8582),
    '금천구': LatLng(37.4578, 126.8953),
    '노원구': LatLng(37.6538, 127.0567),
    '도봉구': LatLng(37.6687, 127.0471),
    '동대문구': LatLng(37.5744, 127.0396),
    '동작구': LatLng(37.5124, 126.9392),
    '마포구': LatLng(37.5661, 126.9011),
    '서대문구': LatLng(37.5794, 126.9366),
    '서초구': LatLng(37.4835, 127.0326),
    '성동구': LatLng(37.5635, 127.0366),
    '성북구': LatLng(37.5894, 127.0167),
    '송파구': LatLng(37.5145, 127.1065),
    '양천구': LatLng(37.5255, 126.8661),
    '영등포구': LatLng(37.5264, 126.8966),
    '용산구': LatLng(37.5323, 126.9905),
    '은평구': LatLng(37.6027, 126.9292),
    '종로구': LatLng(37.5735, 126.9794),
    '중구': LatLng(37.5637, 126.9975),
    '중랑구': LatLng(37.5960, 127.0929),
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initDatabaseAndLoadStores();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // DB 초기화 + 더미 데이터 삽입 + 화면 로드
  // -------------------------------------------------------------
  Future<void> _initDatabaseAndLoadStores() async {
    final initialData = <Map<String, dynamic>>[
      {'bid': 1, 'name': '강남로데오점(XYZ 슈퍼)', 'district': '강남구', 'address': '서울특별시 강남구 논현로102길 3', 'image': 'images/xyz_logo.png', 'lat': 37.5255, 'lng': 127.0396},
      {'bid': 2, 'name': '서초구 강남대로점(XYZ 슈퍼)', 'district': '서초구', 'address': '서울특별시 서초구 강남대로 78길', 'image': 'images/xyz_logo.png', 'lat': 37.4940, 'lng': 127.0230},
      {'bid': 3, 'name': '역삼점(XYZ 슈퍼)', 'district': '강남구', 'address': '서울특별시 강남구 역삼로 204', 'image': 'images/xyz_logo.png', 'lat': 37.4975, 'lng': 127.0345},
      {'bid': 4, 'name': '논현역점(XYZ 슈퍼)', 'district': '강남구', 'address': '서울특별시 강남구 학동로 202', 'image': 'images/xyz_logo.png', 'lat': 37.5110, 'lng': 127.0215},
      {'bid': 5, 'name': '신사 가로수길점(XYZ 슈퍼)', 'district': '강남구', 'address': '서울특별시 강남구 강남대로152길 34', 'image': 'images/xyz_logo.png', 'lat': 37.5215, 'lng': 127.0219},
      {'bid': 6, 'name': '양재역점(XYZ 슈퍼)', 'district': '서초구', 'address': '서울특별시 서초구 남부순환로 2640', 'image': 'images/xyz_logo.png', 'lat': 37.4851, 'lng': 127.0347},
      {'bid': 7, 'name': '강동 천호점(XYZ 슈퍼)', 'district': '강동구', 'address': '서울특별시 강동구 천호대로 1052', 'image': 'images/xyz_logo.png', 'lat': 37.5381, 'lng': 127.1265},
      {'bid': 8, 'name': '강북 미아점(XYZ 슈퍼)', 'district': '강북구', 'address': '서울특별시 강북구 도봉로 349', 'image': 'images/xyz_logo.png', 'lat': 37.6140, 'lng': 127.0315},
      {'bid': 9, 'name': '강서 마곡점(XYZ 슈퍼)', 'district': '강서구', 'address': '서울특별시 강서구 마곡중앙8로 149', 'image': 'images/xyz_logo.png', 'lat': 37.5615, 'lng': 126.8335},
      {'bid': 10, 'name': '관악 신림점(XYZ 슈퍼)', 'district': '관악구', 'address': '서울특별시 관악구 신림로 330', 'image': 'images/xyz_logo.png', 'lat': 37.4839, 'lng': 126.9295},
      {'bid': 11, 'name': '광진 건대점(XYZ 슈퍼)', 'district': '광진구', 'address': '서울특별시 광진구 능동로 120', 'image': 'images/xyz_logo.png', 'lat': 37.5408, 'lng': 127.0699},
      {'bid': 12, 'name': '구로 신도림점(XYZ 슈퍼)', 'district': '구로구', 'address': '서울특별시 구로구 경인로 661', 'image': 'images/xyz_logo.png', 'lat': 37.5085, 'lng': 126.8837},
      {'bid': 13, 'name': '금천 가산점(XYZ 슈퍼)', 'district': '금천구', 'address': '서울특별시 금천구 디지털로10길 9', 'image': 'images/xyz_logo.png', 'lat': 37.4789, 'lng': 126.8890},
      {'bid': 14, 'name': '노원 공릉점(XYZ 슈퍼)', 'district': '노원구', 'address': '서울특별시 노원구 공릉로 232', 'image': 'images/xyz_logo.png', 'lat': 37.6255, 'lng': 127.0768},
      {'bid': 15, 'name': '도봉 창동점(XYZ 슈퍼)', 'district': '도봉구', 'address': '서울특별시 도봉구 노해로 395', 'image': 'images/xyz_logo.png', 'lat': 37.6520, 'lng': 127.0465},
      {'bid': 16, 'name': '동대문 청량리점(XYZ 슈퍼)', 'district': '동대문구', 'address': '서울특별시 동대문구 왕산로 214', 'image': 'images/xyz_logo.png', 'lat': 37.5802, 'lng': 127.0487},
      {'bid': 17, 'name': '동작 사당점(XYZ 슈퍼)', 'district': '동작구', 'address': '서울특별시 동작구 동작대로 107', 'image': 'images/xyz_logo.png', 'lat': 37.4781, 'lng': 126.9806},
      {'bid': 18, 'name': '마포 홍대점(XYZ 슈퍼)', 'district': '마포구', 'address': '서울특별시 마포구 양화로 165', 'image': 'images/xyz_logo.png', 'lat': 37.5566, 'lng': 126.9237},
      {'bid': 19, 'name': '서대문 신촌점(XYZ 슈퍼)', 'district': '서대문구', 'address': '서울특별시 서대문구 신촌로 141', 'image': 'images/xyz_logo.png', 'lat': 37.5560, 'lng': 126.9405},
      {'bid': 20, 'name': '성동 왕십리점(XYZ 슈퍼)', 'district': '성동구', 'address': '서울특별시 성동구 왕십리로 326', 'image': 'images/xyz_logo.png', 'lat': 37.5615, 'lng': 127.0295},
      {'bid': 21, 'name': '성북 길음점(XYZ 슈퍼)', 'district': '성북구', 'address': '서울특별시 성북구 동소문로 286', 'image': 'images/xyz_logo.png', 'lat': 37.6040, 'lng': 127.0185},
      {'bid': 22, 'name': '송파 잠실점(XYZ 슈퍼)', 'district': '송파구', 'address': '서울특별시 송파구 올림픽로 240', 'image': 'images/xyz_logo.png', 'lat': 37.5130, 'lng': 127.0980},
      {'bid': 23, 'name': '양천 목동점(XYZ 슈퍼)', 'district': '양천구', 'address': '서울특별시 양천구 목동동로 257', 'image': 'images/xyz_logo.png', 'lat': 37.5270, 'lng': 126.8745},
      {'bid': 24, 'name': '영등포 여의도점(XYZ 슈퍼)', 'district': '영등포구', 'address': '서울특별시 영등포구 국제금융로 10', 'image': 'images/xyz_logo.png', 'lat': 37.5255, 'lng': 126.9255},
      {'bid': 25, 'name': '용산 이태원점(XYZ 슈퍼)', 'district': '용산구', 'address': '서울특별시 용산구 이태원로 244', 'image': 'images/xyz_logo.png', 'lat': 37.5330, 'lng': 126.9950},
      {'bid': 26, 'name': '은평 연신내점(XYZ 슈퍼)', 'district': '은평구', 'address': '서울특별시 은평구 통일로 856', 'image': 'images/xyz_logo.png', 'lat': 37.6190, 'lng': 126.9205},
      {'bid': 27, 'name': '종로 광화문점(XYZ 슈퍼)', 'district': '종로구', 'address': '서울특별시 종로구 세종대로 175', 'image': 'images/xyz_logo.png', 'lat': 37.5707, 'lng': 126.9786},
      {'bid': 28, 'name': '중구 명동점(XYZ 슈퍼)', 'district': '중구', 'address': '서울특별시 중구 명동길 72', 'image': 'images/xyz_logo.png', 'lat': 37.5620, 'lng': 126.9855},
      {'bid': 29, 'name': '중랑 상봉점(XYZ 슈퍼)', 'district': '중랑구', 'address': '서울특별시 중랑구 망우로 307', 'image': 'images/xyz_logo.png', 'lat': 37.5975, 'lng': 127.0950},
    ];

    final branchesToInsert = initialData
        .map(
          (e) => Branch(
            bid: e['bid'] as int,
            blat: e['lat'] as double,
            blng: e['lng'] as double,
            bname: e['name'] as String,
          ),
        )
        .toList();

    await _branchDB.initializeBranchesIfEmpty(branchesToInsert);

    if (!mounted) return;
    setState(() => allStores = initialData);
  }

  // -------------------------------------------------------------
  // 유틸
  // -------------------------------------------------------------
  int _calculateDistanceInMeters(double lat, double lng) {
    final storeLocation = LatLng(lat, lng);
    return distance(gangnamStation, storeLocation).round();
  }

  String _formatDistance(int meter) {
    if (meter < 1000) return '${meter}m';
    final km = meter / 1000.0;
    return '${km.toStringAsFixed(1)}km';
  }

  void _onSearchChanged() {
    setState(() => _currentSearchQuery = _searchController.text.toLowerCase());

    // 지도 탭에서 검색 시, 첫 매장 기준으로 지도 이동(기존 로직 유지)
    if (_currentTab == 1) {
      final filteredStores = _getFilteredStores();
      if (filteredStores.isNotEmpty) {
        final store = filteredStores.first;
        _mapController.move(
          LatLng(store['lat'] as double, store['lng'] as double),
          13.0,
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredStores() {
    return allStores.where((store) {
      final district = (store['district'] as String).toLowerCase();
      final name = (store['name'] as String).toLowerCase();

      final dropdownMatch = _selectedDistrict == null ||
          _selectedDistrict == '전체' ||
          district.contains(_selectedDistrict!.toLowerCase());

      final searchMatch = _currentSearchQuery.isEmpty ||
          district.contains(_currentSearchQuery) ||
          name.contains(_currentSearchQuery);

      return dropdownMatch && searchMatch;
    }).toList();
  }

  // 선택된 매장 위치 저장 + 지도 탭으로 전환 + 즉시 이동
  void _selectStoreAndMoveMap(double lat, double lng) {
    final selectedLocation = LatLng(lat, lng);

    setState(() {
      _currentTab = 1;
      _pendingCenter = selectedLocation;
    });

    if (_mapReady) {
      _mapController.move(selectedLocation, 14.0);
    }
  }

  void _showSelectionDialog(Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('매장 선택 확인'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  '${store['name']} (${store['district']})을(를) 선택하시겠습니까?',
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Text(
                  '상세 주소: ${store['address']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기

                // 1) 전역 컨트롤러 저장
                storeController.setStore(store);

                // 2) PayPage에서 호출된 경우 결과 반환
                if (widget.popOnSelect) {
                  Get.back(result: store);
                  return;
                }

                _selectStoreAndMoveMap(
                  store['lat'] as double,
                  store['lng'] as double,
                );
              },
              child: const Text('선택 및 지도 확인'),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png',
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: _currentTab == 0 ? _buildListView() : _buildMapView(),
            ),
            _buildSelectedStoreBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          const Text(
            '매장선택',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '매장을 검색해보세요 (예: 강남구)',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: (_) => _onSearchChanged(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _TabButton(
              label: '목록',
              isActive: _currentTab == 0,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 8,
                left: 20,
                right: 30,
              ),
              onTap: () => setState(() => _currentTab = 0),
            ),
            _TabButton(
              label: '지도',
              isActive: _currentTab == 1,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 8,
                right: 20,
              ),
              onTap: () => setState(() => _currentTab = 1),
            ),
          ],
        ),
        Stack(
          children: [
            Container(height: 1, color: Colors.grey[300]),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: _currentTab == 0 ? 20 : 80),
              width: 40,
              height: 2,
              color: Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (allStores.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredStores = _getFilteredStores();

    filteredStores.sort((a, b) {
      final distA = _calculateDistanceInMeters(
        a['lat'] as double,
        a['lng'] as double,
      );
      final distB = _calculateDistanceInMeters(
        b['lat'] as double,
        b['lng'] as double,
      );
      return distA.compareTo(distB);
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지역 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            _buildDistrictDropdown(),
            const Padding(padding: EdgeInsets.only(top: 20)),
            const Text(
              '가까운 매장 (거리순 정렬 / 기준: 강남역)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Padding(padding: EdgeInsets.only(top: 15)),
            ...filteredStores.map((store) {
              final meter = _calculateDistanceInMeters(
                store['lat'] as double,
                store['lng'] as double,
              );
              return _buildStoreCard(
                store: store,
                name: store['name'] as String,
                address: store['district'] as String,
                distance: _formatDistance(meter),
                imagePath: store['image'] as String,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    final items = ['전체', ...seoulDistricts];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrict ?? '전체',
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onChanged: (newValue) {
            setState(() {
              _selectedDistrict = newValue;
              _searchController.clear();
              _currentSearchQuery = '';
            });

            // 지도 탭에서 구 변경 시 중심 이동(기존 유지)
            if (_currentTab == 1) {
              if (newValue != null && newValue != '전체') {
                final center = seoulDistrictCenters[newValue];
                if (center != null) _mapController.move(center, 12.0);
              } else {
                _mapController.move(const LatLng(37.5665, 126.9780), 10.5);
              }
            }
          },
          items: items
              .map(
                (value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStoreCard({
    required Map<String, dynamic> store,
    required String name,
    required String address,
    required String distance,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address, style: const TextStyle(color: Colors.grey)),
              const Padding(padding: EdgeInsets.only(top: 5)),
              Text(
                distance,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          trailing: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          onTap: () => _showSelectionDialog(store),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final markers = allStores.map((store) {
      final point = LatLng(store['lat'] as double, store['lng'] as double);

      return Marker(
        point: point,
        width: 100,
        height: 50,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                store['district'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const Icon(Icons.location_on, color: Colors.red, size: 25),
          ],
        ),
      );
    }).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(37.5665, 126.9780),
        initialZoom: 10.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () {
          _mapReady = true;
          if (_pendingCenter != null) {
            _mapController.move(_pendingCenter!, 14.0);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.xyz_project_01',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  // ✅ 하단 선택 매장 바 (레이아웃 자리 확보는 SizedBox 유지)
// ✅ 하단 선택 매장 바 (레이아웃 자리 확보는 SizedBox 유지)
  Widget _buildSelectedStoreBar() {
    return Obx(() {
      final store = storeController.selectedStore.value;
      if (store == null) return const SizedBox();

      final storeName = (store['name'] as String?) ?? '';

      return Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.only(bottom: 65), // 탭바 위
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  storeName,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // 중앙 FloatingActionButton 공간 확보용(기능/레이아웃 유지)
            const SizedBox(width: 70),

            const Expanded(child: SizedBox()),
          ],
        ),
      );
    });
  }
}

// -----------------------------------
// 탭 버튼(정리용)
// -----------------------------------
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final EdgeInsets padding;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.padding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
