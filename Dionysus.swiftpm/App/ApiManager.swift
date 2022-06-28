import SwiftUI

class ApiManager {
    let host = "http://localhost:8000"
    
    var token = "1f17416b60aea734018a7049b3b3b31bfe65eea65c06ddae666f0cb39968d12e"
    
    func loadAdditions(completionHandler: @escaping ([Addition]) -> Void) {
        guard let url = URL(string: "\(host)/api/v1/addition") else {
            print("error URL: addition-list")
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = [
            "Authorization": "Token \(token)"
        ]
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("could not format HttpResponse")
                return
            }
            
            guard let data = data else { return }
            if httpResponse.statusCode != 200 {
                print("error statusCode \(httpResponse.statusCode):", String(data: data, encoding: .utf8) ?? "")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData =  try decoder.decode(AdditionResults.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(decodedData.results)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
