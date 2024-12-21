import 'package:flutter/material.dart';
import 'package:halal_bites/rating/models/rating.dart' as rating_model;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:halal_bites/food/models/food.dart' as food_model;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

void main() {
  runApp(MaterialApp(
    home: const FoodReviewPage(),
    theme: ThemeData(
      primaryColor: Colors.yellow[700],
      colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.yellow[700]),
    ),
  ));
}

class FoodReviewPage extends StatefulWidget {
  const FoodReviewPage({Key? key}) : super(key: key);

  @override
  _FoodReviewPageState createState() => _FoodReviewPageState();
}

class _FoodReviewPageState extends State<FoodReviewPage> {
  List<rating_model.Rating> allRatings = []; // Initialize as empty list
  List<food_model.Food> allFoods = [];
  food_model.Food? selectedFood;
  int? loggedInUserId; // Changed from String to int?

  int? getActualUserId() {
    final request = Provider.of<CookieRequest>(context, listen: false);
    if (request.loggedIn) {
      return request.jsonData['id']; // Return as int
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        loggedInUserId = getActualUserId();
      });
    });
    fetchFoods();
    fetchRatings();
  }

  Future<void> fetchFoods() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/menu/get_food/')); // Update URL if needed
      print('Food Response: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Decoded Food Data: $data'); // Debug print
        
        setState(() {
          allFoods = data.map((f) => food_model.Food.fromJson(f)).toList();
        });
        print('Parsed Foods: ${allFoods.length}'); // Debug print
      } else {
        print('Failed to fetch foods: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching foods: $e');
    }
  }

  Future<void> fetchRatings() async {
    final response = await http.get(Uri.parse('http://localhost:8000/rating/json/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        allRatings = data.map((json) => rating_model.Rating.fromJson(json)).toList();
      });
    } else {
      // Handle error
      print('Failed to load ratings');
    }
  }

  Future<void> submitReview(rating_model.User? user, food_model.Food food,
      int rating, String description) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final url = Uri.parse('http://localhost:8000/rating/create_rating_flutter/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'food_id': food.pk, // Keep as string, Django will handle conversion
          'user_id': loggedInUserId, // This is already an int
          'rating': rating,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
        }
        // Refresh the ratings list
        await fetchRatings();
      } else {
        print('Failed to submit review: ${response.body}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit review: ${jsonDecode(response.body)['message']}')),
          );
        }
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String searchQuery = "";

  // For the modal dialog form
  final _foodNameController = TextEditingController();
  double _selectedRating = 5;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _foodNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter ratings based on the search query
    List<rating_model.Rating> filteredRatings = allRatings.where((rating) {
      return rating.food.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Group ratings by food to calculate average ratings
    Map<String, List<rating_model.Rating>> ratingsByFood = {};
    for (var rating in allRatings) {
      ratingsByFood.putIfAbsent(rating.food.name, () => []).add(rating);
    }

    // Calculate average ratings for each food
    List<MapEntry<String, double>> averageRatings = ratingsByFood.entries.map((entry) {
      double avg = entry.value.fold(0, (sum, r) => sum + r.rating) / entry.value.length;
      return MapEntry(entry.key, avg);
    }).toList();

    // Sort to get top-rated foods
    averageRatings.sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, double>> topRated = averageRatings.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text(
          "Food Review",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search for reviewed foods",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
            // Top Rated Foods Section
            Container(
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Top Rated",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: topRated.map((entry) {
                      String foodName = entry.key;
                      double avgRating = entry.value;
                      String? imageUrl = ratingsByFood[foodName]?.first.food.imageUrl; // Added

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailPage(
                                foodName: foodName,
                                ratings: ratingsByFood[foodName]!,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Rating badge
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: (imageUrl != null)
                                      ? NetworkImage(imageUrl)
                                      : null, // Changed entryKey to imageUrl
                                  backgroundColor: Colors.yellow[700],
                                  child: Text(
                                    avgRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foodName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text("Rating: ${avgRating.toStringAsFixed(1)} ★"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),

            // Add a Review Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    _showAddReviewDialog();
                  },
                  child: const Text(
                    "Add a Review",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // List of All Reviewed Foods
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: ratingsByFood.keys.map((foodName) {
                  double avgRating = ratingsByFood[foodName]!
                      .fold(0, (sum, r) => sum + r.rating) /
                      ratingsByFood[foodName]!.length;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailPage(
                            foodName: foodName,
                            ratings: ratingsByFood[foodName]!,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            foodName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Rating: ${avgRating.toStringAsFixed(1)} ★"),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    if (allFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No foods available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add a Review",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<food_model.Food>(
                        value: selectedFood,
                        hint: const Text('Select a food'), // Add hint text
                        items: allFoods.map((food_model.Food food) {
                          print('Food Item: ${food.fields.name}'); // Debug print
                          return DropdownMenuItem<food_model.Food>(
                            value: food,
                            child: Text(food.fields.name),
                          );
                        }).toList(),
                        onChanged: (food_model.Food? val) {
                          print('Selected Food: ${val?.fields.name}'); // Debug print
                          setStateDialog(() {
                            selectedFood = val;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Choose Food",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<double>(
                        value: _selectedRating,
                        items: [1, 2, 3, 4, 5].map((val) {
                          return DropdownMenuItem<double>(
                            value: val.toDouble(),
                            child: Text("$val ★"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setStateDialog(() {
                            _selectedRating = val ?? 5.0;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Rating",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () async {
                              // Simulate asynchronous submission
                              await Future.delayed(const Duration(seconds: 1));
                              // Add the new food to the list if not present,
                              // or just add a review if it already exists
                              String name = _foodNameController.text.trim();
                              String desc = _descriptionController.text.trim();
                              if (selectedFood == null || loggedInUserId == null) return;
                              rating_model.User currentUser =
                                  rating_model.User(id: loggedInUserId!.toString(), username: 'LoggedInUser'); // Convert id to String
                              await submitReview(
                                currentUser,
                                selectedFood!,
                                _selectedRating.toInt(),
                                desc,
                              );

                              // Clear fields
                              _foodNameController.clear();
                              _descriptionController.clear();
                              _selectedRating = 5;

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FoodDetailPage extends StatelessWidget {
  final String foodName;
  final List<rating_model.Rating> ratings;

  const FoodDetailPage({Key? key, required this.foodName, required this.ratings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double avgRating = ratings.fold(0, (sum, r) => sum + r.rating) / ratings.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          foodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                foodName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Average Rating: ${avgRating.toStringAsFixed(1)} ★",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                ratings.first.food.name,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                "Reviews",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Column(
                children: ratings.map((r) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        r.user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text("${r.rating} ★ - ${r.description}"),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
