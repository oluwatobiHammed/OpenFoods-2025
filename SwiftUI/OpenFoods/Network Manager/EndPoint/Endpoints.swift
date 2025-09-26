//
//  B2BEndpoints.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

enum Endpoints:EndPointType {
    case getFoods(page: Int)
    case updateFoodLikeStatus(id: Int, endpoint: String)
    
    /// The absolute base URL for the API used by all `Endpoints`.
    ///
    /// Discussion:
    /// - This value is constructed from `kAPI.Base_URL`.
    /// - It must be a valid, absolute URL string that includes a scheme and host (e.g., `"https://api.example.com"`).
    /// - The networking layer is expected to append the endpoint-specific relative `path` to this base URL
    ///   to form the full request URL.
    ///
    /// Requirements:
    /// - `kAPI.Base_URL` must be correctly configured at build/runtime time.
    /// - Avoid embedding endpoint paths or query items in `kAPI.Base_URL`; those belong in each case’s `path`.
    /// - Consistency with `Endpoints.path` is important. If `path` values begin with a leading slash,
    ///   ensure `kAPI.Base_URL` does not end with an extra trailing slash (or vice versa) to prevent
    ///   malformed URLs (e.g., double or missing slashes).
    ///
    /// Failure:
    /// - If `kAPI.Base_URL` cannot be parsed into a `URL`, the app will terminate via `fatalError`,
    ///   failing fast to surface misconfiguration early.
    ///
    /// Example:
    /// - `kAPI.Base_URL = "https://api.example.com"`
    ///   Combined with `path = "/foods/2"` results in `https://api.example.com/foods/2`.
    ///
    /// See also:
    /// - `Endpoints.path` for the relative path appended to this base URL.
    /// - `httpMethod` and `task` for the HTTP method and request configuration associated with each endpoint.
    var baseURL: URL {
     
        guard let url = URL(string: kAPI.Base_URL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    /// The relative path component appended to `baseURL` for the current endpoint.
    ///
    /// Behavior by endpoint:
    /// - `getFoods(page:)`: Appends the foods collection path followed by the page number.
    ///   Example: `"/foods/2"`
    /// - `updateFoodLikeStatus(id:endpoint:)`: Appends the foods collection path, the item `id`,
    ///   and a trailing action segment (`endpoint`), separated by slashes.
    ///   Example: `"/foods/42/like"`
    ///
    /// Notes:
    /// - This value is a relative path (no scheme/host); the networking layer should join it with `baseURL`.
    /// - Dynamic values (e.g., `page`, `id`, `endpoint`) are embedded as path segments, not query items.
    /// - Ensure `kAPI.Endpoints.foods` includes the expected leading/trailing slashes to avoid malformed URLs.
    ///
    /// - Returns: A `String` representing the relative path for the selected `Endpoints` case.
    var path: String {
        switch self {
        case .getFoods(let page):
            return kAPI.Endpoints.foods + "\(page)"
        case .updateFoodLikeStatus(let id, let endpoint):
            return kAPI.Endpoints.foods + "\(id)/" + "\(endpoint)"
        }
    }
    
    /// The HTTP method to use when building the `URLRequest` for this endpoint.
    /// 
    /// Behavior by endpoint:
    /// - `getFoods`: Uses the `.get` method to retrieve a paginated list of foods.
    /// - `updateFoodLikeStatus`: Uses the `.put` method to update the like status of a specific food.
    /// 
    /// Notes:
    /// - New endpoint cases should define their intended HTTP method here to ensure the networking
    ///   layer constructs requests correctly.
    /// - Methods are chosen to align with typical REST semantics (e.g., `GET` for retrieval,
    ///   `PUT` for idempotent updates).
    /// 
    /// - Returns: The appropriate `HTTPMethod` for the current `Endpoints` case.
    var httpMethod: HTTPMethod {
        switch self {
        case .updateFoodLikeStatus(_, _):
            return .put
        default:
            return .get
        }
    }
    
    /// The HTTP task configuration for the current endpoint.
    ///
    /// This property tells the networking layer how to build the `URLRequest` for each case,
    /// including how to encode parameters and whether any headers should be attached.
    ///
    /// Behavior by endpoint:
    /// - `getFoods`: Uses a headers-only request with URL encoding. No body parameters are sent.
    ///   Suitable for a `GET` request where query/path components identify the resource.
    /// - `updateFoodLikeStatus`: Uses a headers-only request with URL encoding. No body payload is sent;
    ///   the action is determined by the path (e.g., the food `id` and the trailing `endpoint` segment),
    ///   and the HTTP method is `PUT` as defined by `httpMethod`.
    ///
    /// Notes:
    /// - Both cases rely on URL encoding, which is appropriate for requests that do not send a JSON body.
    /// - Any default or global headers (e.g., auth, content type) are expected to be applied by the
    ///   networking layer when building the final `URLRequest`.
    var task: HTTPTask {
        switch self {
            
        case .getFoods:
            return .requestHeaders(bodyEncoding: .urlEncoding)
            
        case .updateFoodLikeStatus(id: _, endpoint: _):
            return .requestHeaders(bodyEncoding: .urlEncoding)
        }
        
    }
}
