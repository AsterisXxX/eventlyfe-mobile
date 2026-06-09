import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/event_model.dart';

class EditEventPage extends StatefulWidget {
  final Event event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController titleController;
  late TextEditingController priceController;

  File? imageFile;
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    priceController =
        TextEditingController(text: widget.event.price.toString());
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String> uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('events/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> updateEvent() async {
    final title = titleController.text.trim();
    final price = int.tryParse(priceController.text.trim()) ?? 0;

    if (title.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tidak valid')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String imageUrl = widget.event.image;

      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile!);
      }

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({
        'title': title,
        'price': price,
        'image': imageUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event berhasil diupdate')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteEvent() async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .delete();

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Nama Event'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                color: Colors.grey[800],
                child: imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover)
                    : widget.event.image.isNotEmpty
                        ? Image.network(widget.event.image, fit: BoxFit.cover)
                        : const Center(child: Text('Pilih Gambar')),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : updateEvent,
              child: const Text('Update Event'),
            ),

            const SizedBox(height: 10),

            // 🔴 DELETE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: deleteEvent,
              child: const Text('Hapus Event'),
            ),
          ],
        ),
      ),
    );
  }
}