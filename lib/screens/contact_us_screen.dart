import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'custom_camera_screen.dart';
import 'file_preview_screen.dart';

class ContactUsScreen extends StatefulWidget {
  final int? ticketIndex;
  const ContactUsScreen({super.key, this.ticketIndex});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

// Global variable to keep multiple tickets persistent
final List<List<Map<String, dynamic>>> globalTickets = [];

class _ContactUsScreenState extends State<ContactUsScreen> {
  late int _currentIndex;
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.ticketIndex != null && widget.ticketIndex! >= 0 && widget.ticketIndex! < globalTickets.length) {
      _currentIndex = widget.ticketIndex!;
    } else {
      globalTickets.add([]);
      _currentIndex = globalTickets.length - 1;
    }
  }

  List<Map<String, dynamic>> get _messages => globalTickets[_currentIndex];

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final caption = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => FilePreviewScreen(filePath: image.path)),
        );

        if (caption != null) {
          setState(() {
            _messages.add(<String, dynamic>{
              'sender': 'user', 
              'type': 'image', 
              'path': image.path,
              'caption': caption.isNotEmpty ? caption : null,
            });
          });
          
          // Auto-reply message
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _addSystemMessage('Your message has been sent. If a reply is needed, we will contact you shortly.');
            }
          });
        }
      }
    } catch (e) {
      _addSystemMessage('Failed to upload image: $e');
    }
  }

  Future<void> _takeCustomPhoto() async {
    Navigator.pop(context); // Close bottom sheet
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const CustomCameraScreen()),
    );

    if (result != null && result['path'] != null) {
      setState(() {
        _messages.add(<String, dynamic>{
          'sender': 'user', 
          'type': 'image', 
          'path': result['path'],
          'caption': result['caption']?.isNotEmpty == true ? result['caption'] : null,
        });
      });
      
      // Auto-reply message
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _addSystemMessage('Your message has been sent. If a reply is needed, we will contact you shortly.');
        }
      });
    }
  }

  Future<void> _pickDocument() async {
    Navigator.pop(context); // Close bottom sheet
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        final caption = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => FilePreviewScreen(
            filePath: filePath,
            isDocument: true,
            fileName: fileName,
          )),
        );

        if (caption != null) {
          setState(() {
            _messages.add(<String, dynamic>{
              'sender': 'user', 
              'type': 'document', 
              'name': fileName,
              'caption': caption.isNotEmpty ? caption : null,
            });
          });
          
          // Auto-reply message
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _addSystemMessage('Your message has been sent. If a reply is needed, we will contact you shortly.');
            }
          });
        }
      }
    } catch (e) {
      _addSystemMessage('Failed to upload document: $e');
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: _takeCustomPhoto,
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: Color(0xFF4CAF50)),
                title: const Text('Document', style: TextStyle(color: Colors.white)),
                onTap: _pickDocument,
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(<String, dynamic>{'sender': 'user', 'type': 'text', 'text': text});
      _controller.clear();
      // Add auto-reply message
      _messages.add(<String, dynamic>{
        'sender': 'system',
        'type': 'text',
        'text': 'Your message has been sent. If a reply is needed, we will contact you shortly.'
      });
    });
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(<String, dynamic>{'sender': 'system', 'type': 'text', 'text': text});
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message['sender'] == 'user';
    bool isImage = message['type'] == 'image';
    bool isDocument = message['type'] == 'document';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: isImage ? const EdgeInsets.all(4) : const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4CAF50) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
          ),
        ),
        child: isImage
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(message['path']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (message['caption'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                      child: Text(
                        message['caption']!,
                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
                      ),
                    ),
                ],
              )
            : isDocument
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insert_drive_file, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message['name'] ?? 'Document',
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (message['caption'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                          child: Text(
                            message['caption']!,
                            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
                          ),
                        ),
                    ],
                  )
                : Text(
                    message['text']!,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contact us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat history area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          
          // Bottom input area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Attachment Icon
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Color(0xFF4CAF50)),
                      onPressed: _showAttachmentOptions,
                    ),
                    
                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    // Send Icon
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
