//
//  ViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - MyViewModel
protocol MyViewModel: ViewModel {
    var title: String { get }
    var icon: UIImage? { get }
    var buttonTitle: String { get }
}

// MARK: - MyViewModelPayload
struct MyViewModelPayload: MyViewModel {
    var title = "Title"
    var icon: UIImage? = .checkmark
    var buttonTitle = "Button"
}

// MARK: - ViewController
final class ViewController: BaseViewModelableViewController<MyViewModel> {
    @UIViewBuilder
    override var mainView: UIView {
        VStack(
            alignment: .center,
            spacing: 16
        ) {
            UILabel(viewModel.title)
                .font(.systemFont(ofSize: 32))
                .textAlignment(.center)
                .textColor()

            UIImageView(image: viewModel.icon)
                .setRatio()
                .setConstraints { $0.setWidth(to: $1.widthAnchor, multiplier: 0.5) }

            HStack(spacing: 8) {
                UIButton(
                    configuration: .filled()
                        .with {
                            $0.title = viewModel.buttonTitle
                            $0.baseBackgroundColor = .black
                            $0.cornerStyle = .capsule
                        }
                ).onTap { [weak self] in guard let self else { return }
                    let viewModel = MyViewModelPayload(buttonTitle: "Next")
                    let vc = ViewController(viewModel: viewModel)
                    present(vc, animated: true)
                }

                UIButton(
                    configuration: .filled()
                        .with {
                            $0.title = "Store"
                            $0.baseBackgroundColor = .black
                            $0.cornerStyle = .capsule
                        }
                ).with { [weak self] button in guard let self else { return }
                    button.onTap { [weak self] in guard let self else { return }
                        button.startActivityIndicator(with: .white)
                        startActivityIndicator(with: .white)
                        dispatchOnMain { [weak self] in guard let self else { return }
                            add(users, using: "1")
                            dispatchOnMain { [weak self] in guard let self else { return }
                                button.stopActivityIndicator()
                                stopActivityIndicator()
                                Logger.log(get(using: "1"))
                                Snackbar.show(.init(message: (get(using: "1").count).asString))
                            }
                        }
                    }
                }

                UIButton(
                    configuration: .filled()
                        .with {
                            $0.title = "Delete"
                            $0.baseBackgroundColor = .black
                            $0.cornerStyle = .capsule
                        }
                ).with { [weak self] button in guard let self else { return }
                    button.onTap { [weak self] in guard let self else { return }
                        button.startActivityIndicator(with: .white)
                        startActivityIndicator(with: .white)
                        dispatchOnMain { [weak self] in guard let self else { return }
                            delete(using: "1")
                            dispatchOnMain { [weak self] in guard let self else { return }
                                button.stopActivityIndicator()
                                stopActivityIndicator()
                                Snackbar.show(.init(message: (get(using: "1").count).asString))
                            }
                        }
                    }
                }
            }

            if isPresented {
                HStack(spacing: 8) {
                    UIButton(
                        configuration: .filled()
                            .with {
                                $0.title = "Dismiss"
                                $0.baseBackgroundColor = .black
                                $0.cornerStyle = .capsule
                            }
                    ).onTap { [weak self] in guard let self else { return }
                        dismiss(animated: true)
                    }

                    UIButton(
                        configuration: .filled()
                            .with {
                                $0.title = "Back to root"
                                $0.baseBackgroundColor = .black
                                $0.cornerStyle = .capsule
                            }
                    ).onTap { [weak self] in guard let self else { return }
                        dismissFromRootPresentingViewController()
                    }
                }
            }
        }.setConstraints { $0.alignCenter(with: $1) }
    }

    private let users = Array(
        repeating: User(
            name: "Name",
            age: 99,
            status: true,
            date: .now,
            info: Array(
                repeating: .init(
                    name: "Name",
                    age: 99,
                    info: "Info"
                ),
                count: 100
            )
        ),
        count: 100
    )

    override func setupView() {
        view.randomBackgroundColor()
        
        observe(.onDidBecomeActive) {
            Logger.log("Application did become active")
        }
        observe(.onDidEnterBackground) {
            Logger.log("Application did enter background")
        }
        observe(.onWillEnterForeground) {
            Logger.log("Application will enter foreground")
        }
        observe(.onWillResignActive) {
            Logger.log("Application will resign active")
        }
        observe(.onWillTerminate) {
            Logger.log("Application will terminate")
        }
    }
}

extension ViewController: UserLocalStorageUseCase {}

// MARK: - Preview
//#if canImport(SwiftUI) && compiler(>=5.9)
//import SwiftUI
//@available(iOS 17.0, *)
//#Preview {
//    let viewModel = MyViewModelPayload(title: "Preview", buttonTitle: "Present next")
//    ViewController(viewModel: viewModel)
//}
//#endif

// MARK: - UserStorage
struct UserStorage: SingleRawValueKeyValueObjectStorage {
    enum Keys: String {
        case user
    }

    func add(item: [User]) { add(item: (.user, item)) }
    func delete() { remove(using: .user) }
    func get() -> [User]? { get(using: .user) }
}

// MARK: - User
struct User: Storable {
    let name: String
    let age: Int
    let status: Bool
    let date: Date
    let info: [Info]
}

// MARK: - Info
struct Info: Storable {
    let name: String
    let age: Int
    let info: String
}

// MARK: - UserLocalStorageUseCase
protocol UserLocalStorageUseCase {
    func add(_ users: [User], using id: String)
    func delete(using id: String)
    func get(using id: String) -> [User]
}

// MARK: - Default implementation
extension UserLocalStorageUseCase {
    private var store: KeyValueStore { .init(type: .secure) }
    func add(_ users: [User], using id: String) { store.add(item: (id, users)) }
    func delete(using id: String) { store.remove(using: id) }
    func get(using id: String) -> [User] { store.get(using: id) ?? [] }
}
