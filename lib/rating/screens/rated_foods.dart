import 'package:flutter/material.dart';

// Mock data structures
class FoodItem {
  final String name;
  final double rating;
  final String description;
  final List<Review> reviews;

  FoodItem({
    required this.name,
    required this.rating,
    required this.description,
    required this.reviews,
  });
}

class Review {
  final String reviewerName;
  final int stars; // 1-5 rating
  final String comment;

  Review({required this.reviewerName, required this.stars, required this.comment});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Review Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const FoodReviewPage(),
    );
  }
}

class FoodReviewPage extends StatefulWidget {
  const FoodReviewPage({super.key});

  @override
  State<FoodReviewPage> createState() => _FoodReviewPageState();
}

class _FoodReviewPageState extends State<FoodReviewPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Form fields
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _ratingValue = 3; // default rating

  bool _showReviewForm = false;
  List<FoodItem> _allFoods = [];
  List<FoodItem> _filteredFoods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    // Simulate asynchronous data load
    await Future.delayed(const Duration(seconds: 2));

    final mockData = [
      FoodItem(
        name: "Margherita Pizza",
        rating: 4.5,
        description: "Classic Italian pizza with tomato sauce and mozzarella.",
        reviews: [
          Review(reviewerName: "Alice", stars: 5, comment: "Loved it!"),
          Review(reviewerName: "Bob", stars: 4, comment: "Very good!"),
        ],
      ),
      FoodItem(
        name: "House Special Pizza",
        rating: 4.8,
        description: "Loaded with sausage, mushrooms, olives, and peppers.",
        reviews: [
          Review(reviewerName: "Charlie", stars: 5, comment: "Incredible flavor!"),
          Review(reviewerName: "Diana", stars: 5, comment: "Best pizza ever."),
        ],
      ),
      FoodItem(
        name: "Vegetarian Pizza",
        rating: 4.2,
        description: "Broccoli, mushrooms, olives, and peppers.",
        reviews: [
          Review(reviewerName: "Eve", stars: 4, comment: "Tasty and fresh."),
        ],
      ),
      FoodItem(
        name: "Mediterranean Pizza",
        rating: 4.7,
        description: "Mozzarella, spinach, tomato, garlic, feta cheese.",
        reviews: [
          Review(reviewerName: "Frank", stars: 5, comment: "Amazing flavors."),
          Review(reviewerName: "Grace", stars: 4, comment: "Loved the feta!"),
        ],
      ),
      FoodItem(
        name: "Chicken Alfredo Pizza",
        rating: 4.0,
        description: "Creamy Alfredo base with chicken.",
        reviews: [
          Review(reviewerName: "Hank", stars: 4, comment: "Really good."),
        ],
      ),
    ];

    setState(() {
      _allFoods = mockData;
      _filteredFoods = mockData;
      _isLoading = false;
    });
  }

  void _filterFoods(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFoods = _allFoods;
      });
    } else {
      setState(() {
        _filteredFoods = _allFoods
            .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _submitReview() async {
    final foodName = _foodNameController.text.trim();
    final description = _descriptionController.text.trim();
    final rating = _ratingValue;

    if (foodName.isEmpty) return;

    // Simulate asynchronous submission
    await Future.delayed(const Duration(seconds: 1));

    final newItem = FoodItem(
      name: foodName,
      rating: rating.toDouble(),
      description: description,
      reviews: [
        Review(reviewerName: "You", stars: rating, comment: description)
      ],
    );

    setState(() {
      _allFoods.add(newItem);
      _filterFoods(_searchController.text);
      _foodNameController.clear();
      _descriptionController.clear();
      _ratingValue = 3;
      _showReviewForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topRatedFoods = _filteredFoods
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final topThree = topRatedFoods.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Review"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.yellow[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Search Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search for reviewed foods",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        _filterFoods(value);
                      },
                    ),
                  ),

                  // Top rated foods section
                  if (topThree.isNotEmpty) 
                    Container(
                      color: Colors.yellow[100],
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top Rated",
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          for (var food in topThree)
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(food.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              title: Text(food.name),
                              subtitle: Text("Rating: ${food.rating} ★"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => FoodDetailPage(food: food))
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                  // Button to show/hide review form
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        setState(() {
                          _showReviewForm = !_showReviewForm;
                        });
                      },
                      child: Text(_showReviewForm ? "Hide Review Form" : "Add a Review"),
                    ),
                  ),

                  // Review form
                  if (_showReviewForm)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _foodNameController,
                                decoration: const InputDecoration(
                                  labelText: "Food Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _ratingValue,
                                decoration: const InputDecoration(
                                  labelText: "Rating (1-5)",
                                  border: OutlineInputBorder(),
                                ),
                                items: [1,2,3,4,5].map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e,
                                    child: Text(e.toString()),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _ratingValue = val;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: "Description",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                                onPressed: _submitReview,
                                child: const Text("Submit Review"),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Food list section
                    Expanded(
                      child: _filteredFoods.isEmpty
                          ? const Center(child: Text("No foods found"))
                          : ListView.builder(
                              itemCount: _filteredFoods.length,
                              itemBuilder: (context, index) {
                                final item = _filteredFoods[index];
                                return ListTile(
                                  title: Text(item.name),
                                  subtitle: Text("Rating: ${item.rating} ★"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => FoodDetailPage(food: item))
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                ],
              ),
            ),
    );
  }
}

class FoodDetailPage extends StatelessWidget {
  final FoodItem food;

  const FoodDetailPage({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.name),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              food.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text("Average Rating: ${food.rating.toStringAsFixed(1)} ★"),
            const SizedBox(height: 16),
            Text(
              food.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              "Reviews",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: food.reviews.isEmpty 
                ? const Center(child: Text("No reviews yet."))
                : ListView.builder(
                    itemCount: food.reviews.length,
                    itemBuilder: (context, index) {
                      final review = food.reviews[index];
                      return Card(
                        child: ListTile(
                          title: Text(review.reviewerName),
                          subtitle: Text("${review.stars} ★ - ${review.comment}"),
                        ),
                      );
                    },
                  ),
            )
          ],
        ),
      ),
    );
  }
}
