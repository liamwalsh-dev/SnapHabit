import Foundation

/// A model representing a motivational quote, including its text, author, and HTML representation.
///
/// This model is used to fetch quotes from ZenQuotes API, store and manage them within the application.
/// Each quote has the quote text, the author's name, and an HTML formatted version of the quote.
///
/// - SeeAlso: ZenQuotes API (https://zenquotes.io/)
/// 
/// # Computed Properties:
///  - quoteText: String - The main text of the quote.
///  - author: String - The name of the author.
///  - displayText: String - A formatted string for displaying the quote.
///  - displayAuthor: String - A formatted string for displaying the author's name.
/// 
struct Quote: Codable, Equatable {
    let q: String
    let a: String
    let h: String // HTML formatted string

    var quoteText: String {
       return q
    }
    var author: String {
       return a
    }

    var displayText: String {
        return "\"\(q)\""
    }
    
    var displayAuthor: String {
        return "— \(a)"
    }
}
