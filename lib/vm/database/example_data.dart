// lib/vm/database/example_data.dart

class ExampleData {
  // 1. 고객 (customer) 예시 데이터 (임의의 데이터)
  static final List<Map<String, dynamic>> customers = [
    // {
    //   'cemail': 'user1@example.com',
    //   'cpw': '1234',
    //   'cphone': '010-1111-1111',
    //   'cname': '김철수',
    //   'caddress': '서울시 강남구',
    // },
    // {
    //   'cemail': 'user2@example.com',
    //   'cpw': '1234',
    //   'cphone': '010-2222-2222',
    //   'cname': '이영희',
    //   'caddress': '경기도 성남시',
    // },
  ];

  // 2. 상품 (goods) 예시 데이터
  static final List<Map<String, dynamic>> goods = _generateGoodsData();

  // 3. 지점 (branch) 예시 데이터 (임의의 데이터)
  static final List<Map<String, dynamic>> branches = [
    // {'bid': 1001, 'blat': 37.514, 'blng': 127.039, 'bname': '강남 XYZ 본점'},
    // {'bid': 1002, 'blat': 37.566, 'blng': 126.978, 'bname': '명동 XYZ 지점'},
  ];

  // 4. 직원 (employee) 예시 데이터 (임의의 데이터)
  static final List<Map<String, dynamic>> employees = [
    // {
    //   'eemail': 'admin@xyz.com',
    //   'epw': '1234',

    //   'ename': '김상준',
    //   'ephone': '010-3333-3333',
    //   'erank': 1,
    //   'erole': 1,
    //   'epower': 100,
    //   'workplace': 1001,
    //   'ebid': 1001
    // },
  ];

  // 5. 공급업체 (supplier) 예시 데이터 (임의의 데이터)
  static final List<Map<String, dynamic>> suppliers = [
    // {'sid': 1, 'sname': '나이키 코리아'},
    // {'sid': 2, 'sname': '아디다스 코리아'},
  ];

  // (purchase, refund, approval, orders 데이터는 비워둡니다.)
  static final List<Map<String, dynamic>> purchases = [];
  static final List<Map<String, dynamic>> refunds = [];
  static final List<Map<String, dynamic>> approvals = [];
  static final List<Map<String, dynamic>> orders = [];


  // 요청 조건에 따라 260개의 상품 옵션을 생성하는 함수
  static List<Map<String, dynamic>> _generateGoodsData() {
    final List<Map<String, dynamic>> list = [];
    const int gSumAmount = 100; 

    // 1. 변동값 (사이즈 및 색상)
    final List<String> sizes = [
      '240', '250', '260', '270', '280', '290'
    ]; // 총 6개
    final List<String> colors = ['흰색', '검정색', '시그니쳐 색상', '회색']; // 총 4개

    // 2. 고정값 (5가지 상품 정보와 이미지)
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

    // 3. 옵션 조합 생성 (총 5 * 13 * 4 = 260개)
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
            // SeedData에서 이미지 파일을 로드하기 위한 경로 정보
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
}