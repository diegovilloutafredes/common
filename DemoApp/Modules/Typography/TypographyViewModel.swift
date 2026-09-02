//
//  TypographyViewModel.swift
//  DemoApp
//

import Common
import Observation
import UIKit

// MARK: - TypographyViewModelProtocol
@MainActor
protocol TypographyViewModelProtocol: ViewModel {
    var title: String { get }
    var families: [(family: AppFontFamily, name: String)] { get }
    var selectedFamily: AppFontFamily { get }
    var previewStyles: [UIFont.FontStyle] { get }
    func select(family: AppFontFamily)
}

// MARK: - TypographyViewModel
@Observable
@MainActor
final class TypographyViewModel {
    let title = "Typography"

    let families: [(family: AppFontFamily, name: String)] = [
        (.montserrat, "Montserrat"),
        (.inter,      "Inter"),
        (.poppins,    "Poppins"),
        (.lato,       "Lato"),
    ]

    let previewStyles: [UIFont.FontStyle] = [.light, .regular, .medium, .semiBold, .bold, .italic]

    private(set) var selectedFamily: AppFontFamily = .montserrat
}

// MARK: - TypographyViewModelProtocol
extension TypographyViewModel: TypographyViewModelProtocol {
    func select(family: AppFontFamily) {
        guard selectedFamily != family else { return }
        selectedFamily = family
    }
}
