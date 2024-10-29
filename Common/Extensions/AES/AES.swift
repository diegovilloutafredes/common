import CommonCrypto
import Foundation

public struct AES {
    private let key: Data
    private let iv: Data

    public init?(key: String, iv: String) {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }
    
        guard iv.count == kCCBlockSizeAES128, let ivData = iv.data(using: .utf8) else {
            debugPrint("Error: Failed to set an initial vector.")
            return nil
        }

        self.key = keyData
        self.iv  = ivData
    }

    public func encrypt(_ string: String) -> Data? {
        guard let data = string.data(using: .utf8) else { return nil }
        return encrypt(data)
    }

    public func encrypt(_ data: Data) -> Data? { crypt(data: data, option: .init(kCCEncrypt)) }

    public func decrypt(_ data: Data) -> Data? { crypt(data: data, option: .init(kCCDecrypt)) }

    private func crypt(data: Data, option: CCOperation) -> Data? {
        let cryptLength = data.count + key.count
        var cryptData = Data(count: cryptLength)

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            option,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            data.count,
                            cryptBytes.baseAddress,
                            cryptLength,
                            &bytesLength
                        )
                    }
                }
            }
        }

        switch Int32(status) {
        case Int32(kCCSuccess):
            cryptData.removeSubrange(bytesLength..<cryptData.count)
            return cryptData
        default:
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }
    }
}
