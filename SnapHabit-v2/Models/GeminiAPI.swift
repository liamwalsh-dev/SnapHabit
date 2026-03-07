/// This file defines the data models used for interacting with the Gemini API.
/// It includes request and response structures, as well as error handling.

/// This struct represents an error response from the Gemini API.
/// It uses GeminiError to encapsulate the error details.
/// - SeeAlso: `GeminiError`
struct GeminiErrorResponse: Codable {
    let error: GeminiError
}

/// This struct represents the details of an error from the Gemini API.
/// It includes the error code, message, and status.
/// - SeeAlso: `GeminiErrorResponse`
struct GeminiError: Codable {
    let code: Int
    let message: String
    let status: String
}

/// This struct represents a request to the Gemini API.
/// It includes the content to be processed and the generation configuration.
/// - SeeAlso: `GeminiContent`, `GeminiGenerationConfig`
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

/// This struct represents the content part of a Gemini API response.
/// It includes an array of text parts.
/// It uses GeminiPart to represent each individual part of the content.
/// 
/// - SeeAlso: `GeminiPart`
struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

/// This struct represents a part of the content in a Gemini API response.
/// It includes the text of the part.
/// - SeeAlso: `GeminiContent`
struct GeminiPart: Codable {
    let text: String
}

/// This struct represents the configuration for text generation in the Gemini API.
/// It includes parameters like temperature and maximum output tokens.
/// - SeeAlso: `GeminiRequest`
struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let maxOutputTokens: Int
}

/// This struct represents the response from the Gemini API.
/// It includes an array of candidate responses.
/// It uses GeminiCandidate to represent each individual candidate.
/// - SeeAlso: `GeminiCandidate`
struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

/// This struct represents a candidate response from the Gemini API.
/// It includes the content of the candidate.
/// - SeeAlso: `GeminiResponse`, `GeminiContent`
struct GeminiCandidate: Codable {
    let content: GeminiResponseContent
}

/// This struct represents the content of a Gemini response candidate.
/// It includes either an array of parts or a text string.
/// - SeeAlso: `GeminiCandidate`
struct GeminiResponseContent: Codable {
    let parts: [GeminiResponsePart]?
    let text: String?
    
    // Custom initializer to handle different response structures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode parts first
        parts = try container.decodeIfPresent([GeminiResponsePart].self, forKey: .parts)
        
        // Try to decode text directly
        text = try container.decodeIfPresent(String.self, forKey: .text)
        
        // If neither parts nor text exist, this might be an invalid response
        if parts == nil && text == nil {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Content must have either 'parts' or 'text'"
                )
            )
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case parts, text
    }
}

/// This struct represents a part of the response content in a Gemini API response.
/// It includes the text of the part.
/// - SeeAlso: `GeminiResponseContent`
struct GeminiResponsePart: Codable {
    let text: String
}