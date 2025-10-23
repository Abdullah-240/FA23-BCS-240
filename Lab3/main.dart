import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F6FB),
        fontFamily: 'Roboto',
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body is centered narrow column similar to phone screen
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              children: [
                const SizedBox(height: 36),

                // top colored small action dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _TopDot(color: Color(0xFFEF4444)),
                    SizedBox(width: 10),
                    _TopDot(color: Color(0xFF10B981)),
                    SizedBox(width: 10),
                    _TopDot(color: Color(0xFF3B82F6)),
                    SizedBox(width: 10),
                    _TopDot(color: Color(0xFF8B5CF6)),
                    SizedBox(width: 10),
                    _TopDot(border: true),
                  ],
                ),

                const SizedBox(height: 20),

                // avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.transparent,
                    backgroundImage: const AssetImage('assets/images/file.png'),
                  ),
                ),

                const SizedBox(height: 16),

                // name & subtitle
                const Text(
                  'Abdul wahab',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'AI Developer',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 20),

                // info card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: 'abdulwahab@gmail.com',
                      ),
                      const Divider(height: 20, thickness: 1, color: Color(0xFFF0F2F5)),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        title: 'Address',
                        subtitle: 'vehari , pakistan',
                      ),
                      const Divider(height: 20, thickness: 1, color: Color(0xFFF0F2F5)),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        subtitle: '+92 3123456789',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 38),
              ],
            ),
          ),
        ),
      ),

      // bottom navigation bar with Profile active (middle)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        elevation: 10,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

// small colored circular dot used on top
class _TopDot extends StatelessWidget {
  final Color color;
  final bool border;
  const _TopDot({this.color = Colors.black, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: border ? Colors.transparent : color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.blueGrey, width: 2) : null,
        boxShadow: border
            ? null
            : [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

// reusable info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // blue rounded icon box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
