// // lib/views/student/payment_history_screen.dart
// import 'package:flutter/material.dart';
// import 'package:techcadd/api/api_service.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'dart:io';
// import 'dart:typed_data';

// class PaymentHistoryScreen extends StatefulWidget {
//   const PaymentHistoryScreen({super.key});

//   @override
//   State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
// }

// class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
//   Map<String, dynamic>? _paymentData;
//   bool _isLoading = true;
//   bool _isDownloading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadPaymentHistory();
//   }

//   Future<void> _loadPaymentHistory() async {
//     try {
//       setState(() => _isLoading = true);
//       final data = await ApiService.getStudentPaymentHistory();
//       setState(() {
//         _paymentData = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('❌ Error loading payment history: $e');
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load payment history: $e')),
//       );
//     }
//   }

//   Future<void> _downloadReceipt(String receiptNumber) async {
//     try {
//       setState(() => _isDownloading = true);
      
//       final bytes = await ApiService.downloadReceipt(receiptNumber);
      
//       // Save file to device
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$receiptNumber.pdf');
//       await file.writeAsBytes(bytes);
      
//       // Open the file
//       await OpenFile.open(file.path);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Receipt downloaded successfully!')),
//       );
//     } catch (e) {
//       print('❌ Download error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to download receipt: $e')),
//       );
//     } finally {
//       setState(() => _isDownloading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text(
//           'Payment History & Receipts',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         backgroundColor: const Color(0xFF282C5C),
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _paymentData == null
//               ? const Center(child: Text('No payment data found'))
//               : _buildPaymentHistory(),
//     );
//   }

//   Widget _buildPaymentHistory() {
//     final paymentHistory = _paymentData!['payment_history'] as List<dynamic>? ?? [];
//     final receipts = _paymentData!['receipts'] as List<dynamic>? ?? [];

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Fee Summary Card
//           _buildFeeSummaryCard(),
//           const SizedBox(height: 20),

//           // Payment History
//           const Text(
//             'Payment History',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF282C5C),
//             ),
//           ),
//           const SizedBox(height: 12),

//           if (paymentHistory.isEmpty)
//             const Center(
//               child: Column(
//                 children: [
//                   Icon(Icons.receipt_long, size: 64, color: Colors.grey),
//                   SizedBox(height: 8),
//                   Text(
//                     'No payments found',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           else
//             ...paymentHistory.asMap().entries.map((entry) {
//               final index = entry.key;
//               final payment = entry.value as Map<String, dynamic>;
//               final receipt = receipts[index] as Map<String, dynamic>;
              
//               return _PaymentItem(
//                 payment: payment,
//                 receipt: receipt,
//                 onDownload: () => _downloadReceipt(receipt['receipt_number']),
//                 isDownloading: _isDownloading,
//               );
//             }),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeeSummaryCard() {
//     final totalFee = _paymentData!['total_course_fee'] ?? 0;
//     final paidFee = _paymentData!['total_paid_fee'] ?? 0;
//     final balance = _paymentData!['fee_balance'] ?? 0;
//     final paymentPercentage = totalFee > 0 ? (paidFee / totalFee * 100) : 0;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.credit_card, color: Color(0xFF282C5C)),
//                 SizedBox(width: 8),
//                 Text(
//                   'Fee Summary',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF282C5C),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             // Progress Bar
//             LinearProgressIndicator(
//               value: paymentPercentage / 100,
//               backgroundColor: Colors.grey[300],
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//               minHeight: 8,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${paymentPercentage.toStringAsFixed(1)}% Paid',
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Fee Details
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _FeeDetailItem(
//                   label: 'Total Fee',
//                   value: '₹${totalFee.toStringAsFixed(0)}',
//                   color: Colors.blue,
//                 ),
//                 _FeeDetailItem(
//                   label: 'Paid',
//                   value: '₹${paidFee.toStringAsFixed(0)}',
//                   color: Colors.green,
//                 ),
//                 _FeeDetailItem(
//                   label: 'Balance',
//                   value: '₹${balance.toStringAsFixed(0)}',
//                   color: balance > 0 ? Colors.orange : Colors.green,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PaymentItem extends StatelessWidget {
//   final Map<String, dynamic> payment;
//   final Map<String, dynamic> receipt;
//   final VoidCallback onDownload;
//   final bool isDownloading;

//   const _PaymentItem({
//     required this.payment,
//     required this.receipt,
//     required this.onDownload,
//     required this.isDownloading,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final amount = payment['amount'] ?? 0;
//     final paymentDate = payment['payment_date'] ?? '';
//     final paymentMode = payment['payment_mode_display'] ?? '';
//     final installment = payment['installment_number'] ?? '';
//     final receiptNumber = receipt['receipt_number'];
//     final isReceiptAvailable = receiptNumber != null;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Installment #$installment',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF282C5C),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '₹${amount.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Date: $paymentDate',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             Text(
//               'Mode: $paymentMode',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             if (isReceiptAvailable) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(Icons.receipt, size: 16, color: Colors.green),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Receipt: $receiptNumber',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.green,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   ElevatedButton.icon(
//                     onPressed: isDownloading ? null : onDownload,
//                     icon: isDownloading
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.download, size: 16),
//                     label: const Text('Download'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF282C5C),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _FeeDetailItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _FeeDetailItem({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }