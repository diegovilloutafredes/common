//
//  String+DateFormats.swift
//

import Foundation

// MARK: - DateFormats
extension String {
    public enum DateFormats {
        public static let ddMMyy = "dd MM yy"
        public static let ddMMyyyy = "dd-MM-yyyy"
        public static let ddMMMyy = "dd MMM yy"
        public static let ddMMMMyyyy = "dd MMMM yyyy"
        public static let ddMMyyyyHHmm = "dd-MM-yyyy HH:mm"
        public static let ddDEMMMMDELyyyy = "dd 'de' MMMM 'del' yyyy"
        public static let EEEEddDEMMMM = "EEEE dd 'de' MMMM"
        public static let EEEEddDEMMMMyyyy = "EEEE dd 'de' MMMM yyyy"
        public static let HHmm = "HH:mm"
        public static let MMyy = "MM yy"
        public static let yyyyMMdd = "yyyy-MM-dd"
        public static let yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
        public static let yyyyMMddHHmmss0000 = "yyyy-MM-dd HH:mm:ss +0000"
        public static let yyyyMMddHHmmss000000 = "yyyy-MM-dd HH:mm:ss.000000"
        public static let yyyyMMddTHHmmssSSSZ = "yyyy-MM-dd HH:mm:ss.SSS'Z'"
        public static let YYMMdd = "YYMMdd"
    }
}
