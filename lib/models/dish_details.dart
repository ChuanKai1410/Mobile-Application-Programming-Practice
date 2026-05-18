import 'ingredient.dart';

class DishDetails {
  final List<Ingredient> ingredients;
  final List<String> method;

  const DishDetails({
    required this.ingredients,
    required this.method,
  });
}

final aglioOlioDetails = DishDetails(
  ingredients: [
    const Ingredient(name: 'spaghetti', baseQuantity: 300, unit: 'g'),
    const Ingredient(name: 'cloves of garlic', baseQuantity: 4, unit: ''),
    const Ingredient(name: 'red pepperoni', baseQuantity: 2, unit: ''),
    const Ingredient(name: 'bunch of flat-leaf parsley', baseQuantity: 1, unit: ''),
    const Ingredient(name: 'olive oil or neutral vegetable oil', baseQuantity: 60, unit: 'ml'),
    const Ingredient(name: 'Sea salt and pepper', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Optional: grated Parmesan cheese', baseQuantity: 0, unit: ''),
  ],
  method: [
    'Wash the parsley, shake dry, pluck off the leaves and chop.',
    'Cut the chili peppers lengthwise, remove the seeds, wash and cut into thin strips or rings.',
    'Peel the garlic and slice thinly.',
    'Cook the spaghetti in plenty of boiling salted water for about 10 minutes until al dente.',
    'Drain and set aside.',
    'Heat oil in a pan and sauté the garlic, parsley, and chili pepper over medium heat for 2-3 minutes.',
    'Be careful that the garlic doesn\'t turn brown, otherwise it will become bitter.',
    'Add the spaghetti to the pan and toss to coat.',
    'Season with salt and pepper.',
    'Serve the spaghetti on preheated plates.',
  ],
);

final tomatoDetails = DishDetails(
  ingredients: [
    const Ingredient(name: 'Water for boiling', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Salt', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Spaghetti', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'tomatoes', baseQuantity: 5, unit: ''),
    const Ingredient(name: 'oil', baseQuantity: 1, unit: 'tbsp'),
    const Ingredient(name: 'finely chopped garlic', baseQuantity: 1, unit: 'tbsp'),
    const Ingredient(name: 'red chili flakes', baseQuantity: 2, unit: 'tsp'),
    const Ingredient(name: 'finely chopped onion', baseQuantity: 1, unit: ''),
    const Ingredient(name: 'Finely chopped capsicum', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Finely chopped carrot', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'salt', baseQuantity: 0.5, unit: 'tsp'),
    const Ingredient(name: 'red chili powder', baseQuantity: 1, unit: 'tsp'),
    const Ingredient(name: 'black pepper powder', baseQuantity: 0.5, unit: 'tsp'),
    const Ingredient(name: 'mixed herbs seasoning', baseQuantity: 1, unit: 'tsp'),
    const Ingredient(name: 'Basil leaves', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Sugar', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Tomato ketchup (optional)', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Fresh cream/fresh cheese', baseQuantity: 0, unit: ''),
  ],
  method: [
    'Boil water with salt in a large pot.',
    'Add spaghetti and cook until al dente, then drain.',
    'Heat oil in a pan over medium heat.',
    'Add garlic and sauté for 1 minute until fragrant.',
    'Add chopped onion and cook for 2-3 minutes until translucent.',
    'Add chopped capsicum and carrot, cook for 2-3 minutes.',
    'Add tomatoes and cook until softened (about 5 minutes).',
    'Add red chili flakes, chili powder, salt, pepper, and mixed herbs.',
    'Add basil leaves and a pinch of sugar for balance.',
    'Simmer the sauce for 5-10 minutes.',
    'Add tomato ketchup if desired for extra flavor.',
    'Combine cooked spaghetti with the sauce.',
    'Stir in fresh cream or cheese for richness.',
    'Serve hot and enjoy!',
  ],
);

final creamyGarlicDetails = DishDetails(
  ingredients: [
    const Ingredient(name: 'olive oil', baseQuantity: 2, unit: 'teaspoons'),
    const Ingredient(name: 'garlic cloves, minced', baseQuantity: 4, unit: ''),
    const Ingredient(name: 'butter', baseQuantity: 2, unit: 'tablespoons'),
    const Ingredient(name: 'chicken broth (or more as needed)', baseQuantity: 3, unit: 'cups'),
    const Ingredient(name: 'ground black pepper', baseQuantity: 0.5, unit: 'teaspoon'),
    const Ingredient(name: 'salt', baseQuantity: 0.25, unit: 'teaspoon'),
    const Ingredient(name: 'spaghetti', baseQuantity: 0.5, unit: 'pound'),
    const Ingredient(name: 'grated Parmesan cheese', baseQuantity: 1, unit: 'cup'),
    const Ingredient(name: 'heavy cream', baseQuantity: 0.75, unit: 'cup'),
    const Ingredient(name: 'dried parsley', baseQuantity: 1.5, unit: 'tablespoons'),
  ],
  method: [
    'Gather all ingredients.',
    'Heat olive oil in a medium pan over medium heat.',
    'Add minced garlic and stir until fragrant (1-2 minutes).',
    'Add butter and stir constantly until melted.',
    'Pour in 3 cups chicken broth; add pepper and salt.',
    'Bring to a boil.',
    'Add spaghetti and cook, stirring occasionally, until tender yet firm (about 12 minutes).',
    'Add more chicken broth if pasta starts to stick to the pan.',
    'Add Parmesan cheese, heavy cream, and dried parsley.',
    'Mix until thoroughly combined.',
    'Serve immediately while hot.',
  ],
);

final spicyDetails = DishDetails(
  ingredients: [
    const Ingredient(name: 'For Pasta:', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'salt', baseQuantity: 1, unit: 'tbsp'),
    const Ingredient(name: 'penne pasta (or spaghetti)', baseQuantity: 2, unit: 'cups'),
    const Ingredient(name: 'For Sauce:', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'olive oil', baseQuantity: 4, unit: 'tbsp'),
    const Ingredient(name: 'butter', baseQuantity: 2, unit: 'tbsp'),
    const Ingredient(name: 'cloves garlic (minced)', baseQuantity: 4, unit: ''),
    const Ingredient(name: 'chili flakes', baseQuantity: 1, unit: 'tsp'),
    const Ingredient(name: 'small onion (finely chopped)', baseQuantity: 1, unit: ''),
    const Ingredient(name: 'tomato paste', baseQuantity: 0.5, unit: 'cup'),
    const Ingredient(name: 'heavy cream', baseQuantity: 1, unit: 'cup'),
    const Ingredient(name: 'salt', baseQuantity: 0.25, unit: 'tsp'),
    const Ingredient(name: 'mixed herb', baseQuantity: 1, unit: 'tsp'),
    const Ingredient(name: 'black pepper', baseQuantity: 0.5, unit: 'tsp'),
    const Ingredient(name: 'Parmesan cheese', baseQuantity: 0.5, unit: 'cup'),
    const Ingredient(name: 'For Garnishing:', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Chili flakes', baseQuantity: 0, unit: ''),
    const Ingredient(name: 'Chopped coriander', baseQuantity: 0, unit: ''),
  ],
  method: [
    'Place a large pot on the stove and fill with water.',
    'Bring water to a rolling boil.',
    'Add 1 tbsp of salt to the water and 2 cups of pasta to the pot.',
    'Boil the pasta for about 8-10 minutes or according to package instructions.',
    'Stir occasionally.',
    'Reserve 1 cup of pasta water before draining.',
    'Drain the excess water and rinse under cold water to stop cooking.',
    'Set aside for later use.',
    'Bring a large pot and put it on the stove over medium heat.',
    'Pour 4 tbsp of olive oil into it.',
    'Add 2 tbsp of butter and let it melt.',
    'Add 4 cloves of minced garlic and 1 tsp of chili flakes.',
    'Cook for 1 minute while stirring frequently.',
    'Add 1 small finely chopped onion and cook for 2-3 minutes.',
    'Add 1/2 cup of tomato paste and cook for an additional 2-3 minutes.',
    'Pour in 1 cup of heavy cream and mix thoroughly.',
    'Sprinkle salt, mixed herb, and black pepper. Keep stirring.',
    'Add a little pasta water and let it simmer.',
    'Sprinkle 1/2 cup of grated parmesan cheese until fully melted.',
    'If sauce is too thick, add more reserved pasta water.',
    'Add cooked pasta to the sauce and toss gently.',
    'Garnish with chili flakes and chopped coriander.',
    'Serve on a plate with grated parmesan cheese on top.',
  ],
);

