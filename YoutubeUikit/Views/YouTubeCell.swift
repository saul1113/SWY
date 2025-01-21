//
//  YouTubeCell.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import UIKit

class YouTubeCell: UITableViewCell {
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let channelLabel = UILabel()
    private static let imageCache = NSCache<NSString, UIImage>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        channelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        channelLabel.font = UIFont.boldSystemFont(ofSize: 10)
        channelLabel.textColor = .gray
                
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelLabel)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 200),
                        
            channelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            channelLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: channelLabel.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            
        ])
    }
    
    func configure(with video: YoutubeSearchModel.Video) {
        titleLabel.text = video.snippet.title
        channelLabel.text = video.snippet.channelTitle
        
        // 썸네일 이미지 로드
        let urlString = video.snippet.thumbnails.medium.url
        if let url = URL(string: urlString) {
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.thumbnailImageView.image = UIImage(data: data)
                    }
                } catch {
                    print("Error downloading image: \(error)")
                }
            }
            
            // 캐시 확인
            if let cachedImage = YouTubeCell.imageCache.object(forKey: urlString as NSString) {
                //NSCache에서 이미 다운로드된 이미지를 확인
                //urlString을 키로 사용해 캐싱된 이미지를 가져옴
                thumbnailImageView.image = cachedImage
                //다운로드를 생략하고 캐싱된 이미지를 사용하여 로딩 시간을 줄임.
                return
            }
            
            // 비동기로 이미지 다운로드 및 캐싱
            thumbnailImageView.image = UIImage(named: "placeholder")
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            self?.thumbnailImageView.image = image
                            YouTubeCell.imageCache.setObject(image, forKey: urlString as NSString) // 캐싱
                        }
                    }
                } catch {
                    print("Error downloading image: \(error)")
                }
            }
        }
    }
}
