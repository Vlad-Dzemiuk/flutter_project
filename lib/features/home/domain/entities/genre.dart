/// Domain entity для жанру
///
/// Це чиста domain entity без залежностей від data layer
class GenreEntity {
  final int id;
  final String name;

  const GenreEntity({required this.id, required this.name});
}
