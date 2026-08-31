class Product {
  const Product({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.kofiUrl,
  });

  final String imagePath;
  final String title;
  final String description;
  final String kofiUrl;
}

const List<Product> sampleProducts = [
  Product(
    imagePath: 'assets/products/cardigan_mariposa.png',
    title: 'Cardigan de Mariposa Talla L',
    description:
        'Conviértete en una bella mariposa del bosque con este hermoso cardigan.',
    kofiUrl: 'https://ko-fi.com/s/b121095f37',
  ),
  Product(
    imagePath: 'assets/products/salchipleto.png',
    title: 'Salchipleto',
    description: 'Un delicioso amigo que te acompaña siempre.',
    kofiUrl: 'https://ko-fi.com/s/93a6e28a6c',
  ),
];
