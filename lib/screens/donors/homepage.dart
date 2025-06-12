import 'package:flutter/material.dart';

const Color bloodRed = Color(0xFF8B0000);

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        title: const Text(
          'Welcome, Lifesaver!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: bloodRed,
          ),
        ),
        backgroundColor: const Color(0xFFFDF4F4),
        elevation: 0,
        foregroundColor: bloodRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/donate.jpg',
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: const [
                  InfoCard(
                    icon: Icons.favorite,
                    title: "You Save Lives",
                    description:
                        "Each donation can help multiple patients recover and thrive.",
                  ),
                  SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.volunteer_activism,
                    title: "Be a Hero",
                    description:
                        "Your contribution supports accident victims, surgery patients, and more.",
                  ),
                  SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.shield_rounded,
                    title: "Safe & Secure",
                    description:
                        "All donations go through licensed and trusted blood banks.",
                  ),
                  SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.people,
                    title: "Strong Community",
                    description:
                        "Join thousands of donors creating a culture of care and compassion.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Did You Know Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: bloodRed.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💡 Did You Know?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: bloodRed,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "🔹 Every 2 seconds, someone needs blood in India.",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "🔹 A single car accident victim can need up to 100 units.",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "🔹 Blood cannot be manufactured — only donated.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Community Impact Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: bloodRed.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🌍 Community Impact",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: bloodRed,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "✔️ 10,000+ donations through our platform.",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "✔️ Supporting 100+ hospitals and emergency services.",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "✔️ Thousands of lives changed for the better.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: bloodRed.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 42, color: bloodRed),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: bloodRed,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
