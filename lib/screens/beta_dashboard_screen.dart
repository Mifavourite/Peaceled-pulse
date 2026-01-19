import 'package:flutter/material.dart';
import '../services/beta_testing_service.dart';
import '../utils/bug_tracker.dart';
import '../utils/performance_monitor.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

/// Beta Testing Dashboard for Developers
/// Shows feedback, bugs, and performance metrics
class BetaDashboardScreen extends StatefulWidget {
  const BetaDashboardScreen({super.key});

  @override
  State<BetaDashboardScreen> createState() => _BetaDashboardScreenState();
}

class _BetaDashboardScreenState extends State<BetaDashboardScreen> {
  final _betaService = BetaTestingService();
  final _bugTracker = BugTracker();
  bool _isLoading = false;
  
  FeedbackSummary? _feedbackSummary;
  BugStatistics? _bugStatistics;
  PerformanceSummary? _performanceSummary;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final feedback = await _betaService.analyzeFeedback();
      final bugs = await _bugTracker.getStatistics();
      final perf = PerformanceMonitor.instance.getSummary();
      
      setState(() {
        _feedbackSummary = feedback;
        _bugStatistics = bugs;
        _performanceSummary = perf;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportFeedbackSummary() async {
    try {
      final summary = await _betaService.exportFeedbackSummary();
      final report = '=== BETA TESTING REPORT ===\n\n$summary';
      
      await Share.share(report, subject: 'Beta Testing Feedback Summary');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportBugs() async {
    try {
      final bugsJson = await _bugTracker.exportBugs();
      await Share.share(bugsJson, subject: 'Bug Report Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportPerformanceReport() async {
    try {
      final report = PerformanceMonitor.instance.getPerformanceReport();
      final reportJson = jsonEncode(report);
      await Share.share(reportJson, subject: 'Performance Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beta Dashboard'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Feedback',
                          _feedbackSummary?.totalFeedbacks ?? 0,
                          Icons.feedback,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          'Bugs',
                          _bugStatistics?.total ?? 0,
                          Icons.bug_report,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Open',
                          _bugStatistics?.open ?? 0,
                          Icons.warning,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          'Fixed',
                          _bugStatistics?.fixed ?? 0,
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Feedback Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Feedback Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _exportFeedbackSummary,
                                tooltip: 'Export',
                              ),
                            ],
                          ),
                          if (_feedbackSummary != null) ...[
                            const SizedBox(height: 16),
                            Text('Total: ${_feedbackSummary!.totalFeedbacks}'),
                            const SizedBox(height: 8),
                            ..._feedbackSummary!.categories.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key),
                                    Text('${e.value}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bugs Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bug Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _exportBugs,
                                tooltip: 'Export',
                              ),
                            ],
                          ),
                          if (_bugStatistics != null) ...[
                            const SizedBox(height: 16),
                            Text('Total: ${_bugStatistics!.total}'),
                            const SizedBox(height: 8),
                            Text('Open: ${_bugStatistics!.open}'),
                            Text('Fixed: ${_bugStatistics!.fixed}'),
                            Text('Verified: ${_bugStatistics!.verified}'),
                            const Divider(),
                            ..._bugStatistics!.bySeverity.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key),
                                    Text('${e.value}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Performance Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Performance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _exportPerformanceReport,
                                tooltip: 'Export',
                              ),
                            ],
                          ),
                          if (_performanceSummary != null) ...[
                            const SizedBox(height: 16),
                            Text('Samples: ${_performanceSummary!.sampleCount}'),
                            Text('Avg Memory: ${_performanceSummary!.averageMemoryUsage.toStringAsFixed(1)} MB'),
                            Text('Avg Render: ${_performanceSummary!.averageRenderTime.toStringAsFixed(2)} ms'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
  }

  Widget _buildSummaryCard(String title, int value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
