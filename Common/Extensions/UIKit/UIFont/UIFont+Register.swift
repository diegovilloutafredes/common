//
//  UIFont+Register.swift
//

import UIKit

extension UIFont {
    public enum RegisterFontError: Error {
      case invalidFontFile
      case fontPathNotFound
      case initFontError
      case registerFailed
    }

    /// Registers custom fonts from the specified bundle.
    /// - Parameters:
    ///   - names: List of font family names.
    ///   - styles: List of font styles to register. Defaults to all cases.
    ///   - type: File extension (e.g., "ttf"). Defaults to "ttf".
    ///   - bundle: The bundle containing the font files. Defaults to `.main`.
    public static func register(fonts names: [Uppercaseable], styles: [FontStyle] = FontStyle.allCases, type: String = "ttf", on bundle: Bundle = .main) {
        names.forEach { name in
            styles.forEach { style in
                let fileName = "\(name.uppercasingFirstLetter)-\(style.uppercasingFirstLetter)"
                do { try register(fileName, type: type, on: bundle) }
                catch {
                    Logger.log(["error": error])
                    Logger.log(["bundle": bundle])
                    Logger.log(["fileName": fileName])
                }
            }
        }
    }

    /// Registers a single font file.
    /// - Parameters:
    ///   - fileName: The name of the font file (without extension).
    ///   - type: The file extension.
    ///   - bundle: The bundle containing the file. Defaults to `.main`.
    /// - Throws: `RegisterFontError` if registration fails.
    public static func register(_ fileName: String, type: String, on bundle: Bundle = .main) throws {
        guard let resourceBundleURL = bundle.path(forResource: fileName, ofType: type)
        else { throw RegisterFontError.fontPathNotFound }

        guard
            let fontData = NSData(contentsOfFile: resourceBundleURL),
            let dataProvider = CGDataProvider(data: fontData)
        else { throw RegisterFontError.invalidFontFile }

        guard let fontRef = CGFont(dataProvider)
        else { throw RegisterFontError.initFontError }

        var errorRef: Unmanaged<CFError>? = nil

        guard CTFontManagerRegisterGraphicsFont(fontRef, &errorRef)
        else { throw RegisterFontError.registerFailed }
    }
}
