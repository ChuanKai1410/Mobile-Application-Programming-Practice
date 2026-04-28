import 'package:flutter/material.dart';

class ResponsiveAuthWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const ResponsiveAuthWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD32F2F), Color(0xFFFF9800)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                
                final brandingContent = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant, size: 80, color: Color(0xFFD32F2F)),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                );

                if (isWide) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      elevation: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: 600,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(child: brandingContent),
                                ),
                              ),
                              Container(width: 1, color: Colors.grey.shade200),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(32.0),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(scaffoldBackgroundColor: Colors.white),
                                    child: child,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            brandingContent,
                            const SizedBox(height: 32),
                            SizedBox(
                              height: 550,
                              child: Theme(
                                data: Theme.of(context).copyWith(scaffoldBackgroundColor: Colors.white),
                                child: child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
