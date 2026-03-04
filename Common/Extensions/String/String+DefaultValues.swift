//
//  String+DefaultValues.swift
//

import Foundation

// MARK: - Default Values
// MARK: - Default Values
extension String {
    
    /// Default string values used throughout the application.
    public enum DefaultValues {
        public enum Alerts {
            public static let acceptActionTitle = "Aceptar"
            public static let cancelActionTitle = "Cancelar"
            public static let title = "Atención"
            public static let message = "Ha ocurrido un error, vuelve a intentarlo"
        }
        public enum App {
            public static let name = Bundle.main.displayName
        }
        public enum UIElements {
            public static let goBack = "Volver"
            public static let search = "Buscar"
            public static let finish = "Finalizar"
        }
        public enum Locale {
            public static let esCL = "es_CL"
        }
    }
}
