class Purchase {     // 주문
  int? pseq;         // 주문번호 (PK, AI)
  int pstatus;       // 주문상태 (1: 주문 요청(결제 미완료), 2: 결제 완료(승인 대기), 3: 승인 완료(물건 전달 중), 4: 물건 수령 완료)
  String pdate;      // 주문일자
  int pamount;       // 주문수량
  String ppaydate;   // 결제일자
  double ppayprice;  // 결제가격
  int ppayway;       // 결제수단 (1: 간편결제, 2: 카드결제, 3: 현장결제)
  int ppayamount;    // 결제수량
  double pdiscount;  // 할인율(%) - 0~100
  String userid;     // 사용자 식별자(Customer.cemail)
  int? gseq;         // 상품번호(Goods.gseq)
  String? gsize;     // 선택사이즈
  String? gcolor;    // 선택색상

  Purchase({
    this.pseq,
    required this.pstatus,
    required this.pdate,
    required this.pamount,
    required this.ppaydate,
    required this.ppayprice,
    required this.ppayway,
    required this.ppayamount,
    required this.pdiscount,
    required this.userid,
    this.gseq,
    this.gsize,
    this.gcolor,
  });

  factory Purchase.fromMap(Map<String, dynamic> res) => Purchase(
        pseq: res['pseq'] as int?,
        pstatus: (res['pstatus'] as int?) ?? 0,
        pdate: (res['pdate'] as String?) ?? '',
        pamount: (res['pamount'] as int?) ?? 0,
        ppaydate: (res['ppaydate'] as String?) ?? '',
        ppayprice: (res['ppayprice'] as num?)?.toDouble() ?? 0.0,
        ppayway: (res['ppayway'] as int?) ?? 0,
        ppayamount: (res['ppayamount'] as int?) ?? 0,
        pdiscount: (res['pdiscount'] as num?)?.toDouble() ?? 0.0,
        userid: (res['userid'] as String?) ?? '',
        gseq: res['gseq'] as int?,
        gsize: res['gsize'] as String?,
        gcolor: res['gcolor'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'pseq': pseq,
        'pstatus': pstatus,
        'pdate': pdate,
        'pamount': pamount,
        'ppaydate': ppaydate,
        'ppayprice': ppayprice,
        'ppayway': ppayway,
        'ppayamount': ppayamount,
        'pdiscount': pdiscount,
        'userid': userid,
        'gseq': gseq,
        'gsize': gsize,
        'gcolor': gcolor,
      };
}