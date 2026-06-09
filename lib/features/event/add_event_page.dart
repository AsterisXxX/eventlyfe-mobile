import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
 State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();

  File? imageFile;
  bool isLoading = false;

  final picker = ImagePicker();

  // 📸 PILIH GAMBAR
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // ☁️ UPLOAD IMAGE (FIREBASE STORAGE)
  Future<String> uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('events/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  // 💾 SAVE EVENT (FINAL FIXED)
  Future<void> saveEvent() async {
    final title = titleController.text.trim();
    final price = int.tryParse(priceController.text.trim()) ?? 0;

    // 🔐 VALIDASI
    if (title.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama event dan harga wajib diisi'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String imageUrl = '';

      // 🖼️ OPTIONAL IMAGE
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile!);
      }

      // 💾 SIMPAN KE FIRESTORE
      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'price': price,
        'image': imageUrl, // bisa kosong
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event berhasil ditambahkan'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📧 TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Nama Event'),
            ),

            const SizedBox(height: 10),

            // 💰 PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),

            const SizedBox(height: 20),

            // 🖼️ IMAGE PICKER (OPTIONAL)
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Center(
                        child: Text('Pilih Gambar (Opsional)'),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔘 BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveEvent,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}