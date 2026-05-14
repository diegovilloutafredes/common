
// MARK: - AppFontFamily
/// An extensible font family identifier. Set `rawValue` to the PostScript base name of the font
/// family (e.g. `"montserrat"` → resolves to `"Montserrat-Bold"`, `"Montserrat-Regular"`, etc.).
///
/// Extend this type in your app target to declare your own families:
/// ```swift
/// extension AppFontFamily {
///     static let montserrat  = AppFontFamily(rawValue: "montserrat")
///     static let varelaRound = AppFontFamily(rawValue: "varelaRound")
/// }
/// ```
public struct AppFontFamily: RawRepresentable, Hashable, Uppercaseable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}
