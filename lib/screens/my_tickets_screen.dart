import 'package:flutter/material.dart';
import 'contact_us_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
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
          'My tickets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: globalTickets.length,
        itemBuilder: (context, i) {
          // Iterate in reverse: globalTickets.length - 1 - i
          int index = globalTickets.length - 1 - i;
          final ticket = globalTickets[index];
          
          if (ticket.isEmpty) return const SizedBox.shrink();

          // Find the latest user message
          Map<String, dynamic>? latestMessage;
          for (var msg in ticket.reversed) {
            if (msg['sender'] == 'user') {
              latestMessage = msg;
              break;
            }
          }

          String subtitle = 'Sent an attachment';
          if (latestMessage != null) {
            if (latestMessage['type'] == 'text') {
              subtitle = latestMessage['text'];
            } else if (latestMessage['type'] == 'document') subtitle = 'Document: ${latestMessage['name']}';
            else if (latestMessage['type'] == 'image') subtitle = 'Photo${latestMessage['caption'] != null ? ': ${latestMessage['caption']}' : ''}';
          }

          return _buildTicketItem(
            avatar: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: 'Ticket #${index + 1}',
            subtitle: subtitle,
            time: 'Just now',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsScreen(ticketIndex: index)),
              ).then((_) => setState(() {}));
            },
            onDelete: () {
              setState(() {
                globalTickets.removeAt(index);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactUsScreen()),
          ).then((_) => setState(() {}));
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
    );
  }

  Widget _buildTicketItem({
    required Widget avatar,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: avatar,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          onTap: onTap,
        ),
        const Divider(color: Colors.white12, height: 1),
      ],
    );
  }
}
