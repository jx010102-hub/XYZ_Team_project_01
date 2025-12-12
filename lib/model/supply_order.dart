class SupplyOrder {
  int? oseq;
  String manufacturer;
  String requester;
  int gseq;
  String gname;
  String gsize;
  String gcolor;
  int qty;
  int status; // 0:대기 1:승인 2:거절
  String reqdate;
  String? apprdate;

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

  SupplyOrder.fromMap(Map<String, dynamic> res)
      : oseq = res['oseq'] as int?,
        manufacturer = (res['manufacturer'] as String?) ?? '',
        requester = (res['requester'] as String?) ?? '',
        gseq = (res['gseq'] as int?) ?? 0,
        gname = (res['gname'] as String?) ?? '',
        gsize = (res['gsize'] as String?) ?? '',
        gcolor = (res['gcolor'] as String?) ?? '',
        qty = (res['qty'] as int?) ?? 0,
        status = (res['status'] as int?) ?? 0,
        reqdate = (res['reqdate'] as String?) ?? '',
        apprdate = res['apprdate'] as String?;
}
