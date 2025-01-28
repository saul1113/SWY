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
    private let channelURL = "https://www.googleapis.com/youtube/v3/channels"
    
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
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "API_Error", code: -1, userInfo: nil)))
                return
            }
       
            do {
                let response = try JSONDecoder().decode(YoutubeSearchModel.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// 채널 이미지
    func fetchChannelImages(channelIDs: [String], completion: @escaping (Result<[String: String], Error>) -> Void) {
        // 채널 ID 리스트를 콤마로 연결
        let ids = channelIDs.joined(separator: ",")
        let urlString = "\(channelURL)?part=snippet&id=\(ids)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(YoutubeChannelModel.self, from: data)
                // 채널 ID와 썸네일 URL의 매핑 생성
                let channelImages = response.items.reduce(into: [String: String]()) { dict, channel in
                    if let thumbnailURL = channel.snippet.thumbnails.medium.url {
                        dict[channel.id] = thumbnailURL
                    }
                }
                print("Channel Images Mapping:", channelImages)
                completion(.success(channelImages))
            } catch {
                print("Error decoding channel data:", error)
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
