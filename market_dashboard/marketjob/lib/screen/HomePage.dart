import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? overviewData;
  List<dynamic>? jobsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final overview = await _apiService.getOverview();
      final jobs = await _apiService.getJobs();
      
      setState(() {
        overviewData = overview;
        jobsData = jobs['data'];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Market Intelligence Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewSection(),
                    SizedBox(height: 20),
                    _buildJobsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    if (overviewData == null) return SizedBox.shrink();

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        _buildStatCard(
          'Total Jobs', 
          '${overviewData!['total_jobs']}', 
          Colors.blue
        ),
        _buildStatCard(
          'Companies', 
          '${overviewData!['total_companies']}', 
          Colors.green
        ),
        _buildStatCard(
          'Skills', 
          '${overviewData!['total_skills']}', 
          Colors.orange
        ),
        _buildStatCard(
          'Avg Salary', 
          '\$${overviewData!['avg_salary']}', 
          Colors.purple
        ),
      ],
    );
  }

  Widget _buildJobsList() {
    if (jobsData == null) return SizedBox.shrink();

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: jobsData!.length,
        itemBuilder: (context, index) {
          final job = jobsData![index];
          return ListTile(
            title: Text(job['job_title'] ?? 'No Title'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['company_name'] ?? 'Unknown Company'),
                Text('${job['location'] ?? 'No Location'} • ${job['salary'] ?? 'Salary not specified'}'),
              ],
            ),
            trailing: Chip(
              label: Text(job['job_type'] ?? 'Full-time'),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
            onTap: () {
              // Add job detail navigation here
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
