import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:obl_ihc_pruebasconflutter/entities/Product.dart';
import 'package:obl_ihc_pruebasconflutter/utils.dart';
import 'package:obl_ihc_pruebasconflutter/views/editproduct_page.dart';
import 'package:obl_ihc_pruebasconflutter/views/loading.dart';
import 'package:obl_ihc_pruebasconflutter/views/recommendedproducts_section.dart';

// ==========================
// Vista
// ==========================
class ProductDetailPage extends StatefulWidget {
  late Product product;
  late List<Product> recommendedProducts;
  final bool showDetails;
  final bool ask;
  final bool withBarcode;

  ProductDetailPage({
    required this.product,
    required this.recommendedProducts,
    this.showDetails = true,
    required this.ask,
    required this.withBarcode
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState(
      product,
      recommendedProducts,
      showDetails,
      ask,
      withBarcode
  );
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product product;
  late List<Product> recommendedProducts;
  final bool showDetails;
  bool loadingRecommendedProducts = true;
  bool ask = false;
  bool withBarcode = true;

  _ProductDetailPageState(this.product, this.recommendedProducts, this.showDetails, this.ask, this.withBarcode);

  @override
  void initState() {
    super.initState();
    getRecommendedProducts(product, ask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del producto'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Información ambiental:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.product.environmentalInfo!,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Text('Descripción:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.product.description!,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              if (widget.showDetails) ...[
                SizedBox(height: 20),
                Center(
                  child: withBarcode ? Image.network(
                    widget.product.imageUrl!,
                    width: 100,
                  ) : Image.file(
                    widget.product.imageFile!,
                    width: 100,
                  ),
                ),
                SizedBox(height: 20),
                if (widget.withBarcode) ...[
                  Center(
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProductPage(widget.product),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      label: Text('Editar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 6),
                Divider(
                  color: Colors.grey,
                  thickness: 2.0,
                  height: 20,
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(height: 20),
                Text('Productos recomendados:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder(
                    future: Future.value(recommendedProducts),
                    builder: (context, snapshot) {
                      if (loadingRecommendedProducts) {
                        return LoadingIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        if (recommendedProducts.isEmpty) {
                          return Text(
                            'No se encontraron recomendaciones para el producto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          );
                        } else {
                          return RecommendedProductsSection(recommendedProducts);
                        }
                      }
                      return Container();
                    }
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // Lógica
  // ==========================
  Future<void> getRecommendedProducts(Product scannedProduct, bool ask) async {
    if (!ask) return;

    String filter = scannedProduct.name;
    filter = Utils.removeDiacritics(filter);
    filter = filter.toUpperCase();

    try {
      Map<String, String> headers = { 'Authorization': 'ihc', };
      http.Response response = await http.get(Uri.parse('https://ihc.gil.com.uy/api/recommendedProducts?filter=${filter}'),
          headers: headers
      );

      var data = json.decode(response.body);
      List<Product> recommendedProd = [];

      if (data != null) {
        for (var p in data) {
          var x = Product(
              name: p["name"],
              description: p["description"],
              imageUrl: "",
              environmentalInfo: p["environmentalInfo"],
              category: p["category"],
              environmentalCategory: p["environmentalCategory"]
          );

          recommendedProd.add(x);
        }
      }

      setState(() {
        recommendedProducts = recommendedProd;
        loadingRecommendedProducts = false;
      });
    } catch (e) {
      setState(() {
        recommendedProducts = [];
        loadingRecommendedProducts = false;
      });
    }
  }
}
