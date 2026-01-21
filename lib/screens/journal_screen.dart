import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Journal Screen - Daily reflection and writing
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _journalController = TextEditingController();
  final _titleController = TextEditingController();
  
  List<Map<String, dynamic>> _journalEntries = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  String? _editingEntryId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final entries = await _databaseService.getJournalEntries(userId);
        setState(() {
          _journalEntries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveJournalEntry() async {
    if (_journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something in your journal')),
      );
      return;
    }

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        final date = _selectedDate ?? DateTime.now();
        final title = _titleController.text.trim().isEmpty 
            ? DateFormat('MMMM d, yyyy').format(date)
            : _titleController.text.trim();
        
        if (_editingEntryId != null) {
          await _databaseService.updateJournalEntry(
            userId,
            _editingEntryId!,
            title,
            _journalController.text.trim(),
            date,
          );
        } else {
          await _databaseService.addJournalEntry(
            userId,
            title,
            _journalController.text.trim(),
            date,
          );
        }

        _journalController.clear();
        _titleController.clear();
        _editingEntryId = null;
        await _loadJournalEntries();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal entry saved'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _journalController.clear();
        _titleController.clear();
        _editingEntryId = null;
      });
    }
  }

  void _editEntry(Map<String, dynamic> entry) {
    setState(() {
      _editingEntryId = entry['id'].toString();
      _titleController.text = entry['title'] as String;
      _journalController.text = entry['content'] as String;
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(entry['date'] as int);
    });
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = await _authService.getCurrentUserId();
        if (userId != null) {
          await _databaseService.deleteJournalEntry(userId, entryId);
          await _loadJournalEntries();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date selector and new entry button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime.now();
                                _journalController.clear();
                                _titleController.clear();
                                _editingEntryId = null;
                              });
                            },
                            icon: const Icon(Icons.today),
                            label: const Text('Today'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Journal entry form
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title (optional)',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _journalController,
                        decoration: InputDecoration(
                          labelText: 'Write your thoughts...',
                          prefixIcon: const Icon(Icons.edit),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        maxLines: 8,
                        minLines: 5,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saveJournalEntry,
                        icon: const Icon(Icons.save),
                        label: Text(_editingEntryId != null ? 'Update Entry' : 'Save Entry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Past entries
                Expanded(
                  child: _journalEntries.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No journal entries yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start writing to reflect on your journey',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _journalEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _journalEntries[index];
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              entry['date'] as int,
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  entry['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      entry['content'] as String,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('MMM d, yyyy • h:mm a').format(date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editEntry(entry),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteEntry(entry['id'].toString()),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(entry['title'] as String),
                                      content: SingleChildScrollView(
                                        child: Text(entry['content'] as String),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _journalController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
