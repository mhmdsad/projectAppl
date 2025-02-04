import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'project_appl',
      home: ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.readAllProducts();
    setState(() {
      _products = products;
    });
  }

  void _addProduct() async {
    final name = nameController.text;
    final description = descriptionController.text;
    final price = double.tryParse(priceController.text);

    if (name.isEmpty || description.isEmpty || price == null) return;

    final product = {
      'name': name,
      'description': description,
      'price': price,
    };

    await DatabaseHelper.instance.createProduct(product);
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    _loadProducts();
  }

  void _editProduct(int id) async {
    final name = nameController.text;
    final description = descriptionController.text;
    final price = double.tryParse(priceController.text);

    if (name.isEmpty || description.isEmpty || price == null) return;

    final product = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };

    await DatabaseHelper.instance.updateProduct(product);
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    _loadProducts();
  }

  void _deleteProduct(int id) async {
    await DatabaseHelper.instance.deleteProduct(id);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Manager"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addProduct,
                  child: Text('Add Product'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _editProduct(1), // مثلا تعديل العنصر رقم 1
                  child: Text('Edit Product'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text('${product['description']} - \$${product['price']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteProduct(product['id']),
                    ),
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
