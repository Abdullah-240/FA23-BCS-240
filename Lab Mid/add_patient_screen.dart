import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/patient.dart';

class AddPatientScreen extends StatefulWidget {
  final Patient? patient; // if provided, screen works as edit

  const AddPatientScreen({super.key, this.patient});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      final p = widget.patient!;
      _nameController.text = p.name;
      _dateOfBirthController.text = p.dateOfBirth;
      _phoneController.text = p.phoneNumber;
      _emailController.text = p.email;
      _addressController.text = p.address;
      _medicalHistoryController.text = p.medicalHistory;
      _allergiesController.text = p.allergies;
    }
  }

  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Patient'),
        actions: [
          TextButton(
            onPressed: _savePatient,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Personal Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _dateOfBirthController,
                label: 'Date of Birth (YYYY-MM-DD)',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Medical Information'),
              _buildTextField(
                controller: _medicalHistoryController,
                label: 'Medical History',
                icon: Icons.medical_services,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                icon: Icons.warning,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              Consumer<DatabaseService>(
                builder: (context, databaseService, child) {
                  return ElevatedButton(
                    onPressed: databaseService.isLoading ? null : _savePatient,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: databaseService.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Patient Record'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.patient != null;

      final patient = Patient(
        id: isEditing
            ? widget.patient!.id
            : DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        medicalHistory: _medicalHistoryController.text.trim(),
        allergies: _allergiesController.text.trim(),
        createdAt: isEditing ? widget.patient!.createdAt : DateTime.now(),
      );

      final success = isEditing
          ? await context.read<DatabaseService>().updatePatient(patient)
          : await context.read<DatabaseService>().addPatient(patient);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient record saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save patient record'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
