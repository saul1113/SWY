//
//  APIData.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import Foundation

class APIData {
    
    private let apiKey = getApiKey() ?? ""
    private let apiURL = "https://www.googleapis.com/youtube/v3/search"
    
    func fetchVideoData(keyword: String, pageToken:String?, completion: @escaping  (Result<YoutubeSearchModel, Error>) -> Void ) {
        var urlString = "\(apiURL)?q=\(keyword)&part=snippet&maxResults=10&key=\(apiKey)"
        if let token = pageToken {
            urlString += "&pageToken=\(token)"
        }
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(YoutubeSearchModel.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
}

func getApiKey() -> String? {
    guard let path = Bundle.main.path(forResource: "SecretKey", ofType: "plist"),
          let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
          let apiKey = dictionary["API_KEY"] as? String else {
        return nil
    }
    return apiKey
}
