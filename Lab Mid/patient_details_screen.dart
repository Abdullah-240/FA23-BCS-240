import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import 'add_patient_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Open AddPatientScreen in edit mode
              final updated = await Navigator.push<bool?>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddPatientScreen(patient: widget.patient),
                ),
              );

              // If the edit screen returned true (success), reload or pop
              if (updated == true) {
                // Reload patients in provider
                await context.read<DatabaseService>().loadPatients();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Personal Information', [
              _buildInfoRow('Name', widget.patient.name),
              if (widget.patient.dateOfBirth.isNotEmpty)
                _buildInfoRow('Date of Birth', widget.patient.dateOfBirth),
              if (widget.patient.phoneNumber.isNotEmpty)
                _buildInfoRow('Phone', widget.patient.phoneNumber),
              if (widget.patient.email.isNotEmpty)
                _buildInfoRow('Email', widget.patient.email),
              if (widget.patient.address.isNotEmpty)
                _buildInfoRow('Address', widget.patient.address),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Medical Information', [
              if (widget.patient.medicalHistory.isNotEmpty)
                _buildInfoRow('Medical History', widget.patient.medicalHistory),
              if (widget.patient.allergies.isNotEmpty)
                _buildInfoRow('Allergies', widget.patient.allergies),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Record Information', [
              _buildInfoRow('Created', _formatDate(widget.patient.createdAt)),
              _buildInfoRow('Patient ID', widget.patient.id.toString()),
            ]),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement add visit record
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add visit record coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Visit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement view records
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('View records coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Records'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Patient'),
          content: Text(
            'Are you sure you want to delete ${widget.patient.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await context
                    .read<DatabaseService>()
                    .deletePatient(widget.patient.id);
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Patient deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete patient'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
