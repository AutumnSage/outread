import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchArticles() -> AnyPublisher<[Article], Error> {
        // Adjust the URL to fetch the first 100 articles with embedded media information
        guard let url = URL(string: "https://out-read.com/wp-json/wp/v2/article?_embed&per_page=30") else {
            // Use Fail to immediately return an error if the URL is incorrect
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // Access the data from the response
            .decode(type: [Article].self, decoder: JSONDecoder()) // Decode the data into an array of Articles
            .receive(on: DispatchQueue.main) // Ensure the publisher delivers events on the main thread
            .eraseToAnyPublisher() // Erase the specific publisher type to `AnyPublisher`
    }
    
    func fetchCategories(excludingParentID parentID: Int) -> AnyPublisher<[Category], Error> {
        let urlString = "https://out-read.com/wp-json/wc/v3/products/categories"
        let urlComponents = URLComponents(string: urlString)!
        
        // Assuming you have consumerKey and consumerSecret stored securely
        let consumerKey = "ck_613654b429f3f735d867c2bd6f1ef1f27702e2fd"
        let consumerSecret = "cs_e74484bfc016c729317db18c9cde9338eaaba4ba"
        
        // Basic Auth
        let loginString = "\(consumerKey):\(consumerSecret)"
        guard let loginData = loginString.data(using: .utf8) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let base64LoginString = loginData.base64EncodedString()
        
        guard let url = urlComponents.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Category].self, decoder: JSONDecoder())
            .map { categories in
                categories.filter { $0.parent != parentID }
            }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
    }
    
