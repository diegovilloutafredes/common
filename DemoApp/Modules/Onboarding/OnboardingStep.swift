//
//  OnboardingStep.swift
//

import UIKit

// MARK: - OnboardingStep
enum OnboardingStep: Int, OnboardingCellViewModel {
    case first = 0
    case second
    case third

    var title: String {
        switch self {
        case .first: "Con \(Bundle.main.displayName) pagar es fácil y seguro"
        case .second: "El código se actualiza cada 60 segundos"
        case .third: "Solo debes compartir tu código en las cajas para autorizar tus compras"
        }
    }

    var subtitle: String {
        switch self {
        case .first: "Sólo necesitas tu código para autorizar tu compra en sólo segundos"
        case .second: "Cada código es único, sólo tú lo conoces, y es válido por una única vez"
        case .third: "Para aceptar tu compra, entrega o digita tu código en caja"
        }
    }

    var image: UIImage? {
        switch self {
        case .first: .init(systemName: "cart.fill")
        case .second: .init(systemName: "clock.badge.checkmark.fill")
        case .third: .init(systemName: "qrcode.viewfinder")
        }
    }
}
