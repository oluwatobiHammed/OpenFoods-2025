//
//  LocalizationManagerTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - Localization Manager Tests
class LocalizationManagerTests: XCTestCase {
    
    var localizationManager: LocalizationManager!
    
    override func setUp() {
        super.setUp()
        localizationManager = LocalizationManager.shared
    }
    
    func testDefaultLanguage() {
        // Test that default language is set
        XCTAssertFalse(localizationManager.currentLanguage.isEmpty)
    }
    
    func testSetLanguage() {
        let originalLanguage = localizationManager.currentLanguage
        
        localizationManager.setLanguage("fr")
        XCTAssertEqual(localizationManager.currentLanguage, "fr")
        
        localizationManager.setLanguage("invalid")
        XCTAssertEqual(localizationManager.currentLanguage, "fr") // Should not change
        
        // Reset to original
        localizationManager.setLanguage(originalLanguage)
    }
    
    func testLocalizedString() {
        localizationManager.setLanguage("en")
        XCTAssertEqual(localizationManager.localizedString(for: "app_title"), "OpenFoods")
        XCTAssertEqual(localizationManager.localizedString(for: "loading_foods"), "Loading delicious foods...")
        
        localizationManager.setLanguage("fr")
        XCTAssertEqual(localizationManager.localizedString(for: "loading_foods"), "Chargement des délicieux plats...")
        
        localizationManager.setLanguage("de")
        XCTAssertEqual(localizationManager.localizedString(for: "loading_foods"), "Lade köstliche Gerichte...")
        
        localizationManager.setLanguage("es")
        XCTAssertEqual(localizationManager.localizedString(for: "loading_foods"), "Cargando comidas deliciosas...")
        
        // Test fallback for missing key
        let missingKey = localizationManager.localizedString(for: "non_existent_key_12345")
        XCTAssertEqual(missingKey, "non_existent_key_12345")
    }
    
    func testSupportedLanguages() {
        let supportedLanguages = localizationManager.supportedLanguageNames
        XCTAssertGreaterThanOrEqual(supportedLanguages.count, 8)
        
        let languageCodes = supportedLanguages.map { $0.code }
        XCTAssertTrue(languageCodes.contains("en"))
        XCTAssertTrue(languageCodes.contains("fr"))
        XCTAssertTrue(languageCodes.contains("de"))
        XCTAssertTrue(languageCodes.contains("es"))
        XCTAssertTrue(languageCodes.contains("it"))
        XCTAssertTrue(languageCodes.contains("pt"))
        XCTAssertTrue(languageCodes.contains("ja"))
        XCTAssertTrue(languageCodes.contains("zh"))
    }
    
    func testStringLocalizationExtension() {
           localizationManager.setLanguage("en")
           XCTAssertEqual("like".localized, "Like")
           XCTAssertEqual("unlike".localized, "Unlike")
           
           localizationManager.setLanguage("es")
           XCTAssertEqual("like".localized, "Me gusta")
           XCTAssertEqual("unlike".localized, "Ya no me gusta")
           
           localizationManager.setLanguage("fr")
           XCTAssertEqual("like".localized, "Aimer")
           XCTAssertEqual("unlike".localized, "Ne plus aimer")
       }
       
       func testFoodRelatedLocalizations() {
           localizationManager.setLanguage("en")
           XCTAssertEqual("food_details".localized, "Food Details")
           XCTAssertEqual("description".localized, "Description")
           XCTAssertEqual("last_updated".localized, "Last Updated")
           XCTAssertEqual("offline_mode".localized, "Offline Mode")
           XCTAssertEqual("retry".localized, "Try Again")
           
           localizationManager.setLanguage("de")
           XCTAssertEqual("food_details".localized, "Gericht Details")
           XCTAssertEqual("description".localized, "Beschreibung")
           XCTAssertEqual("retry".localized, "Wiederholen")
       }
}
