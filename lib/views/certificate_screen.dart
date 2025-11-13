// lib/techcadd/screens/certificate_screen.dart
import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Certificates List',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF282C5C)),
          ),
        ),

        // Search and Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by Student Name...',
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF282C5C)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Reg. No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement issue new certificate
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Issue New Certificate - Coming Soon!')),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Issue New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Certificates List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: const [
              _CertificateListItem(
                regNo: 'TCD/4001/3805',
                name: 'Himanshi',
                course: 'Computer Typing',
                email: 'himanshi@example.com',
              ),
              _CertificateListItem(
                regNo: 'TCD/4001/2857',
                name: 'Parminder Singh',
                course: 'Graphic Designing',
                email: 'parminder@example.com',
              ),
              _CertificateListItem(
                regNo: 'TCD/4001/2858',
                name: 'Rahul Sharma',
                course: 'Web Development',
                email: 'rahul@example.com',
              ),
              _CertificateListItem(
                regNo: 'TCD/4001/2859',
                name: 'Priya Verma',
                course: 'Digital Marketing',
                email: 'priya@example.com',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Certificate List Item Widget
class _CertificateListItem extends StatelessWidget {
  final String regNo;
  final String name;
  final String course;
  final String email;

  const _CertificateListItem({
    required this.regNo,
    required this.name,
    required this.course,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const Icon(Icons.badge, color: Color(0xFF282C5C), size: 32),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF282C5C))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reg No: $regNo | Course: $course', style: const TextStyle(fontSize: 13)),
            Text('Email: $email', style: const TextStyle(fontSize: 13)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Color(0xFF3B82F6)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading certificate for $name')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete certificate for $name?')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}