//
//  JSONParameterEncoderJSONParameterEncoder.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

public struct JSONParameterEncoder: ParameterEncoder {

    /**
     Encodes the provided parameters as a JSON payload and assigns it to the `httpBody` of the given `URLRequest`.
     
     This method uses `JSONSerialization` with the `.prettyPrinted` option to convert the supplied key–value pairs into JSON data. If serialization fails (for example, because the parameters contain a non-JSON-representable value), the method throws `NetworkError.encodingFailed`.
     
     - Parameters:
     - urlRequest: The request to modify. Supplied as `inout` so its `httpBody` can be set to the encoded JSON data. Any existing body will be overwritten.
     - parameters: A dictionary of values to be serialized into JSON. All values must be JSON-representable (e.g., `String`, `Number`, `Bool`, `Array`, `Dictionary`, or `NSNull`).
     
     - Throws: `NetworkError.encodingFailed` if the parameters cannot be serialized to JSON.

 - Important: This method does not set HTTP headers. Callers should set the `Content-Type` header to `application/json` (and optionally `Accept: application/json`) on the `URLRequest` as appropriate.

 - Note: The `.prettyPrinted` formatting is used for readability and may increase payload size; it is not required by servers.
 */
    public func encode(
        urlRequest: inout URLRequest,
        withParameters parameters: Parameters
    ) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            
        } catch {
            throw NetworkError.encodingFailed
        }
    }
    
    /**
     Encodes the provided array parameters as a JSON payload and assigns it to the `httpBody` of the given `URLRequest`.
     
     This method uses `JSONEncoder` with the `.prettyPrinted` output formatting to serialize the supplied array (or encodable collection) into JSON data. If encoding fails (for example, because the elements are not `Encodable` or contain non-JSON-representable values), the method throws `NetworkError.encodingFailed`.
     
     - Parameters:
     - urlRequest: The request to modify. Supplied as `inout` so its `httpBody` can be set to the encoded JSON data. Any existing body will be overwritten.
     - arrayParameters: The encodable collection to be serialized into JSON and set as the request body.
     
     - Throws: `NetworkError.encodingFailed` if the parameters cannot be encoded to JSON.

 - Important: This method does not set HTTP headers. Callers should set the `Content-Type` header to `application/json` (and optionally `Accept: application/json`) on the `URLRequest` as appropriate.

 - Note: The `.prettyPrinted` formatting is used for readability and may increase payload size; it is not required by servers.
 */
    public func encode(
        urlRequest: inout URLRequest,
        withArrayParameters arrayParameters: ArrayParameters
    ) throws {
        do {
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            urlRequest.httpBody = try encoder.encode(arrayParameters)
            
        } catch {
            throw NetworkError.encodingFailed
        }
    }
    
    
    
    /**
     Creates a multipart/form-data HTTP body that includes optional text fields and a single binary payload (e.g., an image/file).
     
     This helper assembles a body using the supplied `boundary`, appends each key–value pair in `parameters` as a regular form field, and then appends one file part using `data`, `mimeType`, and `fieldName`. The resulting `Data` ends with the required closing boundary.
     
     - Parameters:
     - parameters: Optional dictionary of additional form fields to include. Values are converted to strings via interpolation. The order of fields is not guaranteed.
     - boundary: The multipart boundary string used to separate parts. This same value must be supplied in the request’s `Content-Type` header (`multipart/form-data; boundary=...`).
     - data: The binary data to include as a single file part (e.g., JPEG/PNG bytes).
     - mimeType: The MIME type of the binary data (e.g., `"image/jpeg"`, `"image/png"`, `"application/pdf"`).
     - fieldName: The form field name for the file part (e.g., `"avatar"`, `"file"`).
     
     - Returns: A `Data` value containing the complete multipart/form-data body, including the closing boundary.
     
     - Important:
     - You must set the request header `Content-Type` to `multipart/form-data; boundary=\(boundary)`.
     - The file part’s `filename` is hard-coded as `"profile.jpg"`; adjust the implementation if you need to control the filename.
     - Ensure `boundary` is unique and does not appear in any field values or file data.
     
     - Notes:
     - Uses CRLF (`\r\n`) line breaks per RFC 7578.
   - Parameters are appended as plain text fields.
   - This function does not modify headers; it only returns the HTTP body.

 - Complexity: O(p + d) where `p` is the number of parameters and `d` is the size of `data`.

 - See also: RFC 7578 (Multipart Form Data)
 */
    
    func createBody(
        parameters: Parameters? = nil,
        boundary: String,
        data: Data,
        mimeType: String,
        fieldName: String
    ) -> Data {
        
        let body = NSMutableData()
        var bodyString = ""
        
        let boundaryPrefix = "--\(boundary)\r\n"
        

        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString(boundaryPrefix)
                
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
                
                bodyString = bodyString.appending(boundaryPrefix)
                
                bodyString = bodyString.appending("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                bodyString = bodyString.appending("\(value)\r\n")
            }
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"profile.jpg\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--\r\n")))
        
        bodyString = bodyString.appending(boundaryPrefix)
        bodyString = bodyString.appending("Content-Disposition: form-data; name=\"picture\"; filename=\"profile.jpg\"\r\n")
        bodyString = bodyString.appending("Content-Type: \(mimeType)\r\n\r\n")
        bodyString = bodyString.appending("[IMAGE-DATA]")
        bodyString = bodyString.appending("\r\n")
        bodyString = bodyString.appending("--".appending(boundary.appending("--\r\n")))
        
        return body as Data
    }
    
}


extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
