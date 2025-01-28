//
//  ImageCacheManager.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/28/25.
//

import Foundation
import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let fileManager = FileManager.default
    private let cacheURL: URL
    
    private init() {
        cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: cacheURL.path) {
            try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func saveImage(_ image: UIImage, for key: String) {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        let filePath = cacheURL.appendingPathComponent(key)
        try? data.write(to: filePath)
    }
    
    func loadImage(for key: String) -> UIImage? {
        let filePath = cacheURL.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: filePath.path),
            let data = try? Data(contentsOf: filePath),
              let image = UIImage(data: data) else { return nil }
        return image
    }
}

/*
 직접 이미지 캐싱을 하면, 이미지를 로컬에 저장 할 수 있다. 로컬 디스크 저장
 NSCache를 쓰게되면, 데이터는 앱 종료시 삭제되고 메모리 캐싱 방식
 NSCache가 속도가 빠르다 (RAM 사용)
 직접 캐스팅은 비교적 느릴 수 있ㄷ다. (디스크 접근)
 */
