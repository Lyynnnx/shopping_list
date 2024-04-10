import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/providers/item_list_provider.dart';
import 'package:uuid/uuid.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key});

  @override
  ConsumerState<NewItem> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem> {


  final formKey = GlobalKey<FormState>();
  bool isSending = false;

  void saveItem(){
    bool isOk=formKey.currentState!.validate();
    setState((){    isSending=true;});
   // isSending=true;
    if(isOk){
      formKey.currentState!.save();
      String id=Uuid().v4();
      String name= ref.read(infoProvider)['name'];
      int quantity= ref.read(infoProvider)['quantity'];
      Category category= ref.read(infoProvider)['category'];
      Future.delayed(Duration.zero, () {
        ref.read(listProvider.notifier).addItem(GroceryItem(id: id, name: name, quantity: quantity, category: category), ref);
    });
   
      //ref.read(listProvider.notifier).getList(ref);

      Navigator.of(context).pop();
    }
    else{
      
     // return;
    }
    isSending=false;
  }
  @override
  Widget build(BuildContext context) {
    // bool isLoading = ref.read(addingItemLoadingProvider);
     bool isLoading = false;
    Widget activeScreen= Padding(
        padding: const EdgeInsets.all(0),
        child: Form(
          
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved:(newValue) => ref.watch(infoProvider.notifier).updateName(newValue!),
                decoration: const InputDecoration(
                  label: Text('cringe'),
                ),
                validator: (value){
                  if(value==null || value.isEmpty || value.trim().length<=3){
                    return "Please enter a normal name";
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      onSaved: (newValue)=> ref.watch(infoProvider.notifier).updateQuantity(int.parse(newValue!)),
                      
                      cursorErrorColor: Colors.green,
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                        hintText: 'Enter Integer Value',
                      ),
                      validator: (value) {
                        if(value==null || value.isEmpty || int.tryParse(value)==null|| int.tryParse(value)!<=0){
                                return "Error message"; //Если введена фигня, то напиши ошибку
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      validator: (value){
                        if(value==null){
                          return "Please, select something";
                        }
                        else{
                          return null;
                        }
                      },
                      onSaved: (newValue)=>ref.watch(infoProvider.notifier).updateCategory(newValue!),
                      onChanged: (newValue)=>ref.watch(infoProvider.notifier).updateCategory(newValue!),
                      items: [
                      ...categories.entries.map(
                        (e) {
                          return DropdownMenuItem(
                            value: e.value,
                            child: Row(
                              children: [
                                Container(
                                    width: 16,
                                    height: 16,
                                    color: e.value.color),
                                const SizedBox(width: 10),
                                Text(e.value.name),
                              ],
                            ),
                          );
                        },
                      ),
                    ], ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () { isSending? null:formKey.currentState!.reset();},
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed:saveItem,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
       if(isSending){
         activeScreen=const Center(child: CircularProgressIndicator());
      }
      






    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
      ),
      body: activeScreen,
    );
  }
}
