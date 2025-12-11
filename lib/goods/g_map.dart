import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 

class Branch {      
  int bid;          
  double blat;      
  double blng;      
  String bname;     

  Branch({
      required this.bid,
      required this.blat,
      required this.blng,
      required this.bname,
  });

  Branch.fromMap(Map<String, dynamic> res)
  : bid = res['bid'],
    blat = res['blat'], 
    blng = res['blng'],
    bname = res['bname'];
}

class GMap extends StatefulWidget {
  const GMap({super.key});

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  // --- 데이터 정의 및 컨트롤러 ---

  final LatLng gangnamStation = const LatLng(37.4981, 127.0276);
  final Distance distance = const Distance(); 
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = ''; 
  final MapController _mapController = MapController();
  int _currentTab = 0; 
  
  // [4] 매장 목록 (위도/경도 포함) - 전체 데이터
  final List<Map<String, dynamic>> allStores = [
    // 상세 주소는 데이터에서만 유지하고, 화면에는 구 이름만 표시합니다.
    {'name': '강남로데오점(XYZ 슈퍼)', 'address': '서울특별시 강남구 논현로102길 3', 'district': '강남구', 'image': 'images/xyz_logo.png', 'lat': 37.5255, 'lng': 127.0396}, 
    {'name': '서초구 강남대로점(XYZ 슈퍼)', 'address': '서울특별시 서초구 강남대로 78길', 'district': '서초구', 'image': 'images/xyz_logo.png', 'lat': 37.4940, 'lng': 127.0230}, 
    {'name': '역삼점(XYZ 슈퍼)', 'address': '서울특별시 강남구 역삼로 204', 'district': '강남구', 'image': 'images/xyz_logo.png', 'lat': 37.4975, 'lng': 127.0345},
    {'name': '논현역점(XYZ 슈퍼)', 'address': '서울특별시 강남구 학동로 202', 'district': '강남구', 'image': 'images/xyz_logo.png', 'lat': 37.5110, 'lng': 127.0215}, 
    {'name': '신사 가로수길점(XYZ 슈퍼)', 'address': '서울특별시 강남구 강남대로152길 34', 'district': '강남구', 'image': 'images/xyz_logo.png', 'lat': 37.5215, 'lng': 127.0219},
    {'name': '양재역점(XYZ 슈퍼)', 'address': '서울특별시 서초구 남부순환로 2640', 'district': '서초구', 'image': 'images/xyz_logo.png', 'lat': 37.4851, 'lng': 127.0347},
    
    // 나머지 구별 대표 매장
    {'name': '강동 천호점(XYZ 슈퍼)', 'address': '서울특별시 강동구 천호대로 1052', 'district': '강동구', 'image': 'images/xyz_logo.png', 'lat': 37.5381, 'lng': 127.1265},
    {'name': '강북 미아점(XYZ 슈퍼)', 'address': '서울특별시 강북구 도봉로 349', 'district': '강북구', 'image': 'images/xyz_logo.png', 'lat': 37.6140, 'lng': 127.0315},
    {'name': '강서 마곡점(XYZ 슈퍼)', 'address': '서울특별시 강서구 마곡중앙8로 149', 'district': '강서구', 'image': 'images/xyz_logo.png', 'lat': 37.5615, 'lng': 126.8335},
    {'name': '관악 신림점(XYZ 슈퍼)', 'address': '서울특별시 관악구 신림로 330', 'district': '관악구', 'image': 'images/xyz_logo.png', 'lat': 37.4839, 'lng': 126.9295},
    {'name': '광진 건대점(XYZ 슈퍼)', 'address': '서울특별시 광진구 능동로 120', 'district': '광진구', 'image': 'images/xyz_logo.png', 'lat': 37.5408, 'lng': 127.0699},
    {'name': '구로 신도림점(XYZ 슈퍼)', 'address': '서울특별시 구로구 경인로 661', 'district': '구로구', 'image': 'images/xyz_logo.png', 'lat': 37.5085, 'lng': 126.8837},
    {'name': '금천 가산점(XYZ 슈퍼)', 'address': '서울특별시 금천구 디지털로10길 9', 'district': '금천구', 'image': 'images/xyz_logo.png', 'lat': 37.4789, 'lng': 126.8890},
    {'name': '노원 공릉점(XYZ 슈퍼)', 'address': '서울특별시 노원구 공릉로 232', 'district': '노원구', 'image': 'images/xyz_logo.png', 'lat': 37.6255, 'lng': 127.0768},
    {'name': '도봉 창동점(XYZ 슈퍼)', 'address': '서울특별시 도봉구 노해로 395', 'district': '도봉구', 'image': 'images/xyz_logo.png', 'lat': 37.6520, 'lng': 127.0465},
    {'name': '동대문 청량리점(XYZ 슈퍼)', 'address': '서울특별시 동대문구 왕산로 214', 'district': '동대문구', 'image': 'images/xyz_logo.png', 'lat': 37.5802, 'lng': 127.0487},
    {'name': '동작 사당점(XYZ 슈퍼)', 'address': '서울특별시 동작구 동작대로 107', 'district': '동작구', 'image': 'images/xyz_logo.png', 'lat': 37.4781, 'lng': 126.9806},
    {'name': '마포 홍대점(XYZ 슈퍼)', 'address': '서울특별시 마포구 양화로 165', 'district': '마포구', 'image': 'images/xyz_logo.png', 'lat': 37.5566, 'lng': 126.9237},
    {'name': '서대문 신촌점(XYZ 슈퍼)', 'address': '서울특별시 서대문구 신촌로 141', 'district': '서대문구', 'image': 'images/xyz_logo.png', 'lat': 37.5560, 'lng': 126.9405},
    {'name': '성동 왕십리점(XYZ 슈퍼)', 'address': '서울특별시 성동구 왕십리로 326', 'district': '성동구', 'image': 'images/xyz_logo.png', 'lat': 37.5615, 'lng': 127.0295},
    {'name': '성북 길음점(XYZ 슈퍼)', 'address': '서울특별시 성북구 동소문로 286', 'district': '성북구', 'image': 'images/xyz_logo.png', 'lat': 37.6040, 'lng': 127.0185},
    {'name': '송파 잠실점(XYZ 슈퍼)', 'address': '서울특별시 송파구 올림픽로 240', 'district': '송파구', 'image': 'images/xyz_logo.png', 'lat': 37.5130, 'lng': 127.0980},
    {'name': '양천 목동점(XYZ 슈퍼)', 'address': '서울특별시 양천구 목동동로 257', 'district': '양천구', 'image': 'images/xyz_logo.png', 'lat': 37.5270, 'lng': 126.8745},
    {'name': '영등포 여의도점(XYZ 슈퍼)', 'address': '서울특별시 영등포구 국제금융로 10', 'district': '영등포구', 'image': 'images/xyz_logo.png', 'lat': 37.5255, 'lng': 126.9255},
    {'name': '용산 이태원점(XYZ 슈퍼)', 'address': '서울특별시 용산구 이태원로 244', 'district': '용산구', 'image': 'images/xyz_logo.png', 'lat': 37.5330, 'lng': 126.9950},
    {'name': '은평 연신내점(XYZ 슈퍼)', 'address': '서울특별시 은평구 통일로 856', 'district': '은평구', 'image': 'images/xyz_logo.png', 'lat': 37.6190, 'lng': 126.9205},
    {'name': '종로 광화문점(XYZ 슈퍼)', 'address': '서울특별시 종로구 세종대로 175', 'district': '종로구', 'image': 'images/xyz_logo.png', 'lat': 37.5707, 'lng': 126.9786},
    {'name': '중구 명동점(XYZ 슈퍼)', 'address': '서울특별시 중구 명동길 72', 'district': '중구', 'image': 'images/xyz_logo.png', 'lat': 37.5620, 'lng': 126.9855},
    {'name': '중랑 상봉점(XYZ 슈퍼)', 'address': '서울특별시 중랑구 망우로 307', 'district': '중랑구', 'image': 'images/xyz_logo.png', 'lat': 37.5975, 'lng': 127.0950},
  ];

