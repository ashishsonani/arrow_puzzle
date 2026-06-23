import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_challenges_screen.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _completedCurrentMonth = 0;
  int _completedPrevMonth1 = 0;
  int _completedPrevMonth2 = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    int countMonth(int year, int month) {
      int days = DateTime(year, month + 1, 0).day;
      int count = 0;
      for (int i = 1; i <= days; i++) {
        int levelNum = year * 10000 + month * 100 + i;
        if (prefs.getBool('daily_completed_$levelNum') == true) {
          count++;
        }
      }
      return count;
    }

    int currentMonth = now.month;
    int currentYear = now.year;
    
    DateTime prev1 = DateTime(currentYear, currentMonth - 1, 1);
    DateTime prev2 = DateTime(currentYear, currentMonth - 2, 1);

    setState(() {
      _completedCurrentMonth = countMonth(currentYear, currentMonth);
      _completedPrevMonth1 = countMonth(prev1.year, prev1.month);
      _completedPrevMonth2 = countMonth(prev2.year, prev2.month);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Awards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Tab Bar Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent, // Removes the line below the tabs
                indicator: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(25),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Events'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    DateTime prev1 = DateTime(now.year, now.month - 1, 1);
    DateTime prev2 = DateTime(now.year, now.month - 2, 1);
    
    int daysInCurrent = DateTime(now.year, now.month + 1, 0).day;
    int daysInPrev1 = DateTime(prev1.year, prev1.month + 1, 0).day;
    int daysInPrev2 = DateTime(prev2.year, prev2.month + 1, 0).day;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            now.year.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrophyItem(months[now.month - 1], '$_completedCurrentMonth of $daysInCurrent', 'assets/trophy${(now.month % 3) + 1}.png', _completedCurrentMonth, daysInCurrent, now),
              _buildTrophyItem(months[prev1.month - 1], '$_completedPrevMonth1 of $daysInPrev1', 'assets/trophy${(prev1.month % 3) + 1}.png', _completedPrevMonth1, daysInPrev1, prev1),
              _buildTrophyItem(months[prev2.month - 1], '$_completedPrevMonth2 of $daysInPrev2', 'assets/trophy${(prev2.month % 3) + 1}.png', _completedPrevMonth2, daysInPrev2, prev2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyItem(String month, String progress, String assetPath, int completed, int total, DateTime monthDate) {
    double progressRatio = total > 0 ? completed / total : 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyChallengesScreen(initialMonth: monthDate),
          ),
        );
      },
      child: Column(
        children: [
        Opacity(
          opacity: completed >= total && total > 0 ? 1.0 : 0.3, // Greyscale if not fully complete
          child: Image.asset(
            assetPath,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          month,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 50,
          height: 4,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 50 * progressRatio,
            height: 4,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          progress,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    ));
  }

  Widget _buildEventsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.stars, // Badge icon
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'You have no awards yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Take part in events and collect unique\nrewards. Stay tuned!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100), // Push up slightly from center
        ],
      ),
    );
  }
}
