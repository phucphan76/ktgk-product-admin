/// Cloudinary settings for unsigned uploads from the client.
/// An unsigned upload preset is designed to be used from apps; it is not a secret.
class AppConfig {
  AppConfig._();

  static const cloudinaryCloudName = 'gx3dk3gu';
  static const cloudinaryUploadPreset = 'ktgk_products';

  static bool get cloudinaryConfigured =>
      !cloudinaryCloudName.startsWith('YOUR_') && !cloudinaryUploadPreset.startsWith('YOUR_');
}
