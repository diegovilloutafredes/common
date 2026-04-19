//
//  OnboardingViewController.swift
//

import Common
import UIKit

// MARK: - View
typealias OnboardingViewProtocol = ScreenSizeMeasurable & NavigationBarVisibilityTogglable


// MARK: - OnboardingViewController
final class OnboardingViewController: BaseViewModelableViewController<OnboardingViewModelProtocol> {
    enum OnboardingStep: Int {
        case first = 0
        case second
        case third

        var buttonTitle: String {
            switch self {
            case .third: "Comenzar"
            default: "Siguiente"
            }
        }
    }

    private lazy var list = HList(
        dataSource: self,
        delegate: self
    ) {
        $0.minimumInteritemSpacing(.zero)
        $0.minimumLineSpacing(.zero)
    }
        .clipsToBounds(false)
        .isPagingEnabled(true)
        .register(OnboardingCell.self)

    private lazy var pageControl = UIPageControl()
        .isUserInteractionEnabled(false)
        .currentPage(.zero)
        .currentPageIndicatorTintColor(.black)
        .numberOfPages(viewModel.getNumberOfItems(in: .zero))
        .pageIndicatorTintColor(.black.withAlphaComponent(0.3))
        .setConstraints { $0.set(height: 32) }

    private lazy var actionButton = UIButton()
        .onTap(onActionButtonPressed)
        .setRatio(327/60)

    @UIViewBuilder
    override var mainView: UIView {
        VStack(spacing: 8) {
            list
            pageControl
            VStack(margins: .init(top: .zero, left: 24, bottom: 24, right: 24)) { actionButton }
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        currentPage = .zero
    }

    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage

            actionButton.configuration = .filled()
                .with {
                    $0.attributedTitle = .init(
                        currentStep?.buttonTitle ?? .empty,
                        attributes: .init()
                            .with { $0.font = .appFont(style: .bold, size: 14) }
                    )
                    $0.baseBackgroundColor = .black
                    $0.baseForegroundColor = .white
                    $0.cornerStyle = .capsule
                }

            on(step: currentStep)
        }
    }

    private var currentStep: OnboardingStep? { .init(rawValue: currentPage) }
    private var lastPageIndex: Int { viewModel.getNumberOfItems(in: .zero) - 1 }

    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x/pageWidth))
        currentPage = page
    }
}

// MARK: - Button handler
extension OnboardingViewController {
    @objc private func onSkipButtonPressed() { viewModel.onRequested(.skip) }
}

// MARK: - Convenience
extension OnboardingViewController {
    private func onActionButtonPressed() {
        guard currentPage < lastPageIndex else { viewModel.onRequested(.begin); return }
        currentPage += 1
        list.setContentOffset(.init(x: list.frame.width * Double(currentPage), y: .zero), animated: false)
    }

    private func on(step: OnboardingStep? = nil) {
        switch step {
        case .third:
            navigationItem.setRightBarButtonItems(nil, animated: true)
        default:
            navigationItem.setRightBarButton(
                .init(
                    title: "Saltar",
                    style: .plain,
                    target: self,
                    action: #selector(onSkipButtonPressed)
                ),
                animated: true
            )

            setupNavigationBar()
        }
    }

    private func setupNavigationBar() {
        setNavigationBar(
            leftBarButtonItemTintColor: .black,
            rightBarButtonItemTintColor: .black,
            barButtonItemFont: .appFont(style: .bold, size: 14)
        )
    }
}

// MARK: - Preview
#if canImport(SwiftUI) && compiler(>=5.9)
import SwiftUI
@available(iOS 17.0, *)
#Preview {
    OnboardingWireframe.createModule { _ in }
}
#endif
