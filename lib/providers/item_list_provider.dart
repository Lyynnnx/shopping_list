import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class ListNotifier extends StateNotifier<List<GroceryItem>> {
  ListNotifier() : super([]);

  void addItem(GroceryItem item, WidgetRef ref) async {
    // ref.read(isLoadingProvdier.notifier).state=true;
    final url = Uri.https('flutter-prep-d00b4-default-rtdb.firebaseio.com',
        '10april.json'); //для запросов на https
    //мы сначала кидаем главную ссылку, потом через кому конкретнее указываем ссылку и добавляем .json в конце
    //final url = Uri.http('flutter-prep-d00b4-default-rtdb.firebaseio.com/'); //для запросов на http
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': item.name,
          'quantity': item.quantity,
          'category': item.category.name
        }));
    //значит, для запроса нам нужна ссылка, потом headers всегда одинаковы, и body сначала шифруем и отправляем то, что хотим
    if (response.statusCode < 400) {
      print('nice');
    } else {
      print('bad');
      print('but its ok');
      return;
    }
    //ref.read(isLoadingProvdier.notifier).state=false;
    state = [...state, item];
  }

  void removeItem(GroceryItem item) {
    state = state.where((element) => element.id != item.id).toList();
  }





  void getList(WidgetRef ref) async {
    ref.read(isLoadingProvdier.notifier).update((ref) => true);
    final url = Uri.https('flutter-prep-d00b4-default-rtdb.firebaseio.com',
        '10april.json'); //указываем ссылку
    final response = await http.get(url,
       ); //получаем json
    if (response.statusCode >= 400) {
      log('error');
      return;
    }
    final data = json.decode(response.body)
        as Map<String, dynamic>; //если все ок, расшифровываем ответ
    final List<GroceryItem> ourList = data.entries
        .map((e) => GroceryItem(
            id: e.key,
            name: e.value['name'],
            quantity: e.value['quantity'],
            category: categories.entries
                .firstWhere(
                  (element) => element.value.name == e.value['category'],
                )
                .value),)
        .toList();
    if (ourList.isEmpty) {
      state = [];
      return;
    }
    ref.read(isLoadingProvdier.notifier).update((ref) => false);
    //проходимся по каждому элементу, создаем GroceryItem, ищем категорию по имени, и добавляем в список
    state = ourList; //присваиваем нашему списку
  }
}

final listProvider = StateNotifierProvider<ListNotifier, List<GroceryItem>>(
    (ref) => ListNotifier());

final nameProvider = StateProvider<String>((ref) => '');
final quantityProvider = StateProvider<int>((ref) => 0);
final categoryProvider =
    StateProvider<Category>((ref) => categories[Categories.other]!);

class InfoNotifier extends StateNotifier<Map<String, dynamic>> {
  InfoNotifier()
      : super({
          'name': '',
          'quantity': 0,
          'category': categories[Categories.other]!
        });

  void updateName(String name) {
    state = state..['name'] = name;
  }

  void updateQuantity(int quantity) {
    state = state..['quantity'] = quantity;
  }

  void updateCategory(Category category) {
    state = state..['category'] = category;
  }

  void updateEveything(String name, int quantity, Category category) {
    state = state
      ..['name'] = name
      ..['quantity'] = quantity
      ..['category'] = category;
  }
}

final infoProvider = StateNotifierProvider<InfoNotifier, Map<String, dynamic>>(
    (ref) => InfoNotifier());

final isLoadingProvdier = StateProvider<bool>((ref) => true);
final addingItemLoadingProvider = StateProvider<bool>((ref) => false);
