//
//  LocalizationManager.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation


// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "en"
    
    private let supportedLanguages = ["en", "fr", "de", "es", "it", "pt", "ja", "zh"]
    private var localizations: [String: [String: String]] = [:]
    
    private init() {
        setupLocalizations()
        currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        if !supportedLanguages.contains(currentLanguage) {
            currentLanguage = "en"
        }
    }
    
    func setLanguage(_ language: String) {
        if supportedLanguages.contains(language) {
            currentLanguage = language
        }
    }
    
    func localizedString(for key: String) -> String {
        return localizations[currentLanguage]?[key] ?? localizations["en"]?[key] ?? key
    }
    
    var supportedLanguageNames: [(code: String, name: String)] {
        return [
            ("en", "English"),
            ("fr", "Français"),
            ("de", "Deutsch"),
            ("es", "Español"),
            ("it", "Italiano"),
            ("pt", "Português"),
            ("ja", "日本語"),
            ("zh", "中文")
        ]
    }
    
    private func setupLocalizations() {
        // English
        localizations["en"] = [
            // App Title
            "app_title": "OpenFoods",
            "app_subtitle": "Discover delicious foods from around the world",
            
            // Navigation & Actions
            "done": "Done",
            "cancel": "Cancel",
            "save": "Save",
            "retry": "Try Again",
            "refresh": "Refresh",
            "clear_cache": "Clear Cache",
            
            // Food List
            "loading_foods": "Loading delicious foods...",
            "loading_more": "Loading more...",
            "offline_mode": "Offline Mode",
            "pending": "pending",
            "no_foods": "No foods available",
            "pull_to_refresh": "Pull to refresh",
            
            // Food Details
            "food_details": "Food Details",
            "description": "Description",
            "no_description": "No description available.",
            "last_updated": "Last Updated",
            "like": "Like",
            "unlike": "Unlike",
            "updated": "Updated",
            "country_of_origin": "Country of Origin",
            
            // Settings
            "api_configuration": "API Configuration",
            "base_url": "Base URL",
            "user_id": "User ID",
            "cache_information": "Cache Information",
            "last_sync": "Last Sync",
            "no_cached_data": "No cached data",
            "pending_likes": "Pending Likes",
            "language_settings": "Language Settings",
            "select_language": "Select Language",
            "example": "Example",
            
            // Errors
            "error_title": "Oops! Something went wrong",
            "network_error": "Network error occurred",
            "server_error": "Server error occurred",
            "no_internet": "No internet connection and no cached data available",
            "failed_to_update_like": "Failed to update like status",
            "invalid_url": "Invalid URL",
            "decoding_error": "Failed to decode data",
            
            // Welcome Screen
            "welcome_title": "Welcome to OpenFoods!",
            "welcome_subtitle": "Configure your API settings to get started",
            "open_settings": "Open Settings"
        ]
        
        // French
        localizations["fr"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "Découvrez des plats délicieux du monde entier",
            
            "settings": "Paramètres",
            "done": "Terminé",
            "cancel": "Annuler",
            "save": "Enregistrer",
            "retry": "Réessayer",
            "refresh": "Actualiser",
            "clear_cache": "Vider le cache",
            
            "loading_foods": "Chargement des délicieux plats...",
            "loading_more": "Chargement...",
            "offline_mode": "Mode hors ligne",
            "pending": "en attente",
            "no_foods": "Aucun plat disponible",
            "pull_to_refresh": "Tirez pour actualiser",
            
            "food_details": "Détails du plat",
            "description": "Description",
            "no_description": "Aucune description disponible.",
            "last_updated": "Dernière mise à jour",
            "like": "Aimer",
            "unlike": "Ne plus aimer",
            "updated": "Mis à jour",
            "country_of_origin": "Pays d'origine",
            
            "api_configuration": "Configuration API",
            "base_url": "URL de base",
            "user_id": "ID utilisateur",
            "cache_information": "Informations du cache",
            "last_sync": "Dernière synchronisation",
            "no_cached_data": "Aucune donnée en cache",
            "pending_likes": "J'aime en attente",
            "language_settings": "Paramètres de langue",
            "select_language": "Sélectionner la langue",
            "example": "Exemple",
            
            "error_title": "Oups ! Quelque chose s'est mal passé",
            "network_error": "Erreur réseau",
            "server_error": "Erreur serveur",
            "no_internet": "Pas de connexion internet et aucune donnée en cache",
            "failed_to_update_like": "Échec de la mise à jour du statut j'aime",
            "invalid_url": "URL invalide",
            "decoding_error": "Échec du décodage des données",
            
            "welcome_title": "Bienvenue sur OpenFoods !",
            "welcome_subtitle": "Configurez vos paramètres API pour commencer",
            "open_settings": "Ouvrir les paramètres"
        ]
        
        // German
        localizations["de"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "Entdecken Sie köstliche Gerichte aus aller Welt",
            
            "settings": "Einstellungen",
            "done": "Fertig",
            "cancel": "Abbrechen",
            "save": "Speichern",
            "retry": "Wiederholen",
            "refresh": "Aktualisieren",
            "clear_cache": "Cache leeren",
            
            "loading_foods": "Lade köstliche Gerichte...",
            "loading_more": "Lade mehr...",
            "offline_mode": "Offline-Modus",
            "pending": "ausstehend",
            "no_foods": "Keine Gerichte verfügbar",
            "pull_to_refresh": "Zum Aktualisieren ziehen",
            
            "food_details": "Gericht Details",
            "description": "Beschreibung",
            "no_description": "Keine Beschreibung verfügbar.",
            "last_updated": "Zuletzt aktualisiert",
            "like": "Gefällt mir",
            "unlike": "Gefällt mir nicht mehr",
            "updated": "Aktualisiert",
            "country_of_origin": "Herkunftsland",
            
            "api_configuration": "API-Konfiguration",
            "base_url": "Basis-URL",
            "user_id": "Benutzer-ID",
            "cache_information": "Cache-Informationen",
            "last_sync": "Letzte Synchronisation",
            "no_cached_data": "Keine zwischengespeicherten Daten",
            "pending_likes": "Ausstehende Likes",
            "language_settings": "Spracheinstellungen",
            "select_language": "Sprache wählen",
            "example": "Beispiel",
            
            "error_title": "Hoppla! Etwas ist schiefgelaufen",
            "network_error": "Netzwerkfehler aufgetreten",
            "server_error": "Serverfehler aufgetreten",
            "no_internet": "Keine Internetverbindung und keine zwischengespeicherten Daten",
            "failed_to_update_like": "Like-Status konnte nicht aktualisiert werden",
            "invalid_url": "Ungültige URL",
            "decoding_error": "Daten konnten nicht dekodiert werden",
            
            "welcome_title": "Willkommen bei OpenFoods!",
            "welcome_subtitle": "Konfigurieren Sie Ihre API-Einstellungen zum Starten",
            "open_settings": "Einstellungen öffnen"
        ]
        
        // Spanish
        localizations["es"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "Descubre comidas deliciosas de todo el mundo",
            
            "settings": "Configuración",
            "done": "Listo",
            "cancel": "Cancelar",
            "save": "Guardar",
            "retry": "Reintentar",
            "refresh": "Actualizar",
            "clear_cache": "Limpiar caché",
            
            "loading_foods": "Cargando comidas deliciosas...",
            "loading_more": "Cargando más...",
            "offline_mode": "Modo sin conexión",
            "pending": "pendiente",
            "no_foods": "No hay comidas disponibles",
            "pull_to_refresh": "Desliza para actualizar",
            
            "food_details": "Detalles de la comida",
            "description": "Descripción",
            "no_description": "No hay descripción disponible.",
            "last_updated": "Última actualización",
            "like": "Me gusta",
            "unlike": "Ya no me gusta",
            "updated": "Actualizado",
            "country_of_origin": "País de origen",
            
            "api_configuration": "Configuración API",
            "base_url": "URL base",
            "user_id": "ID de usuario",
            "cache_information": "Información de caché",
            "last_sync": "Última sincronización",
            "no_cached_data": "No hay datos en caché",
            "pending_likes": "Me gusta pendientes",
            "language_settings": "Configuración de idioma",
            "select_language": "Seleccionar idioma",
            "example": "Ejemplo",
            
            "error_title": "¡Ups! Algo salió mal",
            "network_error": "Error de red",
            "server_error": "Error del servidor",
            "no_internet": "Sin conexión a internet y sin datos en caché",
            "failed_to_update_like": "Error al actualizar el estado de me gusta",
            "invalid_url": "URL inválida",
            "decoding_error": "Error al decodificar datos",
            
            "welcome_title": "¡Bienvenido a OpenFoods!",
            "welcome_subtitle": "Configura tu API para comenzar",
            "open_settings": "Abrir configuración"
        ]
        
        // Italian
        localizations["it"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "Scopri cibi deliziosi da tutto il mondo",
            
            "settings": "Impostazioni",
            "done": "Fatto",
            "cancel": "Annulla",
            "save": "Salva",
            "retry": "Riprova",
            "refresh": "Aggiorna",
            "clear_cache": "Svuota cache",
            
            "loading_foods": "Caricamento cibi deliziosi...",
            "loading_more": "Caricamento...",
            "offline_mode": "Modalità offline",
            "pending": "in attesa",
            "no_foods": "Nessun cibo disponibile",
            
            "food_details": "Dettagli del cibo",
            "description": "Descrizione",
            "no_description": "Nessuna descrizione disponibile.",
            "last_updated": "Ultimo aggiornamento",
            "like": "Mi piace",
            "unlike": "Non mi piace più",
            "updated": "Aggiornato",
            
            "api_configuration": "Configurazione API",
            "language_settings": "Impostazioni lingua",
            "select_language": "Seleziona lingua",
            
            "error_title": "Ops! Qualcosa è andato storto",
            "welcome_title": "Benvenuto in OpenFoods!",
            "welcome_subtitle": "Configura le impostazioni API per iniziare",
            "open_settings": "Apri impostazioni"
        ]
        
        // Portuguese
        localizations["pt"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "Descubra comidas deliciosas de todo o mundo",
            
            "settings": "Configurações",
            "done": "Feito",
            "cancel": "Cancelar",
            "save": "Salvar",
            "retry": "Tentar novamente",
            "refresh": "Atualizar",
            "clear_cache": "Limpar cache",
            
            "loading_foods": "Carregando comidas deliciosas...",
            "loading_more": "Carregando mais...",
            "offline_mode": "Modo offline",
            "pending": "pendente",
            
            "food_details": "Detalhes da comida",
            "description": "Descrição",
            "no_description": "Nenhuma descrição disponível.",
            "last_updated": "Última atualização",
            "like": "Curtir",
            "unlike": "Descurtir",
            
            "language_settings": "Configurações de idioma",
            "select_language": "Selecionar idioma",
            
            "welcome_title": "Bem-vindo ao OpenFoods!",
            "welcome_subtitle": "Configure suas configurações de API para começar",
            "open_settings": "Abrir configurações"
        ]
        
        // Japanese
        localizations["ja"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "世界中の美味しい料理を発見",
            
            "settings": "設定",
            "done": "完了",
            "cancel": "キャンセル",
            "save": "保存",
            "retry": "再試行",
            "refresh": "更新",
            "clear_cache": "キャッシュをクリア",
            
            "loading_foods": "美味しい料理を読み込み中...",
            "loading_more": "さらに読み込み中...",
            "offline_mode": "オフラインモード",
            
            "food_details": "料理の詳細",
            "description": "説明",
            "last_updated": "最終更新",
            "like": "いいね",
            "unlike": "いいねを取り消し",
            
            "language_settings": "言語設定",
            "select_language": "言語を選択",
            
            "welcome_title": "OpenFoodsへようこそ！",
            "welcome_subtitle": "開始するにはAPI設定を構成してください"
        ]
        
        // Chinese
        localizations["zh"] = [
            "app_title": "OpenFoods",
            "app_subtitle": "发现来自世界各地的美食",
            
            "settings": "设置",
            "done": "完成",
            "cancel": "取消",
            "save": "保存",
            "retry": "重试",
            "refresh": "刷新",
            "clear_cache": "清除缓存",
            
            "loading_foods": "正在加载美味食物...",
            "loading_more": "加载更多...",
            "offline_mode": "离线模式",
            
            "food_details": "食物详情",
            "description": "描述",
            "last_updated": "最后更新",
            "like": "点赞",
            "unlike": "取消点赞",
            
            "language_settings": "语言设置",
            "select_language": "选择语言",
            
            "welcome_title": "欢迎使用 OpenFoods！",
            "welcome_subtitle": "配置您的API设置以开始使用"
        ]
    }
}

// MARK: - Localization Extension
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}
