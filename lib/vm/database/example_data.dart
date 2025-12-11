class ExampleData {
  // customer
  static final List<Map<String, dynamic>> customers = [
    // {
    //   'cemail': 'test@example.com',
    //   'cpw': '1111',
    //   'cphone': '010-1111-1111',
    //   'cname': '테스트',
    //   'caddress': '서울시 강남구',
    // },
  ];

  // goods
  
  static List<String> makeSizes(int start, int end, int step) {
    List<String> sizes = [];
    for (int size = start; size <= end; size += step) {
      sizes.add(size.toString());
    }
    return sizes;
  }
  static final List<String> shoeSizes = makeSizes(230, 290, 5);

  static final List<Map<String, dynamic>> goods = [
    // ..._makeGoodsVariants(
    //   gname: '신발',
    //   gengname: 'shoes',
    //   gcategory: '카테고리',
    //   gsize: shoeSizes, // makeSizes 함수로 230 부터 5단위로 290까지 자동 입력 중
    //   gcolor: ['White', 'Grey', 'Black', 'Red'],
    //   gsumamount: 50,
    // ),
  ];

  static List<Map<String, dynamic>> _makeGoodsVariants({
    required String gname,
    required String gengname,
    required String gcategory,
    required List<String> gsize,
    required List<String> gcolor,
    required int gsumamount,
  }) {
    final List<Map<String, dynamic>> result = [];

    // 각 이미지 파일 경로
    const mainPath = 'images/파일이름.png';
    const topPath  = 'images/파일이름.png';
    const backPath = 'images/파일이름.png';
    const sidePath = 'images/파일이름.png';

    for (final size in gsize) {
      for (final color in gcolor) {
        result.add({
          'gsumamount': gsumamount,
          'gname': gname,
          'gengname': gengname,
          'gsize': size,
          'gcolor': color,
          'gcategory': gcategory,
          'mainimagePath': mainPath,
          'topimagePath': topPath,
          'backimagePath': backPath,
          'sideimagePath': sidePath,
        });
      }
    }
    return result;
  }

  // 3) branch
  static final List<Map<String, dynamic>> branches = [
    // {
    //   'bid': 1,
    //   'blat': 37.5665,
    //   'blng': 126.9780,
    //   'bname': '서울본점',
    // },
  ];

  // 4) employee
  static final List<Map<String, dynamic>> employees = [
    // {
    //   'eemail': 'xyz@example.com',
    //   'epw': '1234',
    //   'ephone': '010-3333-3333',
    //   'erank': 1,
    //   'erole': 1,
    //   'epower': 1,
    //   'workplace': 1,
    //   'ebid': 1,
    // },
  ];

  // 5) supplier
  static final List<Map<String, dynamic>> suppliers = [
    // {
    //   'sid': 1,
    //   'sname': '제조사A'
    // },
  ];

  // 6) purchase
  static final List<Map<String, dynamic>> purchases = [
    // {
    //   'pstatus': 1,
    //   'pdate': '2025-01-01',
    //   'pamount': 10,
    //   'ppaydate': '2025-01-02',
    //   'ppayprice': 100000,
    //   'ppayway': 0,
    //   'ppayamount': 100000,
    //   'pdiscount': 0,
    // },
  ];

  // 7) refund
  static final List<Map<String, dynamic>> refunds = [
    // {
    //   'rdate': '2025-01-10',
    //   'rreason': '불량',
    //   'rstatus': 0,
    //   'rpseq': 1,
    // },
  ];

  // 8) approval
  static final List<Map<String, dynamic>> approvals = [
    // {
    //   'astatus': 0,
    //   'adate': '2025-01-05',
    //   'aoseq': 1,
    // },
  ];

  // 9) orders
  static final List<Map<String, dynamic>> orders = [
    // {
    //   'ostatus': 0,
    //   'odate': '2025-01-01',
    //   'oamount': 3,
    // },
  ];
}
