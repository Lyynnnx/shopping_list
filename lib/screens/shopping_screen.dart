import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/providers/item_list_provider.dart';
import 'package:shopping_list/widgets/new_item.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  

  void initState() {
    super.initState();
      Future.delayed(Duration.zero, () {
      ref.read(listProvider.notifier).getList(ref);
    });
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.forward();
  }
  

  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void addItem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );
  }
  void updateList(){
     ref.watch(listProvider.notifier).getList(ref);
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = ref.read(isLoadingProvdier); //в провайдере сначала true
    final List<GroceryItem> items = ref.watch(listProvider);
     Widget currentBody = const Center(child: Text('No Food :('));
     if(isLoading) { //пока true, показываем крутилку
      currentBody = const Center(child:  CircularProgressIndicator());
     }
    if (!ref.watch(listProvider).isEmpty) {
      currentBody= AnimatedBuilder(
        builder: (context, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
                      .chain(CurveTween(curve: Curves.bounceOut))
                      .animate(animationController),
              child: child);
        },
        animation: animationController,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Dismissible(
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.green,
                child: Icon(Icons.delete),
              ),
              onDismissed: (direction) => ref
                  .read(listProvider.notifier)
                  .removeItem(items[index]),
              key: ValueKey(items[index].id),
              child: ListTile(
                leading: Icon(
                  Icons.square,
                  color: items[index].category.color,
                ),
                title: Text(items[index].name),
                trailing: Text(
                  items[index].quantity.toString(),
                ),
              ),
            );
          },
          itemCount: items.length,
        ),
      );
    }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: () {
                addItem(context);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: currentBody,
      );
    }
  }

