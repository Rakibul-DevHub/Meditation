import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String greeting = HomeScreen._getGreeting();

  // Featured Sounds - Horizontal Scroll (8 items)
  final List<Map<String, String>> featuredSounds = [
    {"title": "Gentle Rain", "image": "assets/images/dummy_image.jpg", "duration": "60:00"},
    {"title": "Ocean Waves", "image": "assets/images/dummy_image2.jpg", "duration": "45:00"},
    {"title": "Forest Night", "image": "assets/images/dummy_image3.jpg", "duration": "60:00"},
    {"title": "Mountain Stream", "image": "assets/images/dummy_image.jpg", "duration": "50:00"},
    {"title": "Thunder Storm", "image": "assets/images/dummy_image2.jpg", "duration": "90:00"},
    {"title": "Birds Chirping", "image": "assets/images/dummy_image3.jpg", "duration": "40:00"},
    {"title": "White Noise", "image": "assets/images/dummy_image.jpg", "duration": "120:00"},
    {"title": "Campfire", "image": "assets/images/dummy_image2.jpg", "duration": "60:00"},
  ];

  // Sleep Tonight - Horizontal Scroll (8 items)
  final List<Map<String, String>> sleepTonight = [
    {"title": "Deep Sleep", "image": "assets/images/dummy_image.jpg", "duration": "8:00:00"},
    {"title": "Lucid Dreaming", "image": "assets/images/dummy_image2.jpg", "duration": "6:00:00"},
    {"title": "Sleep Meditation", "image": "assets/images/dummy_image3.jpg", "duration": "45:00"},
    {"title": "Night Rain", "image": "assets/images/dummy_image.jpg", "duration": "8:00:00"},
    {"title": "Calm Piano", "image": "assets/images/dummy_image2.jpg", "duration": "7:00:00"},
    {"title": "Tibetan Bowls", "image": "assets/images/dummy_image3.jpg", "duration": "5:00:00"},
    {"title": "Breathing Exercise", "image": "assets/images/dummy_image.jpg", "duration": "30:00"},
    {"title": "Body Scan", "image": "assets/images/dummy_image2.jpg", "duration": "40:00"},
  ];

  // Popular Listening - Vertical Scroll (10 items)
  final List<Map<String, String>> popularListening = [
    {"title": "Morning Meditation", "image": "assets/images/dummy_image.jpg", "duration": "20:00", "category": "Meditation"},
    {"title": "Focus Music", "image": "assets/images/dummy_image2.jpg", "duration": "120:00", "category": "Focus"},
    {"title": "Anxiety Relief", "image": "assets/images/dummy_image3.jpg", "duration": "30:00", "category": "Therapy"},
    {"title": "Yoga Flow", "image": "assets/images/dummy_image.jpg", "duration": "45:00", "category": "Yoga"},
    {"title": "Study Beats", "image": "assets/images/dummy_image2.jpg", "duration": "180:00", "category": "Study"},
    {"title": "Stress Relief", "image": "assets/images/dummy_image3.jpg", "duration": "25:00", "category": "Therapy"},
    {"title": "Power Nap", "image": "assets/images/dummy_image.jpg", "duration": "20:00", "category": "Sleep"},
    {"title": "Mindfulness", "image": "assets/images/dummy_image2.jpg", "duration": "15:00", "category": "Meditation"},
    {"title": "Nature Sounds", "image": "assets/images/dummy_image3.jpg", "duration": "90:00", "category": "Nature"},
    {"title": "Sleep Stories", "image": "assets/images/dummy_image.jpg", "duration": "45:00", "category": "Sleep"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xff101828),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xff364153)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.watch_later_outlined, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Text("Sleep", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                "Time to unwind and relax",
                style: TextStyle(color: Color(0xff9AA4B2)),
              ),

              const SizedBox(height: 30),

              /// Featured Sounds - Horizontal Scroll
              const SectionHeader(title: "Featured Sounds"),
              const SizedBox(height: 16),

              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredSounds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = featuredSounds[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            image: DecorationImage(
                              image: AssetImage(item["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["title"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          item["duration"]!,
                          style: const TextStyle(
                            color: Color(0xff9AA4B2),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// Sleep Tonight - Horizontal Scroll
              const SectionHeader(title: "Sleep Tonight"),
              const SizedBox(height: 16),

              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sleepTonight.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = sleepTonight[index];
                    return SleepCard(
                      title: item["title"]!,
                      duration: item["duration"]!,
                      image: item["image"]!,
                      width: 110,
                      height: 110,
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// Popular Listening - Vertical Scroll
              const SectionHeader(title: "Popular Listening"),
              const SizedBox(height: 16),

              // Vertical ListView with proper scrolling
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Parent SingleChildScrollView handles scrolling
                itemCount: popularListening.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = popularListening[index];
                  return Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(item["image"]!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${item["category"]} • ${item["duration"]}",
                              style: const TextStyle(
                                color: Color(0xff9AA4B2),
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Icon(Icons.play_arrow, color: Colors.white70),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite_border, color: Colors.white70),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SleepCard extends StatelessWidget {
  final String title;
  final String duration;
  final String image;
  final double width;
  final double height;

  const SleepCard({
    super.key,
    required this.title,
    required this.duration,
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              color: Color(0xff9AA4B2),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}