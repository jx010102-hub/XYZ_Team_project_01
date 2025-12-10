class Order {       // 발주 (+수주)
    
  int? oseq;        // 발주번호 (AI)
  int ostatus;      // 발주상태 (1: 발주 요청, 결재 대기(Approval에서), 2: 결재 완료 후 제조사 확인 대기, 3: 제조사 확인, 수주 완료)
  String odate;     // 발주일자
  int oamount;      // 발주수량

  Order(
    {
      this.oseq,
      required this.ostatus,
      required this.odate,
      required this.oamount,
    }
  );

  Order.fromMap(Map<String, dynamic> res)
  : oseq = res['oseq'],
    ostatus = res['ostatus'],
    odate = res['odate'],
    oamount = res['oamount'];

}