//
//  HTTPTask.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestArrayParametersAndHeaders(bodyParameters: ArrayParameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestHeaders(bodyEncoding: ParameterEncoding)
    

}
