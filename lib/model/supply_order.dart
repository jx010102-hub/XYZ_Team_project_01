class SupplyOrder {     // 결재/발주/상품/요청자 정보
  int? oseq;            // 발주번호(Orders.oseq)
  String manufacturer;  // 제조사
  String requester;     // 요청자
  int gseq;             // 상품번호(Goods.gseq)
  String gname;         // 상품명
  String gsize;         // 사이즈
  String gcolor;        // 색상
  int qty;              // 요청수량
  int status;           // 상태 (0: 대기, 1: 승인, 2: 거절)
  String reqdate;       // 요청일자
  String? apprdate;     // 승인일자

  SupplyOrder({
    this.oseq,
    required this.manufacturer,
    required this.requester,
    required this.gseq,
    required this.gname,
    required this.gsize,
    required this.gcolor,
    required this.qty,
    this.status = 0,
    required this.reqdate,
    this.apprdate,
  });

  factory SupplyOrder.fromMap(Map<String, dynamic> res) => SupplyOrder(
        oseq: res['oseq'] as int?,
        manufacturer: (res['manufacturer'] as String?) ?? '',
        requester: (res['requester'] as String?) ?? '',
        gseq: (res['gseq'] as int?) ?? 0,
        gname: (res['gname'] as String?) ?? '',
        gsize: (res['gsize'] as String?) ?? '',
        gcolor: (res['gcolor'] as String?) ?? '',
        qty: (res['qty'] as int?) ?? 0,
        status: (res['status'] as int?) ?? 0,
        reqdate: (res['reqdate'] as String?) ?? '',
        apprdate: res['apprdate'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'oseq': oseq,
        'manufacturer': manufacturer,
        'requester': requester,
        'gseq': gseq,
        'gname': gname,
        'gsize': gsize,
        'gcolor': gcolor,
        'qty': qty,
        'status': status,
        'reqdate': reqdate,
        'apprdate': apprdate,
      };
}