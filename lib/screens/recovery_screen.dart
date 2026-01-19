import 'package:flutter/material.dart';

/// Recovery Screen after detection - provides encouragement and next steps
class RecoveryScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const RecoveryScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizing for mobile
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.height < 600 || mediaQuery.size.width < 360;
    final buttonMinHeight = 56.0; // Touch-friendly button height
    
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 24 : 40),

                  // Success icon - responsive
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade100,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: isSmallScreen ? 60 : 80,
                      color: Colors.green.shade700,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 32),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '✓ Recovery Complete',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  Text(
                    'You\'ve taken an important step',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      color: Colors.green.shade800,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 32 : 48),

              // Encouragement card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 48,
                        color: Colors.pink.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Remember',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Every moment is a new beginning. You have the strength to make better choices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Next steps
              Card(
                elevation: 2,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Next Steps',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStepItem(
                        '1',
                        'Take a moment to breathe',
                        Icons.air,
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '2',
                        'Engage in positive activity',
                        Icons.sports_soccer,
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '3',
                        'Connect with supportive community',
                        Icons.people,
                      ),
                    ],
                  ),
                ),
              ),

                  SizedBox(height: isSmallScreen ? 32 : 48),

                  // Continue button - touch-friendly, full width on mobile
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 32 : 48,
                          vertical: 18, // Touch-friendly
                        ),
                        minimumSize: Size(double.infinity, buttonMinHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward),
                          const SizedBox(width: 8),
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
