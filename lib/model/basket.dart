class Basket {
  final int? bseq;
  final String userid;
  final String gname;
  final String gsize;
  final String gcolor;
  final int qty;
  final String createdAt;

  Basket({
    this.bseq,
    required this.userid,
    required this.gname,
    required this.gsize,
    required this.gcolor,
    required this.qty,
    required this.createdAt,
  });

  factory Basket.fromMap(Map<String, dynamic> map) {
    return Basket(
      bseq: map['bseq'] as int?,
      userid: map['userid'] as String,
      gname: map['gname'] as String,
      gsize: map['gsize'] as String,
      gcolor: map['gcolor'] as String,
      qty: (map['qty'] as int?) ?? 1,
      createdAt: (map['createdAt'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bseq': bseq,
      'userid': userid,
      'gname': gname,
      'gsize': gsize,
      'gcolor': gcolor,
      'qty': qty,
      'createdAt': createdAt,
    };
  }
}
