// lib/vm/database/example_data.dart 파일 전체 코드 (employee 테이블 ename 오류 수정)

import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/employee.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class ExampleData {
  
  final handler = DatabaseHandler(); 

  // 1. 고객 (customer) 예시 데이터 (기존 내용 유지)
  static final List<Map<String, dynamic>> customers = [
    // { 'cemail': 'user1@example.com', 'cpw': '1234', ... },
    {
    'cemail' : '123',
    'cpw' : '123',
    'cphone' : '123',
    'cname' : '123',
    'caddress' : '123',
    }
  ];

  // 2. 상품 (goods) 예시 데이터 (기존 내용 유지)
  static final List<Map<String, dynamic>> goods = _generateGoodsData();

  // ⭐️ 3. 지점 (branch) 예시 데이터 (bid만 삽입) ⭐️
  static final List<Map<String, dynamic>> branches = _getBranchInitialDataForDB();

  // ⭐️ 4. 직원 (employee) 예시 데이터 (자동 생성 함수 사용) ⭐️
  static final List<Map<String, dynamic>> employees = _generateEmployeeData();
  
  // 5. 공급업체 (supplier) 예시 데이터
  static final List<Map<String, dynamic>> suppliers = [
    {
      'sid': 3001,
      'sname': '나이키',
    },
    {
      'sid': 3002,
      'sname': '아디다스',
    },
    {
      'sid': 3003,
      'sname': '뉴발란스',
    },
    {
      'sid': 3004,
      'sname': '푸마',
    },
    {
      'sid': 3005,
      'sname': '아식스',
    },
    {
      'sid': 3006,
      'sname': '프로스펙스',
    },
    {
      'sid': 3007,
      'sname': '스케쳐스',
    },
    {
      'sid': 9999,
      'sname': 'XYZ',
    },
  ];

  // (purchase, refund, approval, orders 데이터는 일단 비워둡니다.)
  static final List<Map<String, dynamic>> purchases = [];
  static final List<Map<String, dynamic>> refunds = [];
  static final List<Map<String, dynamic>> approvals = [];
  static final List<Map<String, dynamic>> orders = [];


  // 헬퍼 함수 1-1: 직원 생성 로직에서만 사용할 전체 지점 정보 
  static List<Map<String, dynamic>> _getBranchInitialData() {
    // DB에 삽입되지 않는 정보도 모두 포함 (직원 데이터 생성에 필요)
    return [
      {'bid': 1, 'name': '강남로데오점', 'engName': 'GangnamRodeo', 'district': '강남구', 'address': '서울특별시 강남구 논현로102길 3', 'image': 'images/xyz_logo.png', 'lat': 37.5255, 'lng': 127.0396},
      {'bid': 2, 'name': '서초강남대로점', 'engName': 'SeochoGangnam', 'district': '서초구', 'address': '서울특별시 서초구 강남대로 78길', 'image': 'images/xyz_logo.png', 'lat': 37.4940, 'lng': 127.0230},
      {'bid': 3, 'name': '역삼점', 'engName': 'Yeoksam', 'district': '강남구', 'address': '서울특별시 강남구 역삼로 204', 'image': 'images/xyz_logo.png', 'lat': 37.4975, 'lng': 127.0345},
      {'bid': 4, 'name': '논현역점', 'engName': 'Nonhyeon', 'district': '강남구', 'address': '서울특별시 강남구 학동로 202', 'image': 'images/xyz_logo.png', 'lat': 37.5110, 'lng': 127.0215},
      {'bid': 5, 'name': '신사가로수길점', 'engName': 'SinsaGarosu', 'district': '강남구', 'address': '서울특별시 강남구 강남대로152길 34', 'image': 'images/xyz_logo.png', 'lat': 37.5215, 'lng': 127.0219},
      {'bid': 6, 'name': '양재역점', 'engName': 'Yangjae', 'district': '서초구', 'address': '서울특별시 서초구 남부순환로 2640', 'image': 'images/xyz_logo.png', 'lat': 37.4851, 'lng': 127.0347},
      {'bid': 7, 'name': '강동천호점', 'engName': 'GangdongCheonho', 'district': '강동구', 'address': '서울특별시 강동구 천호대로 1052', 'image': 'images/xyz_logo.png', 'lat': 37.5381, 'lng': 127.1265},
      {'bid': 8, 'name': '강북미아점', 'engName': 'GangbukMia', 'district': '강북구', 'address': '서울특별시 강북구 도봉로 349', 'image': 'images/xyz_logo.png', 'lat': 37.6140, 'lng': 127.0315},
      {'bid': 9, 'name': '강서마곡점', 'engName': 'GangseoMagok', 'district': '강서구', 'address': '서울특별시 강서구 마곡중앙8로 149', 'image': 'images/xyz_logo.png', 'lat': 37.5615, 'lng': 126.8335},
      {'bid': 10, 'name': '관악신림점', 'engName': 'GwanakSillim', 'district': '관악구', 'address': '서울특별시 관악구 신림로 330', 'image': 'images/xyz_logo.png', 'lat': 37.4839, 'lng': 126.9295},
      {'bid': 11, 'name': '광진건대점', 'engName': 'GwangjinKonkuk', 'district': '광진구', 'address': '서울특별시 광진구 능동로 120', 'image': 'images/xyz_logo.png', 'lat': 37.5408, 'lng': 127.0699},
      {'bid': 12, 'name': '구로신도림점', 'engName': 'GuroSindorim', 'district': '구로구', 'address': '서울특별시 구로구 경인로 661', 'image': 'images/xyz_logo.png', 'lat': 37.5085, 'lng': 126.8837},
      {'bid': 13, 'name': '금천가산점', 'engName': 'GeumcheonGasan', 'district': '금천구', 'address': '서울특별시 금천구 디지털로10길 9', 'image': 'images/xyz_logo.png', 'lat': 37.4789, 'lng': 126.8890},
      {'bid': 14, 'name': '노원공릉점', 'engName': 'NowonGongneung', 'district': '노원구', 'address': '서울특별시 노원구 공릉로 232', 'image': 'images/xyz_logo.png', 'lat': 37.6255, 'lng': 127.0768},
      {'bid': 15, 'name': '도봉창동점', 'engName': 'DobongChangdong', 'district': '도봉구', 'address': '서울특별시 도봉구 노해로 395', 'image': 'images/xyz_logo.png', 'lat': 37.6520, 'lng': 127.0465},
      {'bid': 16, 'name': '동대문청량리점', 'engName': 'DongdaemunCheongnyangni', 'district': '동대문구', 'address': '서울특별시 동대문구 왕산로 214', 'image': 'images/xyz_logo.png', 'lat': 37.5802, 'lng': 127.0487},
      {'bid': 17, 'name': '동작사당점', 'engName': 'DongjakSadang', 'district': '동작구', 'address': '서울특별시 동작구 동작대로 107', 'image': 'images/xyz_logo.png', 'lat': 37.4781, 'lng': 126.9806},
      {'bid': 18, 'name': '마포홍대점', 'engName': 'MapoHongdae', 'district': '마포구', 'address': '서울특별시 마포구 양화로 165', 'image': 'images/xyz_logo.png', 'lat': 37.5566, 'lng': 126.9237},
      {'bid': 19, 'name': '서대문신촌점', 'engName': 'SeodaemunSinchon', 'district': '서대문구', 'address': '서울특별시 서대문구 신촌로 141', 'image': 'images/xyz_logo.png', 'lat': 37.5560, 'lng': 126.9405},
      {'bid': 20, 'name': '성동왕십리점', 'engName': 'SeongdongWangsimni', 'district': '성동구', 'address': '서울특별시 성동구 왕십리로 326', 'image': 'images/xyz_logo.png', 'lat': 37.5615, 'lng': 127.0295},
      {'bid': 21, 'name': '성북길음점', 'engName': 'SeongbukGireum', 'district': '성북구', 'address': '서울특별시 성북구 동소문로 286', 'image': 'images/xyz_logo.png', 'lat': 37.6040, 'lng': 127.0185},
      {'bid': 22, 'name': '송파잠실점', 'engName': 'SongpaJamsil', 'district': '송파구', 'address': '서울특별시 송파구 올림픽로 240', 'image': 'images/xyz_logo.png', 'lat': 37.5130, 'lng': 127.0980},
      {'bid': 23, 'name': '양천목동점', 'engName': 'YangcheonMokdong', 'district': '양천구', 'address': '서울특별시 양천구 목동동로 257', 'image': 'images/xyz_logo.png', 'lat': 37.5270, 'lng': 126.8745},
      {'bid': 24, 'name': '영등포여의도점', 'engName': 'YeongdeungpoYeouido', 'district': '영등포구', 'address': '서울특별시 영등포구 국제금융로 10', 'image': 'images/xyz_logo.png', 'lat': 37.5255, 'lng': 126.9255},
      {'bid': 25, 'name': '용산이태원점', 'engName': 'YongsanItaewon', 'district': '용산구', 'address': '서울특별시 용산구 이태원로 244', 'image': 'images/xyz_logo.png', 'lat': 37.5330, 'lng': 126.9950},
      {'bid': 26, 'name': '은평연신내점', 'engName': 'EunpyeongYeonsinnae', 'district': '은평구', 'address': '서울특별시 은평구 통일로 856', 'image': 'images/xyz_logo.png', 'lat': 37.6190, 'lng': 126.9205},
      {'bid': 27, 'name': '종로광화문점', 'engName': 'JongnoGwanghwamun', 'district': '종로구', 'address': '서울특별시 종로구 세종대로 175', 'image': 'images/xyz_logo.png', 'lat': 37.5707, 'lng': 126.9786},
      {'bid': 28, 'name': '중구명동점', 'engName': 'JungguMyeongdong', 'district': '중구', 'address': '서울특별시 중구 명동길 72', 'image': 'images/xyz_logo.png', 'lat': 37.5620, 'lng': 126.9855},
      {'bid': 29, 'name': '중랑상봉점', 'engName': 'JungnangSangbong', 'district': '중랑구', 'address': '서울특별시 중랑구 망우로 307', 'image': 'images/xyz_logo.png', 'lat': 37.5975, 'lng': 127.0950},
    ];
  }

  // 헬퍼 함수 1-2: DB에 실제로 삽입될 지점 데이터 (bid만 포함) 
  static List<Map<String, dynamic>> _getBranchInitialDataForDB() {
      // Branch 테이블에 bid만 존재한다고 가정
      return _getBranchInitialData().map((branch) {
          return {
              'bid': branch['bid'],
          };
      }).toList();
  }


  // ⭐️⭐️⭐️ 헬퍼 함수 2: 직원 데이터 (Employee) 자동 생성 ⭐️⭐️⭐️
  static List<Map<String, dynamic>> _generateEmployeeData() {
    final List<Map<String, dynamic>> list = [];
    const String defaultPw = '1111';
    const String emailDomain = '@xyz.co.kr';
    
    // ------------------------------------------
    // 1. 본사 직원 (Workplace: 1) - 총 5명
    // ------------------------------------------
    
    // 1-1. 시스템 관리자 (임원)
    list.add({
      'eemail': 'admin$emailDomain',
      'epw': defaultPw,
      // 'ename': '시스템관리자(본사)', // DB 삽입용 리스트에서는 제거 (ename 없음 가정)
      'ephone': '010-0000-0001',
      'erank': 4, 
      'erole': 5, 
      'epower': 4, 
      'workplace': 1, 
      'ebid': null,
    });
    
    // 1-2. 이사
    list.add({
      'eemail': 'director$emailDomain',
      'epw': defaultPw,
      // 'ename': '이사(본사)', // DB 삽입용 리스트에서는 제거
      'ephone': '010-0000-0002',
      'erank': 3, 
      'erole': 1, 
      'epower': 3, 
      'workplace': 1, 
      'ebid': null,
    });
    
    // 1-3. 팀장
    list.add({
      'eemail': 'manager$emailDomain',
      'epw': defaultPw,
      // 'ename': '팀장(본사)', // DB 삽입용 리스트에서는 제거
      'ephone': '010-0000-0003',
      'erank': 2, 
      'erole': 1, 
      'epower': 2, 
      'workplace': 1, 
      'ebid': null,
    });

    // 1-4. 재고 담당 사원
    list.add({
      'eemail': 'stock_hq$emailDomain',
      'epw': defaultPw,
      // 'ename': '재고담당사원(본사)', // DB 삽입용 리스트에서는 제거
      'ephone': '010-0000-0004',
      'erank': 1, 
      'erole': 2, 
      'epower': 4, 
      'workplace': 1, 
      'ebid': null,
    });
    
    // 1-5. 발주 담당 사원
    list.add({
      'eemail': 'order_hq$emailDomain',
      'epw': defaultPw,
      // 'ename': '발주담당사원(본사)', // DB 삽입용 리스트에서는 제거
      'ephone': '010-0000-0005',
      'erank': 1, 
      'erole': 3, 
      'epower': 1, 
      'workplace': 1, 
      'ebid': null,
    });

    // ------------------------------------------
    // 2. 대리점 직원 (Workplace: 2) - 총 58명 (29개 지점 * 2명)
    // ------------------------------------------
    
    final branches = _getBranchInitialData();
    for (var branch in branches) {
      final int bid = branch['bid'] as int;
      final String engName = branch['engName'] as String;
      // final String korName = branch['name'] as String;
      
      // 2-1. 점장 (대리점장)
      list.add({
        'eemail': '${engName}_boss$emailDomain',
        'epw': defaultPw,
        // 'ename': '$korName 점장', // DB 삽입용 리스트에서는 제거
        'ephone': '010-9999-${bid.toString().padLeft(4, '0')}',
        'erank': 2, 
        'erole': 4, 
        'epower': 2, 
        'workplace': 2, 
        'ebid': bid,
      });

      // 2-2. 일반 직원
      list.add({
        'eemail': '${engName}_staff$emailDomain',
        'epw': defaultPw,
        // 'ename': '$korName 직원', // DB 삽입용 리스트에서는 제거
        'ephone': '010-8888-${bid.toString().padLeft(4, '0')}',
        'erank': 1, 
        'erole': 1, 
        'epower': 1, 
        'workplace': 2, 
        'ebid': bid,
      });
    }

    return list;
  }
  
  // 상품 옵션 생성 함수 (기존 유지) 
  static List<Map<String, dynamic>> _generateGoodsData() {
    final List<Map<String, dynamic>> list = [];
    const int gSumAmount = 100; 

    final List<String> sizes = [
      '230', '235', '240', '245', '250',
      '255', '260', '265', '270', '275',
      '280', '285', '290'
    ]; 
    final List<String> colors = ['흰색', '검정색', '시그니쳐 색상', '회색']; 

    final List<Map<String, dynamic>> baseProducts = [
      {
        'gname': '에어맥스',
        'gengname': 'Air Max',
        'gcategory': '러닝화',
        'main': 'main1.png', 'top': 'top1.png', 'back': 'back1.png', 'side': 'side1.png'
      },
      {
        'gname': '에어포스',
        'gengname': 'Air Force',
        'gcategory': '농구화',
        'main': 'main2.png', 'top': 'top2.png', 'back': 'back2.png', 'side': 'side2.png'
      },
      {
        'gname': '파워레인저',
        'gengname': 'Power Rangers',
        'gcategory': '운동화',
        'main': 'main3.png', 'top': 'top3.png', 'back': 'back3.png', 'side': 'side3.png'
      },
      {
        'gname': '가젤',
        'gengname': 'Gazelle',
        'gcategory': '스니커즈',
        'main': 'main4.png', 'top': 'top4.png', 'back': 'back4.png', 'side': 'side4.png'
      },
      {
        'gname': '슈퍼스타',
        'gengname': 'Superstar',
        'gcategory': '스니커즈',
        'main': 'main5.png', 'top': 'top5.png', 'back': 'back5.png', 'side': 'side5.png'
      },
    ];

    const String imagePathBase = 'images/';

    for (final product in baseProducts) {
      for (var size in sizes) {
        for (var color in colors) {
          list.add({
            'gsumamount': gSumAmount,
            'gname': product['gname'],
            'gengname': product['gengname'],
            'gsize': size,
            'gcolor': color,
            'gcategory': product['gcategory'],
            'mainimagePath': '$imagePathBase${product['main']}',
            'topimagePath': '$imagePathBase${product['top']}',
            'backimagePath': '$imagePathBase${product['back']}',
            'sideimagePath': '$imagePathBase${product['side']}',
          });
        }
      }
    }
    
    return list;
  }

  // 이메일 중복 체크 (기존 유지)
  Future<int> idCheck(String id) async {
    final db = await handler.initializeDB();
    var result = await db.rawQuery(
      """
      select count(*) as count
      from employee
      where eemail = ?
      """,
      [id],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 로그인 (기존 유지)
  Future<bool> loginCheck(String id, String pw) async {
    final Database db = await handler.initializeDB();
    final List<Map<String, dynamic>> result = await db.rawQuery(
      """
      select * from employee
      where eemail = ? and epw = ?
      """,
      [id, pw]
    );
    return result.isNotEmpty;
  }

  // ⭐️ 입력 (insertEmployee) 수정 부분 ⭐️
  Future<int> insertEmployee(Employee employee) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    // 'ename' 컬럼을 쿼리 목록과 값 목록에서 모두 제거합니다.
    result = await db.rawInsert(
      """
        insert into employee
        (eemail, epw, ephone, erank, erole, epower, workplace, ebid)
        values
        (?,?,?,?,?,?,?,?)
      """,
      [employee.eemail, employee.epw, employee.ephone, employee.erank, employee.erole, employee.epower, employee.workplace, employee.ebid]
    );
    return result;
  }

  // 수정 (기존 유지)
  Future<int> updateEmployee(Employee employee) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    // 이 쿼리 역시 'ename' 컬럼을 사용하지 않도록 수정해야 할 수 있습니다. 
    // 하지만 현재 오류는 insert이므로 일단 유지합니다.
    result = await db.rawUpdate(
      """
      update employee
      set epw = ?, ename = ?, ephone = ?
      where eseq = ?
      """,
      [employee.epw, employee.ename, employee.ephone, employee.eseq]
    );
    return result;
  }

  // 삭제 (기존 유지)
  Future<void> deleteEmployee(int eseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from employee
        where eseq = ?
      """,
      [eseq]
    );
  }

}