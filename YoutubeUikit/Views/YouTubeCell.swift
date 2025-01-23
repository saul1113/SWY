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
    private let channelImage = UIImageView()
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
        channelImage.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        channelLabel.font = UIFont.boldSystemFont(ofSize: 14)
        channelLabel.textColor = .gray
        channelImage.contentMode = .scaleAspectFit
        channelImage.clipsToBounds = true
        channelImage.layer.cornerRadius = 20
//        channelImage.layer.borderWidth = 1
//        channelImage.layer.borderColor = UIColor.gray.cgColor
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(channelImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelLabel)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -70),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 200),
            
            channelImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            channelImage.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            channelImage.widthAnchor.constraint(equalToConstant: 40),
            channelImage.heightAnchor.constraint(equalToConstant: 40),
            
            channelLabel.leadingAnchor.constraint(equalTo: channelImage.trailingAnchor, constant: 8),
            channelLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: channelImage.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            
        ])
    }
    
    func configure(with video: YoutubeSearchModel.Video, channelImageURL: String?) {
        titleLabel.text = video.snippet.title
        channelLabel.text = video.snippet.channelTitle
        
        print("Channel Image URL:", channelImageURL ?? "nil")
        
        // 썸네일 이미지 로드
        if let thumbnailURL = video.snippet.thumbnails.medium.url {
            loadImage(from: thumbnailURL, into: thumbnailImageView, placeholder: "placeholder")
        }
        
        // 채널 이미지 로드
        if let channelImageURL = channelImageURL {
            loadImage(from: channelImageURL, into: channelImage, placeholder: "placeholder")
        } else {
            channelImage.image = UIImage(named: "placeholder")
        }
        
        // 캐시 확인
        func loadImage(from urlString: String, into imageView: UIImageView, placeholder: String) {
            if let cachedImage = YouTubeCell.imageCache.object(forKey: urlString as NSString) {
                //NSCache에서 이미 다운로드된 이미지를 확인
                //urlString을 키로 사용해 캐싱된 이미지를 가져옴
                imageView.image = cachedImage
                //다운로드를 생략하고 캐싱된 이미지를 사용하여 로딩 시간을 줄임.
                return
            }
            
            // 비동기로 이미지 다운로드 및 캐싱
            imageView.image = UIImage(named: "placeholder")
            DispatchQueue.global().async {
                guard let url = URL(string: urlString) else { return }
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                            YouTubeCell.imageCache.setObject(image, forKey: urlString as NSString)
                        }
                    }
                } catch {
                    print("Error downloading image: \(error)")
                }
            }
        }
    }
}

