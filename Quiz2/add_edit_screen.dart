import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studentapp/db/database_helper.dart';
import 'package:studentapp/models/person.dart';

class AddEditScreen extends StatefulWidget {
  final Person? person;

  const AddEditScreen({super.key, this.person});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late int _age;
  File? _image;

  @override
  void initState() {
    super.initState();
    _name = widget.person?.name ?? '';
    _email = widget.person?.email ?? '';
    _age = widget.person?.age ?? 0;
    if (widget.person?.image != null) {
      _image = File(widget.person!.image!);
    }
  }

  Future<void> _pickImage() async {
    final photosStatus = await Permission.photos.request();

    if (photosStatus.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      // Handle the case when permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photos permission is required to select an image.')),
      );
    }
  }

  void _savePerson() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? imagePath;
      if (_image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_image!.path);
        final savedImage = await _image!.copy('${appDir.path}/$fileName');
        imagePath = savedImage.path;
      }

      final person = Person(
        id: widget.person?.id,
        name: _name,
        email: _email,
        age: _age,
        image: imagePath,
      );

      final navigator = Navigator.of(context);

      if (widget.person == null) {
        await DatabaseHelper.instance.insert(person);
      } else {
        await DatabaseHelper.instance.update(person);
      }
      
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_image != null)
                Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
                onSaved: (value) => _age = int.parse(value!),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _savePerson,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
