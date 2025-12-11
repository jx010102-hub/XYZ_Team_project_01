class Purchase {    // 주문

  int? pseq;        // 주문번호 (AI)
  int pstatus;      // 주문상태 (1: 주문 요청, 결제 미완료, 2: 결제 완료, 승인 대기, 3: 승인 완료, 물건 전달 중 4: 물건 수령 완료)
  String pdate;     // 주문일자
  int pamount;      // 주문수량
  String ppaydate;  // 결제일자
  double ppayprice; // 결제가격
  int ppayway;      // 결제수단 (1: 간편결제, 2: 카드결제, 3: 현장결제)
  int ppayamount;   // 결제수량
  double pdiscount; // 할인 (%)
  String userid;

  Purchase(
    {
      this.pseq,
      required this.pstatus,
      required this.pdate,
      required this.pamount,
      required this.ppaydate,
      required this.ppayprice,
      required this.ppayway,
      required this.ppayamount,
      required this.pdiscount,
      required this.userid
    }
  );

  Purchase.fromMap(Map<String, dynamic> res)
  : pseq = res['pseq'],
    pstatus = res['pstatus'],
    pdate = res['pdate'],
    pamount = res['pamount'],
    ppaydate = res['ppaydate'],
    ppayprice = res['ppayprice'],
    ppayway = res['ppayway'],
    ppayamount = res['ppayamount'],
    pdiscount = res['pdiscount'],
    userid = res['userid'];

}