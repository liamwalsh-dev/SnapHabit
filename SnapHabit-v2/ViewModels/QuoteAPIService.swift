import Foundation

/// Class to represent a quote from the API
/// 
/// This Class is used to decode the JSON response from the quote API (https://zenquotes.io/api/random).
/// It contains two properties: `q` for the quote text and `a` for the author of the quote.
/// # Properties:
///  - `q`: A string representing the quote text.
///  - `a`: A string representing the author of the quote.
/// # Methods:
///  - `fetchQuoteFromAPI()`: Fetches a new quote from the API.
///  - `loadQuote()`: Loads a quote, either from cache or by fetching from the API.
///  - `cacheQuote(quote:author:)`: Caches the fetched quote and author in UserDefaults.
///  - `getCachedQuote()`: Retrieves the cached quote from UserDefaults.
///  - `getCachedAuthor()`: Retrieves the cached author from UserDefaults.
///  - `todayString()`: Returns the current date as a string in "yyyy-MM-dd" format.
///
@MainActor
class QuoteAPIService: ObservableObject {
    @Published var quote: String = ""
    @Published var author: String = ""
    @Published var errorMessage: String = ""

    private let apiUrl = "https://zenquotes.io/api/random"
    private let userDefaults = UserDefaults.standard
    
    private let quoteDateKey = "lastQuoteFetchDate"    
    private let quoteTextKey = "lastFetchedQuote"
    private let quoteAuthorKey = "lastFetchedQuoteAuthor"

    init() {
        Task {
            await loadQuote()
        }
    }
    
    /// Function loads the quote, either from cache or by fetching from the API.
    /// 
    /// Checks if a quote has already been fetched today. If so, it loads the cached quote and author.
    /// If not, it fetches a new quote from the API and caches it.
    /// 
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    /// - SeeAlso: `fetchQuoteFromAPI()`, `cacheQuote(quote:author:)`, `getCachedQuote()`, `getCachedAuthor()`, `todayString()`
    private func loadQuote() async {
        let today = todayString()
        let lastFetchDate = userDefaults.string(forKey: quoteDateKey)

        if (lastFetchDate == today){
            if let cachedQuote = getCachedQuote(), let cachedAuthor = getCachedAuthor() {
                self.quote = cachedQuote
                self.author = cachedAuthor
                return
            }
        }

        await fetchQuoteFromAPI()
    }

    /// Function fetches a new quote from the API.
    /// 
    /// Makes a network request to the quote API, decodes the JSON response, and updates
    /// the `quote` and `author` properties. It also calls `cacheQuote(quote:author:)` to store the fetched quote.
    /// Handles errors related to network issues and JSON decoding.
    /// 
    /// - Parameters: None
    /// - Returns: None
    /// - Throws: None
    /// - SeeAlso: `cacheQuote(quote:author:)`
    private func fetchQuoteFromAPI() async {
        guard let url = URL(string: apiUrl) else {
            self.errorMessage = "Invalid URL"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.errorMessage = "Invalid response from server"
                return
            }

            if let quoteResponse = try? JSONDecoder().decode([Quote].self, from: data).first {
                self.quote = quoteResponse.q
                self.author = quoteResponse.a
                cacheQuote(
                    quote: quoteResponse.q,
                    author: quoteResponse.a
                )
            } else {
                self.errorMessage = "Failed to decode response"
            }
        } catch {
            self.errorMessage = "Network error: \(error.localizedDescription)"
        }
    }

    /// Function caches the fetched quote and author in UserDefaults.
    /// - Parameters:
    ///   - quote: The quote text to cache.
    ///   - author: The author of the quote to cache.
    private func cacheQuote(quote: String, author: String) {
        let today = todayString()
        userDefaults.set(today, forKey: quoteDateKey)
        userDefaults.set(quote, forKey: quoteTextKey)
        userDefaults.set(author, forKey: quoteAuthorKey)
    }

    // MARK: - Helper Functions

    /// Retrieves the cached quote from UserDefaults.
    /// - Returns: The cached quote string, or `nil` if not found.
    private func getCachedQuote() -> String? {
        return userDefaults.string(forKey: quoteTextKey)
    }

    /// Retrieves the cached author from UserDefaults.
    /// - Returns: The cached author string, or `nil` if not found.
    private func getCachedAuthor() -> String? {
        return userDefaults.string(forKey: quoteAuthorKey)
    }
    /// Returns the current date as a string in "yyyy-MM-dd" format.
    /// - Returns: A string representing today's date.
    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
