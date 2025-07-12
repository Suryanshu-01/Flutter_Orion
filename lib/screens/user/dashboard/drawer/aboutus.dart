import 'package:flutter/material.dart';
import '../../authentication/select_user.dart';
import '../dashboard_screen.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  Widget _buildTeamMember({
    required String name,
    required String rollNumber,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.cyan,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rollNumber,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan[800]!, Colors.cyan[400]!],
                ),
              ),
              child: Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile Manager"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text("Admin/User"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SelectUser()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About Us"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AboutUs()),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.shade700, Colors.cyan.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.group, size: 40, color: Colors.cyan),
                      SizedBox(height: 10),
                      Text(
                        "We are the Team of Orion Pay",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTeamMember(
                  name: "Kumar Suryanshu",
                  rollNumber: "2024IMG-026",
                  description: "Add text here",
                ),
                _buildTeamMember(
                  name: "Prakhar Srivastava",
                  rollNumber: "2024IMG-033",
                  description: "Add text here",
                ),
                _buildTeamMember(
                  name: "Aryan Singh",
                  rollNumber: "2024IMT-013",
                  description: "Add text here",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
