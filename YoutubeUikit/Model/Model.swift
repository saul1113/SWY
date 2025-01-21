//
//  Model.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import Foundation

struct YoutubeSearchModel: Codable {
    let items: [Video]
    let nextPageToken: String?
    
    struct Video: Codable {
        let id: VideoID
        let snippet: Snippet
    }
    
    struct VideoID: Codable {
        let videoId: String
        
        private enum CodingKeys: String, CodingKey {
            case videoId = "videoId"
        }
    }
    
    struct Snippet: Codable {
        let title: String
        let channelTitle: String
        let thumbnails: Thumbnails
    }
    
    struct Thumbnails: Codable {
        let medium: Thumbnail
    }
    
    struct Thumbnail: Codable {
        let url: String
    }
}
