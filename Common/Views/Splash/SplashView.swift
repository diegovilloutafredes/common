//
//  SplashView.swift
//

import UIKit

// MARK: - SplashView
public final class SplashView: BaseViewModelableView<SplashViewModelProtocol> {
    @UIViewBuilder public override var mainView: UIView {
        UIImageView()
            .contentMode(.scaleAspectFit)
            .image(viewModel?.image)
            .setRatio()
            .setConstraints { 
                $0.alignCenter(with: $1)
                $0.setWidth(to: $1.widthAnchor, multiplier: 0.3)
            }
    }

    public required init(viewModel: any SplashViewModelProtocol = SplashViewModel()) {
        super.init(viewModel: viewModel)
    }

    public override func setupView() {
        backgroundColor(viewModel?.backgroundColor)
    }
}
