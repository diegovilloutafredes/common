//
//  StorageViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - StorageViewController
/// The buttons only call the view model; every status label is rendered from the
/// observable `stored` / `directSecret` snapshots in `updateContent()`.
final class StorageViewController: BaseViewModelableViewController<StorageViewModelProtocol> {
    private lazy var statusLabels: [StorageType: UILabel] = Dictionary(
        uniqueKeysWithValues: StorageType.allCases.map { ($0, makeStatusLabel()) }
    )

    private lazy var directStatusLabel = makeStatusLabel()

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                sectionCard(for: .userDefaults)
                sectionCard(for: .file)
                sectionCard(for: .keychain)
                sectionCard(for: .inMemory)
                directKeychainCard()
            }.setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }.setConstraints { $0.snap(to: $1) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }

    override func updateContent() {
        super.updateContent()
        let stored = viewModel.stored
        StorageType.allCases.forEach { type in
            render(statusLabels[type], item: stored[type])
        }
        if let secret = viewModel.directSecret {
            directStatusLabel.text("Stored: \"\(secret)\"").textColor(.systemGreen)
        } else {
            directStatusLabel.text("Empty — nothing stored").textColor(.secondaryLabel)
        }
    }

    private func render(_ label: UILabel?, item: StorageItem?) {
        if let item {
            label?.text("Stored: \"\(item.value)\" at \(item.timestamp.toString(with: "HH:mm:ss"))")
                .textColor(.systemGreen)
        } else {
            label?.text("Empty — nothing stored")
                .textColor(.secondaryLabel)
        }
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
                    Snackbar.show(.init(message: "Saved to \(type.title)"))
                }
                makeButton(title: "Read", color: .systemOrange) { [weak self] in
                    let value = self?.viewModel.read(type: type)
                    Snackbar.show(.init(message: value != nil
                        ? "Read: \"\(value!.value)\""
                        : "Nothing stored in \(type.title)"))
                }
                makeButton(title: "Delete", color: .systemRed) { [weak self] in
                    self?.viewModel.delete(type: type)
                    Snackbar.show(.init(message: "Deleted from \(type.title)"))
                }
            }

            statusLabels[type]!
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func directKeychainCard() -> UIView {
        VStack(
            margins: .init(top: 16, left: 16, bottom: 16, right: 16),
            spacing: 12
        ) {
            HStack(alignment: .center, spacing: 10) {
                UIImageView(image: .init(systemName: "key.fill"))
                    .tintColor(.systemTeal)
                    .contentMode(.scaleAspectFit)
                    .setConstraints { $0.set(width: 24); $0.set(height: 24) }
                UILabel()
                    .text("KeychainWrapper (direct)")
                    .font(.boldSystemFont(ofSize: 18))
                    .textColor(.label)
            }

            UILabel()
                .text("The low-level typed API under KeyValueStore(.secure): set(_:forKey:), string(forKey:), removeObject(forKey:).")
                .font(.systemFont(ofSize: 13))
                .textColor(.secondaryLabel)
                .numberOfLines(0)

            HStack(distribution: .fillEqually, spacing: 8) {
                makeButton(title: "Save", color: .systemTeal) { [weak self] in
                    guard let self else { return }
                    let secret = viewModel.saveDirectSecret()
                    Snackbar.show(.init(message: "Saved \"\(secret)\""))
                }
                makeButton(title: "Read", color: .systemOrange) { [weak self] in
                    guard let self else { return }
                    let value = viewModel.readDirectSecret()
                    Snackbar.show(.init(message: value.map { "Read: \"\($0)\"" } ?? "Nothing stored"))
                }
                makeButton(title: "Delete", color: .systemRed) { [weak self] in
                    guard let self else { return }
                    viewModel.deleteDirectSecret()
                    Snackbar.show(.init(message: "Deleted from Keychain"))
                }
            }

            directStatusLabel
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
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
