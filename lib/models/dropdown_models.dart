// lib/techcadd/models/dropdown_models.dart
class DropdownChoice {
  final String value;
  final String label;

  DropdownChoice({required this.value, required this.label});

  factory DropdownChoice.fromList(List<dynamic> list) {
    return DropdownChoice(
      value: list[0].toString(),
      label: list[1].toString(),
    );
  }
}

class StaffOption {
  final int id;
  final String name;

  StaffOption({required this.id, required this.name});

  factory StaffOption.fromJson(Map<String, dynamic> json) {
    return StaffOption(
      id: json['id'],
      name: json['name'],
    );
  }
}

class DropdownChoices {
  final List<DropdownChoice> centreChoices;
  final List<DropdownChoice> tradeChoices;
  final List<DropdownChoice> enquirySourceChoices;
  final List<DropdownChoice> enquiryStatusChoices;
  final List<StaffOption> staffOptions;

  DropdownChoices({
    required this.centreChoices,
    required this.tradeChoices,
    required this.enquirySourceChoices,
    required this.enquiryStatusChoices,
    required this.staffOptions,
  });

  factory DropdownChoices.fromJson(Map<String, dynamic> json) {
    return DropdownChoices(
      centreChoices: (json['centre_choices'] as List<dynamic>)
          .map((item) => DropdownChoice.fromList(item))
          .toList(),
      tradeChoices: (json['trade_choices'] as List<dynamic>)
          .map((item) => DropdownChoice.fromList(item))
          .toList(),
      enquirySourceChoices: (json['enquiry_source_choices'] as List<dynamic>)
          .map((item) => DropdownChoice.fromList(item))
          .toList(),
      enquiryStatusChoices: (json['enquiry_status_choices'] as List<dynamic>)
          .map((item) => DropdownChoice.fromList(item))
          .toList(),
      staffOptions: (json['staff_options'] as List<dynamic>)
          .map((item) => StaffOption.fromJson(item))
          .toList(),
    );
  }
}