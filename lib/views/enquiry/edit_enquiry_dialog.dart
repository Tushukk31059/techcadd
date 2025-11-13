import 'package:flutter/material.dart';

import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/dropdown_models.dart';

class EditEnquiryDialog extends StatefulWidget {
  final Map<String, dynamic> enquiry;
  final DropdownChoices dropdownChoices;
  final VoidCallback onEnquiryUpdated;

  const EditEnquiryDialog({
    super.key,
    required this.enquiry,
    required this.dropdownChoices,
    required this.onEnquiryUpdated,
  });

  @override
  State<EditEnquiryDialog> createState() => _EditEnquiryDialogState();
}

class _EditEnquiryDialogState extends State<EditEnquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _nextFollowUpController = TextEditingController();
  final TextEditingController _courseFeeController = TextEditingController();

  String? _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill current values
    _selectedStatus = widget.enquiry['enquiry_status']?.toString();
    _remarkController.text = widget.enquiry['remark']?.toString() ?? '';
    _nextFollowUpController.text =
        widget.enquiry['next_follow_up_date']?.toString() ?? '';
    _courseFeeController.text =
        widget.enquiry['course_fee_offer']?.toString() ?? '';
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF282C5C),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
    }
  }

  Future<void> _updateEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final updateData = {
        'enquiry_status': _selectedStatus ?? 'registration_done',
        'remark': _remarkController.text.isEmpty ? "" : _remarkController.text,
        'next_follow_up_date': _nextFollowUpController.text.isEmpty
            ? ""
            : _nextFollowUpController.text,
      };

      // Add course fee only if provided
      if (_courseFeeController.text.isNotEmpty) {
        final fee = double.tryParse(_courseFeeController.text);
        if (fee != null) {
          updateData['course_fee_offer'] = fee as String;
        }
      }

      print('✏️ Updating enquiry with data: $updateData');

      final enquiryId = widget.enquiry['id'] as int;
      await ApiService.updateEnquiry(enquiryId, updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enquiry updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onEnquiryUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update enquiry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.enquiry['student_name']?.toString() ?? 'Unknown';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFF282C5C), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Update Enquiry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Student: $studentName',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Status Dropdown - Default to "Registration Done"
              DropdownButtonFormField<String>(
                value: _selectedStatus ?? 'registration_done',
                decoration: const InputDecoration(
                  labelText: 'Enquiry Status *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timeline, color: Color(0xFF282C5C)),
                ),
                items: widget.dropdownChoices.enquiryStatusChoices.map((
                  choice,
                ) {
                  return DropdownMenuItem(
                    value: choice.value,
                    child: Text(choice.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value),
                validator: (value) =>
                    value == null ? 'Please select status' : null,
              ),
              const SizedBox(height: 12),

              // Course Fee Field
              TextFormField(
                controller: _courseFeeController,
                decoration: const InputDecoration(
                  labelText: 'Course Fee Offer (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: Color(0xFF282C5C),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Remark Field
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note, color: Color(0xFF282C5C)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Next Follow Up Date Field
              TextFormField(
                controller: _nextFollowUpController,
                readOnly: true,
                onTap: () => _selectDate(_nextFollowUpController),
                decoration: const InputDecoration(
                  labelText: 'Next Follow Up Date (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: Color(0xFF282C5C),
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF282C5C),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _updateEnquiry,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 18,color: Colors.white,),
                                SizedBox(width: 6),
                                Text('Update',style: TextStyle(color: Colors.white),),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _nextFollowUpController.dispose();
    _courseFeeController.dispose();
    super.dispose();
  }
}
