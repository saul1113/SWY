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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
        channelImage.image = nil
        titleLabel.text = nil
        channelLabel.text = nil
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
    
    // MARK: - 채널 이미지 fetch
    func configure(with video: YoutubeSearchModel.Video, channelImageURL: String?) {
        titleLabel.text = video.snippet.title
        channelLabel.text = video.snippet.channelTitle
        
        print("Channel Image URL:", channelImageURL ?? "nil")
        
        // 썸네일 이미지 로드
        if let thumbnailURL = video.snippet.thumbnails.medium.url {
            loadImage(from: thumbnailURL, into: thumbnailImageView)
        }
        
        // 채널 이미지 로드
        if let channelImageURL = channelImageURL {
            loadImage(from: channelImageURL, into: channelImage)
        } else {
            channelImage.image = UIImage(named: "placeholder")
        }
        
        // MARK: - 이미지 캐싱
        func loadImage(from urlString: String, into imageView: UIImageView) {
            if let cachedImage = ImageCacheManager.shared.loadImage(for: urlString) {
                imageView.image = cachedImage
                return
            }
            
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("이미지 다운로드 실패: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    imageView.image = image
                    ImageCacheManager.shared.saveImage(image, for: urlString)
                }
            }
            task.resume()
        }
    }
}

