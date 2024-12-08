import 'package:flutter/material.dart';
// Import the Rating model
import '../models/rating.dart';

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
  // Replace List<FoodItem> with List<Rating>
  List<Rating> allRatings = [
    Rating(
      id: '1',
      food: Food(id: '1', name: 'Margherita Pizza'),
      user: User(id: '1', username: 'Alice'),
      rating: 5,
      description: 'Delicious!',
      createdAt: DateTime.now(),
    ),
    Rating(
      id: '2',
      food: Food(id: '1', name: 'Margherita Pizza'),
      user: User(id: '2', username: 'Bob'),
      rating: 4,
      description: 'Quite good.',
      createdAt: DateTime.now(),
    ),
    Rating(
      id: '3',
      food: Food(id: '2', name: 'House Special Pizza'),
      user: User(id: '3', username: 'Carol'),
      rating: 5,
      description: 'My favorite!',
      createdAt: DateTime.now(),
    ),
    Rating(
      id: '4',
      food: Food(id: '2', name: 'House Special Pizza'),
      user: User(id: '4', username: 'Dan'),
      rating: 4,
      description: 'Really tasty.',
      createdAt: DateTime.now(),
    ),
    Rating(
      id: '5',
      food: Food(id: '3', name: 'Vegetarian Pizza'),
      user: User(id: '5', username: 'Eve'),
      rating: 4,
      description: 'Good flavors.',
      createdAt: DateTime.now(),
    ),
    Rating(
      id: '6',
      food: Food(id: '4', name: 'Meat Eaters Pizza'),
      user: User(id: '6', username: 'Frank'),
      rating: 5,
      description: 'Fantastic!',
      createdAt: DateTime.now(),
    ),
    Rating(
      id: '7',
      food: Food(id: '4', name: 'Meat Eaters Pizza'),
      user: User(id: '7', username: 'Grace'),
      rating: 4,
      description: 'Great taste.',
      createdAt: DateTime.now(),
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
    // Filter ratings based on the search query
    List<Rating> filteredRatings = allRatings.where((rating) {
      return rating.food.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Group ratings by food to calculate average ratings
    Map<String, List<Rating>> ratingsByFood = {};
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

                            // Create new Rating instance
                            Rating newRating = Rating(
                              id: DateTime.now().toString(),
                              food: Food(id: 'new', name: name),
                              user: User(id: 'anonymous', username: 'Anonymous'),
                              rating: _selectedRating.toInt(),
                              description: desc.isEmpty ? "No description" : desc,
                              createdAt: DateTime.now(),
                            );

                            setState(() {
                              allRatings.add(newRating);
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
  final String foodName;
  final List<Rating> ratings;

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
