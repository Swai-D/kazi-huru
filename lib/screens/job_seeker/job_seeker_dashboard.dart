import 'package:flutter/material.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  int _selectedIndex = 0;

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text(
                'Salio Lako: TZS 5,000',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(color: Colors.black54),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Ongeza Salio',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kazi Zilizopo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Job 1
        const _JobCard(
          title: 'Kumuhamisha Mtu',
          location: 'Dar es Salaam',
          price: 'TZS 20,000',
        ),
        const SizedBox(height: 12),
        // Job 2
        const _JobCard(
          title: 'Kusafisha Compound',
          location: 'Dar es Salaam',
          price: 'TZS 15,000',
        ),
      ],
    );
  }

  Widget _buildTumaKazi() {
    return const Center(
      child: Text(
        'Tuma Kazi (Placeholder)',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildKaziZangu() {
    return const Center(
      child: Text(
        'Kazi Zangu (Placeholder)',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildDashboard(),
              ),
            ),
          ],
        );
        break;
      case 1:
        bodyContent = _buildTumaKazi();
        break;
      case 2:
        bodyContent = _buildKaziZangu();
        break;
      default:
        bodyContent = Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildDashboard(),
              ),
            ),
          ],
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quickjobs'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: bodyContent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Mwanzo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tuma Kazi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Kazi Zangu',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;

  const _JobCard({
    required this.title,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(location),
                Text(price),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              side: const BorderSide(color: Colors.black54),
            ),
            child: const Text('Omba'),
          ),
        ],
      ),
    );
  }
} 