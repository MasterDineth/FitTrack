/// How a glass surface obtains its frosted look.
enum GlassBackdrop {
  /// Default. glassFloating => live; glass1 / glass2 => flat.
  auto,

  /// Real BackdropFilter. Use ONLY when something non-uniform is painted beneath the surface:
  /// scrolling content, another card, an image, text. (dock, island, shade, sheets, pinned bars)
  live,

  /// Fill + border + top highlight + shadow, no BackdropFilter. Use for in-flow cards over the static mesh.
  flat,
}
