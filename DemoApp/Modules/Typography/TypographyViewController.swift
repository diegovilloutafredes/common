//
//  TypographyViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - TypographyViewProtocol
protocol TypographyViewProtocol: AnyObject {
    func updateSelectedFamily()
}

// MARK: - TypographyViewController
final class TypographyViewController: BaseViewModelableViewController<TypographyViewModelProtocol> {

    // MARK: - Family Picker
    private lazy var familyScrollView = UIScrollView()
        .with {
            $0.showsHorizontalScrollIndicator = false
            $0.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
        .setConstraints { $0.set(height: 56) }

    private lazy var familyChipsStack = HStack(alignment: .center, spacing: 8)

    // MARK: - Preview Card
    private lazy var previewTitleLabel   = UILabel().numberOfLines(0)
    private lazy var previewSubtitleLabel = UILabel().numberOfLines(0)
    private lazy var previewBodyLabel    = UILabel().numberOfLines(0)

    private lazy var previewCard = VStack(
        margins: .init(top: 20, left: 20, bottom: 20, right: 20),
        spacing: 8
    ) {
        previewTitleLabel
        previewSubtitleLabel
        previewBodyLabel
    }
    .backgroundColor(.systemBackground)
    .round(radius: 16)
    .shadow(color: .black.withAlphaComponent(0.1), offset: .init(width: 0, height: 4), opacity: 1, radius: 12)

    // MARK: - Styles Section
    private lazy var sectionHeader = UILabel("Styles")
        .font(.boldSystemFont(ofSize: 13))
        .textColor(.secondaryLabel)

    private lazy var stylesContainer = VStack(spacing: 0)

    // MARK: - PaddingLabel demo
    private lazy var paddingBadgeRow = HStack(alignment: .center, spacing: 8) {
        PaddingLabel(padding: .init(horizontal: 10, vertical: 4))
            .text("PaddingLabel")
            .font(.systemFont(ofSize: 12, weight: .semibold))
            .textColor(.white)
            .backgroundColor(.systemPink)
            .setAsRoundedView(radius: 10)
        UILabel("padded · rounded · wraps within insets")
            .font(.systemFont(ofSize: 11))
            .textColor(.tertiaryLabel)
            .numberOfLines(0)
        UIView()
    }

    // MARK: - Layout
    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 0, left: 0, bottom: 32, right: 0),
                spacing: 0
            ) {
                familyScrollView
                VStack(
                    margins: .init(top: 16, left: 16, bottom: 16, right: 16),
                    spacing: 20
                ) {
                    previewCard
                    paddingBadgeRow
                    sectionHeader
                    stylesContainer
                }
            }
            .setConstraints { $0.snap(to: $1); $0.setWidth(to: $1.widthAnchor) }
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemGroupedBackground)
        familyScrollView.addSubview(familyChipsStack)
        familyChipsStack.setConstraints {
            $0.snap(to: $1, insets: .init(horizontal: .zero, vertical: 12))
            $0.set(height: 32)
        }
        viewModel.families.enumerated().forEach { index, item in
            familyChipsStack.addArrangedSubview(makeChip(for: item.family, name: item.name, index: index))
        }
        reloadPreview()
        updateChipSelection()
    }
}

// MARK: - TypographyViewProtocol
extension TypographyViewController: TypographyViewProtocol {
    func updateSelectedFamily() {
        reloadPreview()
        updateChipSelection()
    }
}

// MARK: - Private
private extension TypographyViewController {

    func reloadPreview() {
        let family = viewModel.selectedFamily
        previewTitleLabel
            .font(.appFont(family, style: .bold, size: 26))
            .text(viewModel.families.first(where: { $0.family == family })?.name ?? "")
            .textColor(.label)

        previewSubtitleLabel
            .font(.appFont(family, style: .medium, size: 17))
            .text("The quick brown fox jumps over the lazy dog")
            .textColor(.secondaryLabel)

        previewBodyLabel
            .font(.appFont(family, style: .regular, size: 14))
            .text("Sphinx of black quartz, judge my vow.")
            .textColor(.secondaryLabel)

        rebuildStyleRows(for: family)
    }

    func rebuildStyleRows(for family: AppFontFamily) {
        stylesContainer.removeArrangedSubviews()
        viewModel.previewStyles.forEach { style in
            stylesContainer.addArrangedSubview(makeStyleRow(family: family, style: style))
        }
    }

    func makeStyleRow(family: AppFontFamily, style: UIFont.FontStyle) -> UIView {
        let postScriptName = "\(family.uppercasingFirstLetter)-\(style.uppercasingFirstLetter)"
        let isResolved = UIFont(name: postScriptName, size: 16) != nil

        let nameLabel = UILabel(style.uppercasingFirstLetter)
            .font(.systemFont(ofSize: 11, weight: .medium))
            .textColor(isResolved ? .secondaryLabel : .tertiaryLabel)
            .setConstraints { $0.set(width: 80) }

        let sampleLabel = UILabel("Sphinx of black quartz, judge my vow")
            .font(.appFont(family, style: style, size: 16))
            .textColor(isResolved ? .label : .tertiaryLabel)
            .numberOfLines(1)

        let resolvedLabel = UILabel(isResolved ? "" : "↩ system")
            .font(.monospacedSystemFont(ofSize: 10, weight: .regular))
            .textColor(.tertiaryLabel)
            .setConstraints { $0.set(width: 56) }

        return VStack(spacing: 0) {
            HStack(
                alignment: .center,
                margins: .init(top: 10, left: 0, bottom: 10, right: 0),
                spacing: 8
            ) {
                nameLabel
                sampleLabel
                resolvedLabel
            }
            Separator(color: .separator, height: 0.5)
        }
    }

    func makeChip(for family: AppFontFamily, name: String, index: Int) -> UIButton {
        UIButton(configuration: .filled()
            .with {
                $0.title = name
                $0.baseBackgroundColor = .systemBlue
                $0.baseForegroundColor = .white
                $0.cornerStyle = .capsule
                $0.contentInsets = .init(top: 6, leading: 14, bottom: 6, trailing: 14)
                $0.titleTextAttributesTransformer = .init { container in
                    var c = container
                    c.font = .systemFont(ofSize: 13, weight: .medium)
                    return c
                }
            }
        )
        .tag(index)
        .onTap { [weak self] in
            guard let self else { return }
            viewModel.select(family: family)
        }
    }

    func updateChipSelection() {
        let selectedIndex = viewModel.families.firstIndex(where: { $0.family == viewModel.selectedFamily }) ?? 0
        familyChipsStack.arrangedSubviews
            .compactMap { $0 as? UIButton }
            .forEach { button in
                var config = button.configuration
                let isSelected = button.tag == selectedIndex
                config?.baseBackgroundColor = isSelected ? .systemBlue : .systemFill
                config?.baseForegroundColor = isSelected ? .white : .label
                button.configuration = config
            }
    }
}
