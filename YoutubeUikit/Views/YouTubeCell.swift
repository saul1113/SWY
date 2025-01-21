//
//  YouTubeCell.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import UIKit

class YouTubeCell: UITableViewCell {
    private let thumnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let channelLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        thumnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        channelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        channelLabel.font = UIFont.boldSystemFont(ofSize: 14)
        channelLabel.textColor = .systemGray
        
        contentView.addSubview(thumnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelLabel)
        
        NSLayoutConstraint.activate([
            thumnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumnailImageView.widthAnchor.constraint(equalToConstant: 100),
            thumnailImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            channelLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            channelLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            channelLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            channelLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with video: YoutubeSearchModel.Video) {
        titleLabel.text = video.snippet.title
        channelLabel.text = video.snippet.channelTitle
        
        if let url = URL(string: video.snippet.thumbnails.medium.url) {
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.imageView?.image = UIImage(data: data)
                    }
                } catch {
                    print("Error downloading image: \(error)")
                }
            }
        }
    }
}
