import 'package:flutter/material.dart';
import '../models/spaghetti_dish.dart';
import 'dish_widgets.dart';

class DishDetailContent extends StatefulWidget {
  final SpaghettiDish dish;
  final List<String> ingredients;
  final List<String> method;

  const DishDetailContent({
    super.key,
    required this.dish,
    required this.ingredients,
    required this.method,
  });

  @override
  State<DishDetailContent> createState() => _DishDetailContentState();
}

class _DishDetailContentState extends State<DishDetailContent> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1000;
        final isTablet = width >= 650 && width < 1000;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                  child: _buildImagePanel(),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
                  child: _buildTabbedPanel(contentPadding: 20),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(isTablet ? 16 : 10, 12, isTablet ? 16 : 10, 10),
              height: isTablet ? 300 : 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.dish.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant, size: 56, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isTablet ? 16 : 10, 0, isTablet ? 16 : 10, 12),
                child: _buildTabbedPanel(contentPadding: isTablet ? 16 : 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Image.asset(
                widget.dish.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              widget.dish.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabbedPanel({required double contentPadding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              color: Colors.white,
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Dish'),
                _buildTabButton(1, 'Ingredients'),
                _buildTabButton(2, 'Method'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedTabIndex == 0) ...[
                    _buildDishTab(),
                  ] else if (_selectedTabIndex == 1) ...[
                    _buildIngredientsTab(),
                  ] else ...[
                    _buildMethodTab(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent,
                width: 3,
              ),
            ),
            color: isSelected ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFD32F2F) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDishTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFFF9C4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          boxedSection(
            Text(
              widget.dish.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                fontSize: 22,
              ),
            ),
          ),
          boxedSection(
            Text(
              'Price: ${widget.dish.price}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
            ),
          ),
          boxedSection(
            Text(
              widget.dish.description,
              textAlign: TextAlign.center,
              style: descTextStyle,
            ),
          ),
          ratings(widget.dish),
          const SizedBox(height: 16),
          iconList(widget.dish),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 16),
          ...widget.ingredients.map((ingredient) {
            final isCategory = ingredient.endsWith(':');
            final cleanedIngredient = ingredient.replaceFirst(RegExp(r'^\s*•\s*'), '');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCategory)
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      cleanedIngredient,
                      style: TextStyle(
                        fontSize: isCategory ? 16 : 15,
                        fontWeight: isCategory ? FontWeight.bold : FontWeight.w500,
                        color: isCategory ? const Color(0xFFD32F2F) : const Color(0xFF424242),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMethodTab() {
    var stepNumber = 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.method.length, (index) {
            final step = widget.method[index];
            final isHeader = step.endsWith(':');
            if (!isHeader) {
              stepNumber += 1;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isHeader)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$stepNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: isHeader ? 16 : 15,
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                        color: isHeader ? const Color(0xFFD32F2F) : const Color(0xFF424242),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
