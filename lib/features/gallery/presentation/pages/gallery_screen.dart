import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';
import 'package:open_filex/open_filex.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
    GallerySaverHelper.shouldReloadGallery.addListener(_loadImages);
  }

  @override
  void dispose() {
    GallerySaverHelper.shouldReloadGallery.removeListener(_loadImages);
    super.dispose();
  }

  Future<void> _loadImages() async {
    setState(() => _loading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final imageFiles = files
          .where(
            (file) =>
                file is File &&
                (file.path.endsWith('.jpg') ||
                    file.path.endsWith('.png') ||
                    file.path.endsWith('.jpeg') ||
                    file.path.endsWith('.pdf') ||
                    file.path.endsWith('.svg')),
          )
          .map((file) => File(file.path))
          .toList();

      imageFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      setState(() {
        _images = imageFiles;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading images: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text(
          'My Work',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No saved work yet",
                    style: GoogleFonts.outfit(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadImages,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final file = _images[index];
                  final path = file.path.toLowerCase();
                  final isPdf = path.endsWith('.pdf');
                  final isSvg = path.endsWith('.svg');
                  final isImage = !isPdf && !isSvg;

                  return GestureDetector(
                    onTap: () {
                      if (isImage) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FullScreenImage(file: file),
                          ),
                        );
                      } else {
                        _showFileDetails(context, file);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        image: isImage
                            ? DecorationImage(
                                image: FileImage(file),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: !isImage
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isPdf
                                      ? Icons.picture_as_pdf
                                      : Icons
                                            .image_aspect_ratio, // SVG icon proxy
                                  size: 40,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    file.path.split('/').last,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showFileDetails(BuildContext context, File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              file.path.split('/').last,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      // Copy to cache dir for FileProvider access
                      final tempDir = await getTemporaryDirectory();
                      final fileName = file.path.split('/').last;
                      final tempFile = File('${tempDir.path}/$fileName');
                      await file.copy(tempFile.path);

                      final result = await OpenFilex.open(tempFile.path);
                      if (result.type != ResultType.done) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Could not open file: ${result.message}',
                              ),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error opening file: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open"),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Share.shareXFiles([XFile(file.path)]);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text("Share"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final File file;

  const _FullScreenImage({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: InteractiveViewer(child: Image.file(file))),
    );
  }
}
