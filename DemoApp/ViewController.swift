//
//  ViewController.swift
//  DemoApp
//

import Common
import UIKit

final class ViewController: BaseViewController {
    @UIViewBuilder
    override var mainView: UIView {
        UILabel(Bundle.main.displayName)
            .font(.systemFont(ofSize: 32))
            .textAlignment(.center)
            .textColor()
            .setConstraints { $0.alignCenter(with: $1) }
    }

    override func setupView() {
        backgroundColor(.red)
    }
}

#Preview {
    ViewController()
}
