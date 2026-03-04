//
//  CardView.swift
//

import UIKit

// MARK: - CardViewModel
/// A protocol defining the properties for a card view model.
public protocol CardViewModel: ViewModel {
    /// The background color for the left image container.
    var leftImageBackgroundColor: UIColor? { get }
    /// The image to display on the left side of the card.
    var leftImage: UIImage? { get }
    /// The main title text.
    var title: String { get }
    /// An attributed title text, if specified.
    var attributedTitle: NSAttributedString? { get }
    /// The main content/description text.
    var content: String { get }
    /// An attributed content/description text, if specified.
    var attributedContent: NSAttributedString? { get }
    /// The image to display on the right side of the card.
    var rightImage: UIImage? { get }
}

public struct CardViewModelPayload: CardViewModel {
    public var leftImageBackgroundColor: UIColor?
    public var leftImage: UIImage?
    public var title: String
    public var attributedTitle: NSAttributedString?
    public var content: String
    public var attributedContent: NSAttributedString?
    public var rightImage: UIImage?

    public init(leftImageBackgroundColor: UIColor? = nil, leftImage: UIImage? = nil, title: String = .empty, attributedTitle: NSAttributedString? = nil, content: String = .empty, attributedContent: NSAttributedString? = nil, rightImage: UIImage? = nil) {
        self.leftImageBackgroundColor = leftImageBackgroundColor
        self.leftImage = leftImage
        self.title = title
        self.attributedTitle = attributedTitle
        self.content = content
        self.attributedContent = attributedContent
        self.rightImage = rightImage
    }
}

/// A customizable card view that displays an optional left image, title, content, and an optional right image.
public final class CardView: BaseViewModelableView<CardViewModel> {
    @UIViewBuilder public override var mainView: UIView {
        HStack(
            alignment: .center,
            distribution: .fill,
            margins: .DefaultValues.StackView.margins,
            spacing: .DefaultValues.StackView.spacing
        ) {
            if let leftImage = viewModel.leftImage {
                HStack(alignment: .center) {
                    UIImageView(image: leftImage)
                        .contentMode(.center)
                        .setRatio()
                        
                }
                .backgroundColor(viewModel.leftImageBackgroundColor)
                .setRatio()
                .setAsRoundedView(radius: viewModel.leftImageBackgroundColor.isNil ? .zero : nil)
                .setConstraints {
                    if self.viewModel.leftImageBackgroundColor.isNotNil { $0.setWidth(to: $1.widthAnchor, multiplier: 0.16) }
                }
            }

            if
                viewModel.title.isNotEmpty ||
                viewModel.attributedTitle?.string.isNotEmpty ?? false ||
                viewModel.content.isNotEmpty ||
                viewModel.attributedContent?.string.isNotEmpty ?? false {
                VStack(spacing: 10) {
                    if viewModel.title.isNotEmpty {
                        UILabel(viewModel.title)
                            .font(.boldSystemFont(ofSize: 16))
                            .textColor()
                    } else if let attributedTitle = viewModel.attributedTitle {
                        UILabel()
                            .attributedText(attributedTitle)
                    }

                    if viewModel.content.isNotEmpty {
                        UILabel(viewModel.content)
                            .adjustsFontSizeToFitWidth()
                            .font(.systemFont(ofSize: 14))
                            .numberOfLines(.zero)
                            .textColor()
                    } else if let attributedContent = viewModel.attributedContent {
                        UILabel()
                            .adjustsFontSizeToFitWidth()
                            .attributedText(attributedContent)
                            .numberOfLines(.zero)
                    }
                }
            }

            if let rightImage = viewModel.rightImage {
                HStack(alignment: .center) {
                    UIImageView(image: rightImage)
                        .contentMode(.scaleAspectFit)
                        .setRatio()
                }.setRatio()
            }
        }.setConstraints { $0.snap(to: $1) }
    }

    public override func setupView() {
        backgroundColor(.white)
        cornerRadius(8)
        shadow(
            color: .init(red: 0, green: 0, blue: 0, alpha: 0.1),
            offset: .init(width: .zero, height: 8),
            opacity: 1,
            radius: 15
        )
    }
}
