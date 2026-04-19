//
//  StorageViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - StorageViewController
final class StorageViewController: BaseViewModelableViewController<StorageViewModelProtocol> {
    private lazy var statusLabels: [StorageType: UILabel] = Dictionary(
        uniqueKeysWithValues: StorageType.allCases.map { ($0, makeStatusLabel()) }
    )

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView()
            .setConstraints { $0.snap(to: $1) }
            .with { scroll in
                let contentStack = VStack(
                    margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                    spacing: 16
                ) {
                    sectionCard(for: .userDefaults)
                    sectionCard(for: .file)
                    sectionCard(for: .keychain)
                }
                contentStack.translatesAutoresizingMaskIntoConstraints = false
                scroll.addSubview(contentStack)
                NSLayoutConstraint.activate([
                    contentStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
                    contentStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
                    contentStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                    contentStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                    contentStack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
                ])
            }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        StorageType.allCases.forEach { refreshLabel(for: $0) }
    }

    private func sectionCard(for type: StorageType) -> UIView {
        VStack(
            margins: .init(top: 16, left: 16, bottom: 16, right: 16),
            spacing: 12
        ) {
            HStack(alignment: .center, spacing: 10) {
                UIImageView(image: .init(systemName: type.iconName))
                    .tintColor(type.color)
                    .contentMode(.scaleAspectFit)
                    .setConstraints { $0.set(width: 24); $0.set(height: 24) }
                UILabel()
                    .text(type.title)
                    .font(.boldSystemFont(ofSize: 18))
                    .textColor(.label)
            }

            UILabel()
                .text(type.description)
                .font(.systemFont(ofSize: 13))
                .textColor(.secondaryLabel)
                .numberOfLines(0)

            UILabel()
                .text("Value: \"\(type.exampleValue)\"")
                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                .textColor(.tertiaryLabel)
                .numberOfLines(0)

            HStack(distribution: .fillEqually, spacing: 8) {
                makeButton(title: "Save", color: type.color) { [weak self] in
                    _ = self?.viewModel.save(type: type)
                    self?.refreshLabel(for: type)
                    Snackbar.show(.init(message: "Saved to \(type.title)"))
                }
                makeButton(title: "Read", color: .systemOrange) { [weak self] in
                    self?.refreshLabel(for: type)
                    let value = self?.viewModel.read(type: type)
                    Snackbar.show(.init(message: value != nil
                        ? "Read: \"\(value!.value)\""
                        : "Nothing stored in \(type.title)"))
                }
                makeButton(title: "Delete", color: .systemRed) { [weak self] in
                    self?.viewModel.delete(type: type)
                    self?.refreshLabel(for: type)
                    Snackbar.show(.init(message: "Deleted from \(type.title)"))
                }
            }

            statusLabels[type]!
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func refreshLabel(for type: StorageType) {
        if let item = viewModel.read(type: type) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            statusLabels[type]?.text("Stored: \"\(item.value)\" at \(formatter.string(from: item.timestamp))")
                .textColor(.systemGreen)
        } else {
            statusLabels[type]?.text("Empty — nothing stored")
                .textColor(.secondaryLabel)
        }
    }

    private func makeStatusLabel() -> UILabel {
        UILabel()
            .text("Empty — nothing stored")
            .font(.systemFont(ofSize: 13))
            .textColor(.secondaryLabel)
            .numberOfLines(2)
    }

    private func makeButton(title: String, color: UIColor, action: @escaping () -> Void) -> UIButton {
        UIButton(
            configuration: .filled()
                .with {
                    $0.title = title
                    $0.baseBackgroundColor = color
                    $0.cornerStyle = .capsule
                }
        )
        .onTap(action)
        .setConstraints { $0.set(height: 38) }
    }
}
