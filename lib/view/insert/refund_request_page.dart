import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/refund_database.dart';

class RefundRequestPage extends StatefulWidget {
  final int pseq;
  final String goodsName;
  final String optionText;

  const RefundRequestPage({
    super.key,
    required this.pseq,
    required this.goodsName,
    required this.optionText,
  });

  @override
  State<RefundRequestPage> createState() => _RefundRequestPageState();
}

class _RefundRequestPageState extends State<RefundRequestPage> {
  final RefundDatabase _refundDB = RefundDatabase();
  final Message _message = const Message();

  late final TextEditingController _reasonController;
  bool _isSubmitting = false;

  void _info(String t, String m) => _message.info(t, m);
  void _error(String t, String m) => _message.error(t, m);
  void _success(String t, String m) => _message.success(t, m);

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ✅ 즉시 닫기 버전: 결과 상관없이 무조건 pop
  void _submitAndCloseNow() {
    if (_isSubmitting) return;

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      _info('알림', '반품 사유를 입력해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    Navigator.of(context).pop(true);
    
    Future<void>(() async {
      try {
        final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final newRefund = Refund(
          rdate: nowStr,
          rreason: reason,
          rstatus: 1,
          rpseq: widget.pseq,
        );

        final id = await _refundDB.insertRefund(newRefund);
        if (id > 0) {
          _success('완료', '반품 요청이 등록되었습니다.');
        } else {
          _error('실패', '반품 요청 등록 실패');
        }
      } catch (e) {
        debugPrint('RefundRequestPage background insert error: $e');
        _error('오류', '반품 요청 중 오류 발생');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          '반품 요청',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.goodsName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                widget.optionText,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _reasonController,
                  enabled: !_isSubmitting,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '반품 사유를 입력해 주세요.\n예) 사이즈가 맞지 않음',
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAndCloseNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('요청하기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
