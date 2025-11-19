// lib/views/fee_collection/add_fee_dialog.dart
import 'package:flutter/material.dart';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/utils/snackbar_utils.dart';

class AddFeeDialog extends StatefulWidget {
  final String registrationNumber;
  final String studentName;
  final double totalFee;
  final double paidFee;
  final double pendingFee;
  final VoidCallback onFeeAdded;

  const AddFeeDialog({
    super.key,
    required this.registrationNumber,
    required this.studentName,
    required this.totalFee,
    required this.paidFee,
    required this.pendingFee,
    required this.onFeeAdded,
  });

  @override
  State<AddFeeDialog> createState() => _AddFeeDialogState();
}

class _AddFeeDialogState extends State<AddFeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  String _selectedPaymentMode = 'cash';
  bool _isSubmitting = false;

  final List<String> _paymentModes = [
    'cash',
    'online',
    'cheque',
    'card',
    'upi',
  ];

  Map<String, String> _paymentModeLabels = {
    'cash': 'Cash',
    'online': 'Online Transfer',
    'cheque': 'Cheque',
    'card': 'Credit/Debit Card',
    'upi': 'UPI Payment',
  };

  @override
  void initState() {
    super.initState();
    // Set maximum payable amount as placeholder
    _amountController.text = widget.pendingFee.toStringAsFixed(0);
  }

  Future<void> _submitFeePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;

      if (amount > widget.pendingFee) {
         CustomSnackBar.showError(context: context, message: "Amount cannot exceed pending fee: ₹${widget.pendingFee}");
           
        setState(() => _isSubmitting = false);
        return;
      }

      if (amount <= 0) {
       CustomSnackBar.showWarning(context: context, message: "Please Enter Valid Amount");
           
        setState(() => _isSubmitting = false);
        return;
      }

      await ApiService.addFeePayment(
        registrationNumber: widget.registrationNumber,
        amount: amount,
        paymentMode: _selectedPaymentMode,
        transactionId: _transactionIdController.text.isEmpty
            ? null
            : _transactionIdController.text,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
      );

      // Success
      Navigator.pop(context);
      widget.onFeeAdded();
    } catch (e) {
      CustomSnackBar.showError(context: context, message: "Failed to add fee");
           
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 32,
                    color: Color(0xFF282C5C),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Fee Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF282C5C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.studentName,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Reg: ${widget.registrationNumber}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Fee Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeeStat(
                      'Total',
                      '₹${widget.totalFee.toStringAsFixed(0)}',
                      Colors.blue,
                    ),
                    _buildFeeStat(
                      'Paid',
                      '₹${widget.paidFee.toStringAsFixed(0)}',
                      Colors.green,
                    ),
                    _buildFeeStat(
                      'Pending',
                      '₹${widget.pendingFee.toStringAsFixed(0)}',
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter valid amount';
                        }
                        if (amount > widget.pendingFee) {
                          return 'Amount cannot exceed pending fee';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Payment Mode
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMode,
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                        prefixIcon: Icon(Icons.payment),
                        border: OutlineInputBorder(),
                      ),
                      items: _paymentModes.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(_paymentModeLabels[mode] ?? mode),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMode = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select payment mode';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Transaction ID (optional)
                    TextFormField(
                      controller: _transactionIdController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction ID (Optional)',
                        prefixIcon: Icon(Icons.receipt),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remark (optional)
                    TextFormField(
                      controller: _remarkController,
                      decoration: const InputDecoration(
                        labelText: 'Remark (Optional)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitFeePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF282C5C),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Add Payment',style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
