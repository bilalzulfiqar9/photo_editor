import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = dir.listSync();
    final List<File> files = entities
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'),
        )
        .toList();

    // Sort by modification time descending
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
    _loadFiles();
  }

  Future<void> _shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Creations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
          ? const Center(child: Text('No images saved yet'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    trailing: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, size: 20),
                          onPressed: () => _shareFile(file),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteFile(file),
                        ),
                      ],
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Open full screen viewer (using standard dialog for now)
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: InteractiveViewer(child: Image.file(file)),
                        ),
                      );
                    },
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                );
              },
            ),
    );
  }
}