  // [5] 기타 데이터 (변화 없음)
  final List<String> seoulDistricts = [
    '강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', 
    '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', 
    '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', 
    '은평구', '종로구', '중구', '중랑구'
  ];

  final Map<String, LatLng> seoulDistrictCenters = {
    '강남구': LatLng(37.5175, 127.0475), '강동구': LatLng(37.5301, 127.1238), '강북구': LatLng(37.6398, 127.0255),
    '강서구': LatLng(37.5509, 126.8496), '관악구': LatLng(37.4783, 126.9515), '광진구': LatLng(37.5385, 127.0827),
    '구로구': LatLng(37.4954, 126.8582), '금천구': LatLng(37.4578, 126.8953), '노원구': LatLng(37.6538, 127.0567),
    '도봉구': LatLng(37.6687, 127.0471), '동대문구': LatLng(37.5744, 127.0396), '동작구': LatLng(37.5124, 126.9392),
    '마포구': LatLng(37.5661, 126.9011), '서대문구': LatLng(37.5794, 126.9366), '서초구': LatLng(37.4835, 127.0326),
    '성동구': LatLng(37.5635, 127.0366), '성북구': LatLng(37.5894, 127.0167), '송파구': LatLng(37.5145, 127.1065),
    '양천구': LatLng(37.5255, 126.8661), '영등포구': LatLng(37.5264, 126.8966), '용산구': LatLng(37.5323, 126.9905),
    '은평구': LatLng(37.6027, 126.9292), '종로구': LatLng(37.5735, 126.9794), '중구': LatLng(37.5637, 126.9975),
    '중랑구': LatLng(37.5960, 127.0929),
  };
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  // --- 거리 계산 함수: 미터 반환 ---
  int _calculateDistanceInMeters(double lat, double lng) {
    final LatLng storeLocation = LatLng(lat, lng);
    return distance(gangnamStation, storeLocation).round();
  }
  
