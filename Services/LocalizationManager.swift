//
//  LocalizationManager.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 4/7/2024.
//

import Foundation
public enum SelectedLanguage: String {
    case english = "en"
    case t_chinese = "zh-Hant"
    case s_chinese = "zh-Hans"
}

public class LocalizationManager {
    // MARK: - Variables
    public static let shared = LocalizationManager()
    
    public var language: SelectedLanguage {
        get {
            guard let languageString = UserDefaults.standard.string(forKey: "selectedLanguage") else {
                saveLanguage(.t_chinese)
                return .t_chinese
            }
            // In other cases, a language saved in UserDefaults would be returned instead
            return SelectedLanguage(rawValue: languageString) ?? .t_chinese
        } set {
            if newValue != language {
                saveLanguage(newValue)
            }
        }
    }
    
    // MARK: - Init
    public init() { }
    
    // MARK: - Methods
    private func saveLanguage(_ language: SelectedLanguage) {
        UserDefaults.standard.setValue(language.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages") // Set the device's app language
        UserDefaults.standard.synchronize() // Optional as Apple does not recommend doing this
    }
}

