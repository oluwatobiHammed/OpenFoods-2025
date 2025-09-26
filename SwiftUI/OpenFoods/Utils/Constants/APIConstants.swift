//
//  APIConstants.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

/// A lightweight namespace that centralizes API configuration details for the app's
/// networking layer. `kAPI` is not intended to be instantiated; it simply exposes
/// static constants used to build request URLs.
///
/// Overview:
/// - Provides the service's base URL.
/// - Groups relative endpoint paths under a nested `Endpoints` type for clarity
///   and discoverability.
/// - Encourages consistent URL construction across the codebase.
///
/// Usage:
/// - Compose request URLs by appending a relative endpoint path to `Base_URL`.
/// - Prefer `URLComponents` when adding query items to avoid manual string
///   concatenation and ensure proper percent-encoding.
///
/// Thread Safety:
/// - All values are immutable `static let` constants and therefore thread-safe.
///
/// Extensibility:
/// - Add new relative paths to `kAPI.Endpoints` as the API surface grows.
/// - Keep paths relative (starting with "/") so they can be joined with `Base_URL`
///   reliably.
///
/// Example:
/// ```swift
/// // Building a URL for the foods collection
/// let url = URL(string: kAPI.Base_URL + kAPI.Endpoints.foods)
///
/// // Building a URL for a specific food item
/// let foodID = "123"
/// let detailURL = URL(string: kAPI.Base_URL + kAPI.Endpoints.foods + foodID)
///
/// // Building a URL with query items using URLComponents
/// var components = URLComponents(string: kAPI.Base_URL + kAPI.Endpoints.foods)
/// components?.queryItems = [URLQueryItem(name: "page", value: "1")]
/// let pagedURL = components?.url
/// ```
///
/// - Warning: Do not add a trailing slash to `Base_URL`. Relative paths in
///   `Endpoints` already begin with a leading slash. Doubling slashes may produce
///   invalid URLs.

/// The root URL for the backend API.
/// - Important: Includes the `/api` prefix and intentionally omits a trailing slash
///   to ensure safe concatenation with endpoint paths that begin with `/`.
/// - Example: `https://opentable-dex-ios-test-d645a49e3287.herokuapp.com/api`

/// A grouping of relative endpoint paths to be appended to `Base_URL`.
/// - Note: All endpoint strings should start with `/` and represent paths relative
///   to `Base_URL`.

/// Relative path for the "foods" collection and related resources.
/// - Structure: Begins with `/v1/toladipupo/food/`.
/// - Trailing Slash: Intentionally includes a trailing slash so you can append
///   identifiers or additional path components directly (e.g., `.../food/123`).
/// - Example:
///   - Collection: `kAPI.Base_URL + kAPI.Endpoints.foods`
///   - Detail: `kAPI.Base_URL + kAPI.Endpoints.foods + "{id}"`
struct kAPI {
    
    static let Base_URL = "https://opentable-dex-ios-test-d645a49e3287.herokuapp.com/api"
    
    struct Endpoints {
        
        static let foods    = "/v1/toladipupo/food/"
    }
}
