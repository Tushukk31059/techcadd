// lib/models/registration_models.dart
class RegistrationOptions {
  final List<CourseType> courseTypes;
  final List<DurationChoice> durationChoices;
  final List<BranchChoice> branchChoices;

  RegistrationOptions({
    required this.courseTypes,
    required this.durationChoices,
    required this.branchChoices,
  });

  factory RegistrationOptions.fromJson(Map<String, dynamic> json) {
    return RegistrationOptions(
      courseTypes: (json['course_types'] as List)
          .map((item) => CourseType.fromJson(item))
          .toList(),
      durationChoices: (json['duration_choices'] as List)
          .map((item) => DurationChoice.fromJson(item))
          .toList(),
      branchChoices: (json['branch_choices'] as List)
          .map((item) => BranchChoice.fromJson(item))
          .toList(),
    );
  }
}

class CourseType {
  final int id;
  final String name;

  CourseType({required this.id, required this.name});

  factory CourseType.fromJson(Map<String, dynamic> json) {
    return CourseType(
      id: json['id'],
      name: json['name'],
    );
  }
}

class DurationChoice {
  final String value;
  final String label;

  DurationChoice({required this.value, required this.label});

  factory DurationChoice.fromJson(Map<String, dynamic> json) {
    return DurationChoice(
      value: json['value'],
      label: json['label'],
    );
  }
}

class BranchChoice {
  final String value;
  final String label;

  BranchChoice({required this.value, required this.label});

  factory BranchChoice.fromJson(List<dynamic> json) {
    return BranchChoice(
      value: json[0],
      label: json[1],
    );
  }
}

class Course {
  final int id;
  final String name;
  final int courseType;
  final String courseTypeName;
  final String softwareCovered;
  final String durationMonths;
  final String durationMonthsDisplay;
  final int durationHours;
  final double courseFee;

  Course({
    required this.id,
    required this.name,
    required this.courseType,
    required this.courseTypeName,
    required this.softwareCovered,
    required this.durationMonths,
    required this.durationMonthsDisplay,
    required this.durationHours,
    required this.courseFee,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      courseType: json['course_type'],
      courseTypeName: json['course_type_name'],
      softwareCovered: json['software_covered'] ?? '',
      durationMonths: json['duration_months'],
      durationMonthsDisplay: json['duration_months_display'],
      durationHours: json['duration_hours'],
      courseFee: (json['course_fee'] as num).toDouble(),
    );
  }
}

class StudentRegistration {
  final int id;
  final String registrationNumber;
  final String branch;
  final String branchDisplay;
  final String joiningDate;
  final String studentName;
  final String fatherName;
  final String dateOfBirth;
  final String email;
  final String qualification;
  final String workCollege;
  final String contactAddress;
  final String phoneNo;
  final String whatsappNo;
  final String parentsNo;
  final int courseType;
  final String courseTypeName;
  final int course;
  final String courseName;
  final String softwareCovered;
  final String durationMonths;
  final String durationMonthsDisplay;
  final int durationHours;
  final double totalCourseFee;
  final double paidFee;
  final double feeBalance;
  final String? courseCompletionDate;
  final int? daysRemainingToComplete;
  final String courseStatus;
  final int? totalCourseDays;
  final bool certificateIssued;
  final String? certificateNumber;
  final String? certificateIssueDate;
  final bool isEligibleForCertificate;
  final String username;
  final String? password;
  final String createdAt;

  StudentRegistration({
    required this.id,
    required this.registrationNumber,
    required this.branch,
    required this.branchDisplay,
    required this.joiningDate,
    required this.studentName,
    required this.fatherName,
    required this.dateOfBirth,
    required this.email,
    required this.qualification,
    required this.workCollege,
    required this.contactAddress,
    required this.phoneNo,
    required this.whatsappNo,
    required this.parentsNo,
    required this.courseType,
    required this.courseTypeName,
    required this.course,
    required this.courseName,
    required this.softwareCovered,
    required this.durationMonths,
    required this.durationMonthsDisplay,
    required this.durationHours,
    required this.totalCourseFee,
    required this.paidFee,
    required this.feeBalance,
    this.courseCompletionDate,
    this.daysRemainingToComplete,
    required this.courseStatus,
    this.totalCourseDays,
    required this.certificateIssued,
    this.certificateNumber,
    this.certificateIssueDate,
    required this.isEligibleForCertificate,
    required this.username,
    this.password,
    required this.createdAt,
  });

  factory StudentRegistration.fromJson(Map<String, dynamic> json) {
    return StudentRegistration(
      id: json['id'],
      registrationNumber: json['registration_number'],
      branch: json['branch'],
      branchDisplay: json['branch_display'],
      joiningDate: json['joining_date'],
      studentName: json['student_name'],
      fatherName: json['father_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      email: json['email'],
      qualification: json['qualification'] ?? '',
      workCollege: json['work_college'] ?? '',
      contactAddress: json['contact_address'] ?? '',
      phoneNo: json['phone_no'],
      whatsappNo: json['whatsapp_no'] ?? '',
      parentsNo: json['parents_no'] ?? '',
      courseType: json['course_type'],
      courseTypeName: json['course_type_name'],
      course: json['course'],
      courseName: json['course_name'],
      softwareCovered: json['software_covered'] ?? '',
      durationMonths: json['duration_months'],
      durationMonthsDisplay: json['duration_months_display'],
      durationHours: json['duration_hours'],
      totalCourseFee: (json['total_course_fee'] as num).toDouble(),
      paidFee: (json['paid_fee'] as num).toDouble(),
      feeBalance: (json['fee_balance'] as num).toDouble(),
      courseCompletionDate: json['course_completion_date'],
      daysRemainingToComplete: json['days_remaining_to_complete'],
      courseStatus: json['course_status'] ?? 'ongoing',
      totalCourseDays: json['total_course_days'],
      certificateIssued: json['certificate_issued'] ?? false,
      certificateNumber: json['certificate_number'],
      certificateIssueDate: json['certificate_issue_date'],
      isEligibleForCertificate: json['is_eligible_for_certificate'] ?? false,
      username: json['username'],
      password: json['password'],
      createdAt: json['created_at'],
    );
  }
}