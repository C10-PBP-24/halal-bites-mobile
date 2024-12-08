import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const FoodReviewPage(),
    theme: ThemeData(
      primaryColor: Colors.yellow[700],
      colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.yellow[700]),
    ),
  ));
}

class FoodItem {
  String name;
  double rating;
  String description;
  List<Review> reviews;

  FoodItem({
    required this.name,
    required this.rating,
    required this.description,
    required this.reviews,
  });

  double get averageRating {
    if (reviews.isEmpty) return 0;
    double sum = reviews.fold(0, (acc, r) => acc + r.rating);
    return sum / reviews.length;
  }
}

class Review {
  String reviewerName;
  double rating;
  String comment;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });
}

class FoodReviewPage extends StatefulWidget {
  const FoodReviewPage({Key? key}) : super(key: key);

  @override
  _FoodReviewPageState createState() => _FoodReviewPageState();
}

class _FoodReviewPageState extends State<FoodReviewPage> {
  List<FoodItem> allFoods = [
    FoodItem(
      name: "Margherita Pizza",
      rating: 4.5,
      description: "A classic pizza with fresh tomatoes, mozzarella and basil.",
      reviews: [
        Review(reviewerName: "Alice", rating: 5, comment: "Delicious!"),
        Review(reviewerName: "Bob", rating: 4, comment: "Quite good."),
      ],
    ),
    FoodItem(
      name: "House Special Pizza",
      rating: 4.7,
      description: "Loaded with sausage, mushrooms, olives, peppers, and onions.",
      reviews: [
        Review(reviewerName: "Carol", rating: 5, comment: "My favorite!"),
        Review(reviewerName: "Dan", rating: 4.5, comment: "Really tasty."),
      ],
    ),
    FoodItem(
      name: "Vegetarian Pizza",
      rating: 4.3,
      description: "A healthy mix of broccoli, mushrooms, olives, and peppers.",
      reviews: [
        Review(reviewerName: "Eve", rating: 4, comment: "Good flavors."),
      ],
    ),
    FoodItem(
      name: "Meat Eaters Pizza",
      rating: 4.8,
      description: "Pepperoni, sausage, meatballs, and ham for carnivores.",
      reviews: [
        Review(reviewerName: "Frank", rating: 5, comment: "Fantastic!"),
        Review(reviewerName: "Grace", rating: 4.5, comment: "Great taste."),
      ],
    ),
  ];

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
    // Filter foods based on search
    List<FoodItem> filteredFoods = allFoods.where((food) {
      return food.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Sort by rating to get top rated
    List<FoodItem> sortedByRating = List.from(allFoods);
    sortedByRating.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    List<FoodItem> topRated = sortedByRating.take(3).toList();

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
                    children: topRated.map((food) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailPage(food: food),
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
                                  backgroundColor: Colors.yellow[700],
                                  child: Text(
                                    food.averageRating.toStringAsFixed(1),
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
                                      food.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                        "Rating: ${food.averageRating.toStringAsFixed(1)} ★"),
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
                children: filteredFoods.map((food) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailPage(food: food),
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
                            food.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "Rating: ${food.averageRating.toStringAsFixed(1)} ★"),
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
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
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
                    TextField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        labelText: "Food Name",
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
                            if (name.isEmpty) return;
                            // Check if food exists
                            FoodItem existing = allFoods.firstWhere(
                              (f) => f.name.toLowerCase() == name.toLowerCase(),
                              orElse: () => FoodItem(
                                name: name,
                                rating: 0,
                                description:
                                    desc.isEmpty ? "No description" : desc,
                                reviews: [],
                              ),
                            );

                            if (!allFoods.contains(existing)) {
                              allFoods.add(existing);
                            }

                            existing.reviews.add(
                              Review(
                                reviewerName: "Anonymous",
                                rating: _selectedRating,
                                comment: desc,
                              ),
                            );

                            setState(() {
                              // Update UI
                            });

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
        });
      },
    );
  }
}

class FoodDetailPage extends StatelessWidget {
  final FoodItem food;

  const FoodDetailPage({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Review> reviews = food.reviews;
    double avgRating = food.averageRating;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          food.name,
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
                food.name,
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
                food.description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                "Reviews",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Column(
                children: reviews.map((r) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        r.reviewerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${r.rating} ★ - ${r.comment}"),
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
