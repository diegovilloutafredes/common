//
//  OnboardingViewController.swift
//

import Common
import UIKit

// MARK: - OnboardingViewController
final class OnboardingViewController: BaseCollectionViewableViewController<OnboardingViewModelProtocol> {

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
        .pageIndicatorTintColor(.black.withAlphaComponent(0.3))
        .setConstraints { $0.set(height: 32) }

    private lazy var actionButton = UIButton()
        .onTap { [weak self] in self?.viewModel.advance() }
        .setRatio(327/60)

    /// Guards the animated bar-item swap so it only runs when the observed state flips.
    private var renderedShowsSkip: Bool?

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
        pageControl.numberOfPages(viewModel.pageCount)
    }

    /// Every `viewModel` read here is tracked: swiping (via `set(currentPage:)`) and the
    /// button (via `advance()`) both land here, with no `didSet` in between.
    override func updateContent() {
        super.updateContent()
        let page = viewModel.currentPage
        pageControl.currentPage = page

        actionButton.configuration = .filled()
            .with {
                $0.attributedTitle = .init(
                    viewModel.buttonTitle,
                    attributes: .init()
                        .with { $0.font = .appFont(style: .bold, size: 14) }
                )
                $0.baseBackgroundColor = .black
                $0.baseForegroundColor = .white
                $0.cornerStyle = .capsule
            }

        scrollToPageIfNeeded(page)
        renderSkipItem(viewModel.showsSkip)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        guard pageWidth > 0 else { return }
        viewModel.set(currentPage: Int(round(scrollView.contentOffset.x / pageWidth)))
    }
}

// MARK: - Convenience
extension OnboardingViewController {
    /// A page change that came from the button (not from a swipe) leaves the pager behind;
    /// bring it to the observed page. Swipes already have the pager on that page.
    private func scrollToPageIfNeeded(_ page: Int) {
        let pageWidth = list.frame.width
        guard pageWidth > 0 else { return }
        let visiblePage = Int(round(list.contentOffset.x / pageWidth))
        guard visiblePage != page else { return }
        list.setContentOffset(.init(x: pageWidth * Double(page), y: .zero), animated: false)
    }

    private func renderSkipItem(_ showsSkip: Bool) {
        guard renderedShowsSkip != showsSkip else { return }
        renderedShowsSkip = showsSkip
        if showsSkip {
            navigationItem.setRightBarButton(
                .init(
                    title: "Saltar",
                    primaryAction: .init { [weak self] _ in self?.viewModel.skip() }
                ),
                animated: true
            )
            setupNavigationBar()
        } else {
            navigationItem.setRightBarButtonItems(nil, animated: true)
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
    OnboardingWireframe.createModule(onRequested: { _ in }, onPerformed: { _ in })
}
#endif
