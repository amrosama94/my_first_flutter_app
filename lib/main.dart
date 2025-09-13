import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ITHAKAplaceApp());
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://be.ithaka.world/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      // Print API response for debugging
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      print('API Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Login successful
        final data = json.decode(response.body);
        print('Login successful! Response data: $data');
        
        // Show success toast
        _showSuccessToast('Login successful! Welcome to ITHAKA!');
        
        // Navigate to main app after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        });
      } else {
        // Login failed - parse error message from response
        String errorMessage = 'Login failed. Please check your credentials.';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        
        print('Login failed with status: ${response.statusCode}');
        _showErrorToast(errorMessage);
      }
    } catch (e) {
      print('Network error: $e');
      _showErrorToast('Network error. Please check your connection and try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LandingPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ),
              // Login form
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo/Title
                              const Text(
                                'ITHAKA',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Welcome to Egypt',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1E3A8A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1E3A8A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Demo credentials info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Demo Credentials:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Email: admin@cp.cs',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Password: 4EgfWS@4',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ITHAKAplaceApp extends StatelessWidget {
  const ITHAKAplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITHAKA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep blue inspired by Ithaka
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFF59E0B), // Orange accent
          surface: const Color(0xFFF8FAFC),
          background: const Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavigationHeader(),
            const HeroSection(),
            const DestinationsSection(),
            const ActivitiesSection(),
            const BlogSection(),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class NavigationHeader extends StatelessWidget {
  const NavigationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout - stack vertically
            return Column(
              children: [
                const Text(
                  'ITHAKA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Destinations'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Activities'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Blog'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Desktop layout - horizontal
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ITHAKA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Destinations'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Activities'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Blog'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double titleFontSize = 48;
                double subtitleFontSize = 20;
                
                if (constraints.maxWidth < 600) {
                  titleFontSize = 32;
                  subtitleFontSize = 16;
                } else if (constraints.maxWidth < 900) {
                  titleFontSize = 40;
                  subtitleFontSize = 18;
                }
                
                return Column(
                  children: [
                    Text(
                      'Discover Egypt with ITHAKA',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore the wonders of Egypt with our curated collection of authentic tours and experiences',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      ),
    );
  }
}

class DestinationsSection extends StatelessWidget {
  const DestinationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = 48;
        if (constraints.maxWidth < 600) {
          padding = 16;
        } else if (constraints.maxWidth < 900) {
          padding = 24;
        }
        
        return Container(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double titleFontSize = 36;
                  double subtitleFontSize = 18;
                  
                  if (constraints.maxWidth < 600) {
                    titleFontSize = 28;
                    subtitleFontSize = 16;
                  } else if (constraints.maxWidth < 900) {
                    titleFontSize = 32;
                    subtitleFontSize = 17;
                  }
                  
                  return Column(
                    children: [
                      Text(
                        'Egyptian Destinations',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Discover the most beautiful destinations across Egypt',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 2;
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.2,
                ),
                itemCount: 6,
            itemBuilder: (context, index) {
              final destinations = [
                {'name': 'Cairo', 'image': '🏛️', 'tours': '45 tours'},
                {'name': 'Alexandria', 'image': '🌊', 'tours': '32 tours'},
                {'name': 'Luxor', 'image': '🏺', 'tours': '28 tours'},
                {'name': 'Aswan', 'image': '⛵', 'tours': '38 tours'},
                {'name': 'Siwa', 'image': '🏜️', 'tours': '25 tours'},
                {'name': 'Dahab', 'image': '🤿', 'tours': '42 tours'},
              ];
              
              return DestinationCard(
                name: destinations[index]['name']!,
                image: destinations[index]['image']!,
                tours: destinations[index]['tours']!,
              );
            },
              );
            },
          ),
        ],
        ),
      );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String name;
  final String image;
  final String tours;

  const DestinationCard({
    super.key,
    required this.name,
    required this.image,
    required this.tours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            image,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tours,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double titleFontSize = 36;
              double subtitleFontSize = 18;
              
              if (constraints.maxWidth < 600) {
                titleFontSize = 28;
                subtitleFontSize = 16;
              } else if (constraints.maxWidth < 900) {
                titleFontSize = 32;
                subtitleFontSize = 17;
              }
              
              return Column(
                children: [
                      Text(
                        'Egyptian Experiences',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Immerse yourself in authentic Egyptian culture and adventures',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 4;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 3;
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: 8,
            itemBuilder: (context, index) {
              final activities = [
                {'name': 'Pyramid Tours', 'icon': Icons.location_city, 'color': const Color(0xFF3B82F6)},
                {'name': 'Nile Cruises', 'icon': Icons.directions_boat, 'color': const Color(0xFFF59E0B)},
                {'name': 'Desert Safari', 'icon': Icons.terrain, 'color': const Color(0xFF10B981)},
                {'name': 'Temples', 'icon': Icons.museum, 'color': const Color(0xFF8B5CF6)},
                {'name': 'Red Sea Diving', 'icon': Icons.water, 'color': const Color(0xFF059669)},
                {'name': 'Photography', 'icon': Icons.camera_alt, 'color': const Color(0xFFEF4444)},
                {'name': 'Archaeology', 'icon': Icons.history_edu, 'color': const Color(0xFF7C3AED)},
                {'name': 'Cultural Shows', 'icon': Icons.theater_comedy, 'color': const Color(0xFFDC2626)},
              ];
              
              return ActivityCard(
                name: activities[index]['name']! as String,
                icon: activities[index]['icon']! as IconData,
                color: activities[index]['color']! as Color,
              );
            },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const ActivityCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BlogSection extends StatelessWidget {
  const BlogSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double titleFontSize = 36;
              double subtitleFontSize = 18;
              
              if (constraints.maxWidth < 600) {
                titleFontSize = 28;
                subtitleFontSize = 16;
              } else if (constraints.maxWidth < 900) {
                titleFontSize = 32;
                subtitleFontSize = 17;
              }
              
              return Column(
                children: [
                      Text(
                        'Egypt Travel Stories',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Get inspired by authentic Egyptian travel experiences and local insights',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 2;
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.8,
                ),
                itemCount: 3,
            itemBuilder: (context, index) {
              final articles = [
                {
                  'title': '10 Hidden Gems in Cairo',
                  'excerpt': 'Discover the secret spots that locals love in the City of a Thousand Minarets.',
                  'author': 'Ahmed Hassan',
                  'date': 'Dec 15, 2023',
                  'image': '🏛️',
                },
                {
                  'title': 'Luxor Temple Guide: Best Times to Visit',
                  'excerpt': 'A comprehensive guide to experiencing the magic of ancient Egyptian temples.',
                  'author': 'Fatima Ali',
                  'date': 'Dec 12, 2023',
                  'image': '🏺',
                },
                {
                  'title': 'Red Sea Adventures in Dahab',
                  'excerpt': 'Experience the thrill of diving and water sports in Egypt\'s most beautiful coastal town.',
                  'author': 'Omar Mahmoud',
                  'date': 'Dec 10, 2023',
                  'image': '🤿',
                },
              ];
              
              return BlogCard(
                title: articles[index]['title']!,
                excerpt: articles[index]['excerpt']!,
                author: articles[index]['author']!,
                date: articles[index]['date']!,
                image: articles[index]['image']!,
              );
            },
              );
            },
          ),
        ],
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final String title;
  final String excerpt;
  final String author;
  final String date;
  final String image;

  const BlogCard({
    super.key,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.date,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: const Color(0xFFF8FAFC),
            ),
            child: Center(
              child: Text(
                image,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  excerpt,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      color: const Color(0xFF1E3A8A),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    _buildFooterColumn('ITHAKA', 'Discover authentic Egyptian tours and experiences\nwith local expertise and cultural insights.', [
                      const Text('About Us', style: TextStyle(color: Colors.white70)),
                      const Text('Careers', style: TextStyle(color: Colors.white70)),
                      const Text('Contact', style: TextStyle(color: Colors.white70)),
                    ]),
                    const SizedBox(height: 32),
                    _buildFooterColumn('Support', '', [
                      const Text('Help Center', style: TextStyle(color: Colors.white70)),
                      const Text('Terms of Service', style: TextStyle(color: Colors.white70)),
                      const Text('Privacy Policy', style: TextStyle(color: Colors.white70)),
                    ]),
                    const SizedBox(height: 32),
                    _buildFooterColumn('Follow Us', '', [
                      Row(
                        children: [
                          Icon(Icons.facebook, color: Colors.white70),
                          const SizedBox(width: 16),
                          Icon(Icons.camera_alt, color: Colors.white70),
                          const SizedBox(width: 16),
                          Icon(Icons.alternate_email, color: Colors.white70),
                        ],
                      ),
                    ]),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ITHAKA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Discover authentic Egyptian tours and experiences\nwith local expertise and cultural insights.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('About Us', style: TextStyle(color: Colors.white70)),
                        const Text('Careers', style: TextStyle(color: Colors.white70)),
                        const Text('Contact', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Help Center', style: TextStyle(color: Colors.white70)),
                        const Text('Terms of Service', style: TextStyle(color: Colors.white70)),
                        const Text('Privacy Policy', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Follow Us',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.facebook, color: Colors.white70),
                            const SizedBox(width: 16),
                            Icon(Icons.camera_alt, color: Colors.white70),
                            const SizedBox(width: 16),
                            Icon(Icons.alternate_email, color: Colors.white70),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          const Text(
            '© 2023 ITHAKA Egypt. All rights reserved.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, String description, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
