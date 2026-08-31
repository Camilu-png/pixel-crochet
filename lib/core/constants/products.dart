import '../../generated/app_localizations.dart';

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

/// Returns the promotional sample products with locale-aware copy.
List<Product> sampleProducts(AppLocalizations l10n) => [
      Product(
        imagePath: 'assets/products/cardigan_mariposa.png',
        title: l10n.productMariposaTitle,
        description: l10n.productMariposaDesc,
        kofiUrl: 'https://ko-fi.com/s/b121095f37',
      ),
      Product(
        imagePath: 'assets/products/salchipleto.png',
        title: l10n.productSalchipletoTitle,
        description: l10n.productSalchipletoDesc,
        kofiUrl: 'https://ko-fi.com/s/93a6e28a6c',
      ),
    ];

