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
        let videoId: String?
    }
    
    struct Snippet: Codable {
        let title: String
        let channelTitle: String
        let channelId: String
        let thumbnails: Thumbnails
    }
    
    struct Thumbnails: Codable {
        let medium: Thumbnail
    }
    
    struct Thumbnail: Codable {
        let url: String?
    }
}

//채널 이미지 가져오기 위한 모델
struct YoutubeChannelModel: Codable {
    let items: [Channel]
    
    struct Channel: Codable {
        let id: String
        let snippet: Snippet
    }
    
    struct Snippet: Codable {
        let title: String
        let thumbnails: Thumbnails
    }
    
    struct Thumbnails: Codable {
        let medium: Thumbnail
    }
    
    struct Thumbnail: Codable {
        let url: String?
    }
}