  // --- 거리 문자열 변환 함수 ---
  String _formatDistance(int meter) {
    if (meter < 1000) {
      return '${meter}m';
    } else {
      double km = meter / 1000.0;
      return '${km.toStringAsFixed(1)}km'; 
    }
  }

  // --- 검색 로직 ---
  void _onSearchChanged() {
    setState(() {
      _currentSearchQuery = _searchController.text.toLowerCase();
    });
  }

  // --- 매장 선택 및 지도 이동 로직 ---
  void _selectStoreAndMoveMap(String name, double lat, double lng) {
    final LatLng selectedLocation = LatLng(lat, lng);
    
    setState(() {
      _currentTab = 1; // 탭을 지도로 변경
    });

    // 지도 컨트롤러를 사용하여 해당 위치로 이동 및 확대
    _mapController.move(selectedLocation, 14.0); 
  }

  // --- 다이얼로그 표시 로직 ---
  void _showSelectionDialog(Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('매장 선택 확인'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${store['name']} (${store['district']})을(를) 선택하시겠습니까?'),
                const SizedBox(height: 10),
                Text('상세 주소: ${store['address']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('선택 및 지도 확인'),
              onPressed: () {
                Navigator.of(context).pop(); 
                _selectStoreAndMoveMap(store['name'], store['lat'], store['lng']);
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(), 
            _buildSearchBar(), 
            _buildTabBar(), 
            Expanded(
              child: _currentTab == 0
                  ? _buildListView() 
                  : _buildMapView(), 
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. 헤더 (변화 없음) ---
  Widget _buildHeader() { /* ... */ return Container(); }
  
  // 2. 검색창 (변화 없음)
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
            hintText: '구 이름 (예: 강남구)',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: (value) { _onSearchChanged(); },
        ),
      ),
    );
  }

  // 3. 목록/지도 탭 버튼 (변화 없음)
  Widget _buildTabBar() { /* ... */ return Container(); }

  // 4-A. 목록 탭 내용 (정렬 및 주소 간소화 적용)
  Widget _buildListView() {
    // 1. 필터링 로직: 현재 검색어에 따라 매장 필터링
    final filteredStores = allStores.where((store) {
      if (_currentSearchQuery.isEmpty) return true;

      final district = (store['district'] as String).toLowerCase();
      final name = (store['name'] as String).toLowerCase();

      return district.contains(_currentSearchQuery) || name.contains(_currentSearchQuery);
    }).toList();

    // 2. **거리순 정렬 로직 적용**
    filteredStores.sort((a, b) {
      final distA = _calculateDistanceInMeters(a['lat'], a['lng']);
      final distB = _calculateDistanceInMeters(b['lat'], b['lng']);
      return distA.compareTo(distB); // 가까운 거리(작은 값)가 먼저 오도록 정렬
    });


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentSearchQuery.isEmpty 
              ? '가까운 매장 (거리순 정렬 / 기준: 강남역)' // 정렬 정보 추가
              : '검색 결과 (${filteredStores.length}개)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 필터링 및 정렬된 매장 목록 빌드
            ...filteredStores.map((store) {
              final int meter = _calculateDistanceInMeters(store['lat'], store['lng']);
              final String formattedDistance = _formatDistance(meter);
              
              return _buildStoreCard(
                store: store, 
                name: store['name'] as String,
                address: store['district'] as String, // **간소화된 주소 (구 이름)**
                distance: formattedDistance, 
                imagePath: store['image'] as String,
              );
            }).toList(),
            
            // 검색 중이 아닐 때만 서울 전 지역 구 목록 표시
            if (_currentSearchQuery.isEmpty) ...[
              const SizedBox(height: 30),
              const Text('서울 전 지역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              Wrap(
                spacing: 8.0, runSpacing: 8.0,
                children: seoulDistricts.map((district) => _buildDistrictButton(district)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 매장 항목 카드 위젯 (주소 표시 변경)
  Widget _buildStoreCard({
    required Map<String, dynamic> store, 
    required String name,
    required String address, // 이제 구 이름만 받습니다
    required String distance,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address, style: const TextStyle(color: Colors.grey)), // 구 이름 표시
              const SizedBox(height: 5),
              Text(distance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          trailing: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.contain),
          onTap: () { 
            _showSelectionDialog(store);
          },
        ),
      ),
    );
  }
  
  // 구 이름 버튼 위젯 (변화 없음)
  Widget _buildDistrictButton(String district) {
    return OutlinedButton(
      onPressed: () { 
        _searchController.text = district;
        _onSearchChanged();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black, side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(district, style: const TextStyle(fontSize: 14)),
    );
  }

  // 4-B. 지도 탭 내용 (변화 없음)
  Widget _buildMapView() { /* ... */ return Container(); }
}