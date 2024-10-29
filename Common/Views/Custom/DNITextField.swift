//
//  DNITextField.swift
//

// MARK: - DNITextField
public final class DNITextField: BaseDNITextField {
    public override func setupView() {
        super.setupView()
        backgroundColor(.white)
        .enablesReturnKeyAutomatically(true)
        .font(.systemFont(ofSize: 16))
        .placeholder(
            "RUT (Ej: 123456789)",
            color: .black.withAlphaComponent(0.9),
            font: .systemFont(ofSize: 16)
        )
        .setAsRoundedView(
            using: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
            radius: 4
        )
        .setRatio(328/56)
        .textColor(.black)
        .with { $0.leftView(.init(frame: .init(x: .zero, y: .zero, width: 16, height: $0.frame.height))) }
    }
}
