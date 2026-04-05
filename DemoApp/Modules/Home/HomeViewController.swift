//
//  HomeViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - HomeViewProtocol
typealias HomeViewProtocol = ScreenSizeMeasurable

// MARK: - HomeViewController
final class HomeViewController: BaseViewModelableViewController<HomeViewModelProtocol> {
    private lazy var list = VList(dataSource: self, delegate: self)
        .register(DemoFeatureCell.self)

    @UIViewBuilder
    override var mainView: UIView {
        list.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemGroupedBackground)
    }
}
