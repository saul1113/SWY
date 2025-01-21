//
//  YoutubeViewController.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import UIKit

class YoutubeViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let api = APIData()
    
    private var videos: [YoutubeSearchModel.Video] = []
    private var nextPage: String?
    private var loading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        view.backgroundColor = .systemBackground
        
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YouTubeCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchVideos(keyword: String) {
        guard !loading else { return }
        loading = true
        
        api.fetchVideoData(keyword: keyword, pageToken: nextPage) { [weak self] result in
            guard let self else { return }
            self.loading = false
            
            switch result {
            case .success(let response):
                self.nextPage = response.nextPageToken
                self.videos.append(contentsOf: response.items)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}

// MARK: - 테이블뷰 및 서치바 Extension
extension YoutubeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! YouTubeCell
        let video = videos[indexPath.row]
        cell.configure(with: video)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        let webVC = WebViewController()
        webVC.videoID = video.id.videoId
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension YoutubeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        videos = []     //video 리셋
        nextPage = nil
        tableView.reloadData()
        fetchVideos(keyword: keyword)
    }
}
