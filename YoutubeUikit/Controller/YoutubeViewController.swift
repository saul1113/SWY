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
    private let youtubeLogo = UIImageView()
    
    private let api = APIData()
    private let searchHistoryKey = "SearchHistoryKey"
    private var searchHistory: [String] = []
    private var videos: [(video: YoutubeSearchModel.Video, channelImageURL: String?)] = []
    private var nextPage: String?
    private var loading = false
    private var isSearching = false
    
    private var diffableDataSource: UITableViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configDataSource()
        loadSearchHistory()
    }
    
    // MARK: - Section & Item
    enum Section {
        case history
        case results
    }
    
    enum Item: Hashable, Equatable {    //Item 타입은 반드시 Hashable, Equtable 프로토콜을 반드시 명시해야함
        static func == (lhs: Item, rhs: Item) -> Bool { //Eautable 프로토콜 채택 시 필수 구조체
            switch (lhs, rhs) {
            case (.history(let keyword1), .history(let keyworkd2)):
                return keyword1 == keyworkd2
            case (.video(let video1, let image1), .video(let video2, let image2)):
                return video1.id.videoId == video2.id.videoId && image1 == image2
            default:
                return false
            }
        }
        
        case history(String)
        case video(YoutubeSearchModel.Video, String?)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .history(let keyword):
                hasher.combine(keyword)
            case .video(let video, _):
                hasher.combine(video.id.videoId)
//                hasher.combine(channelImageURL ?? "")
            }
        }
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupLogo()
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupLogo() {
        youtubeLogo.image = UIImage(named: "youtube")
        youtubeLogo.contentMode = .scaleAspectFit
        youtubeLogo.translatesAutoresizingMaskIntoConstraints = false
        youtubeLogo.isHidden = false
        view.addSubview(youtubeLogo)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.register(YouTubeCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            youtubeLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            youtubeLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            youtubeLogo.widthAnchor.constraint(equalToConstant: 300),
            youtubeLogo.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        view.bringSubviewToFront(youtubeLogo)
        // 테이블뷰가 로고를 덮고있어서, 로고를 최상위에 올리기

    }
    
    private func setupNavigationBar() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    
    // MARK: - Diffable Datasource
    
    private func configDataSource() {
        diffableDataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .history(let keyword):
                let cell = UITableViewCell()
                cell.textLabel?.text = keyword
                return cell
            case .video(let video, let channelImageURL):
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! YouTubeCell
                
                cell.configure(with: video, channelImageURL: channelImageURL) //cell검색 화면이 안떠서 config호출 추가
                return cell
            }
        }
        
        tableView.dataSource = diffableDataSource
        applySnapshot()
    }
    
    // MARK: - Snapshot
    
    private func applySnapshot() {
        var snapShot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        if isSearching {
            snapShot.appendSections([.results])
            snapShot.appendItems(videos.map { .video($0.video, $0.channelImageURL)}, toSection: .results)
        } else {
            snapShot.appendSections([.history])
            snapShot.appendItems(searchHistory.map { .history($0) }, toSection: .history)
        }
        DispatchQueue.main.async {
            self.diffableDataSource.apply(snapShot, animatingDifferences: true)
        }
    }
    
    // MARK: - 검색 히스토리 메서드
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: searchHistoryKey) ?? []
    }
    
    private func saveSearchHistory(keyword: String) {
        // 중복된 검색어는 제거
        if let existingIndex = searchHistory.firstIndex(of: keyword) {
            searchHistory.remove(at: existingIndex)
        }
        // 최신 검색어를 맨 앞에 추가
        searchHistory.insert(keyword, at: 0)
        // 검색 기록의 최대 개수를 제한
        if searchHistory.count > 5 {
            searchHistory.removeLast()
        }
        // UserDefaults에 저장
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
    }
    
    // MARK: - API Fetch
    private func fetchVideos(keyword: String) {
        guard !loading else { return }
        loading = true
        
        api.fetchVideoData(keyword: keyword, pageToken: nextPage) { [weak self] result in
            guard let self = self else { return }
            self.loading = false
            
            switch result {
            case .success(let response):
                self.nextPage = response.nextPageToken
                var fetchedVideos = response.items.map { video in
                    (video: video, channelImageURL: String?.none)
                }
                
                let channelIDs = response.items.map { $0.snippet.channelId }
                self.api.fetchChannelImages(channelIDs: channelIDs) { channelResult in
                    switch channelResult {
                    case .success(let channelImages):
                        let updatedVideos = fetchedVideos.map { (video, _) in
                            (video: video, channelImageURL: channelImages[video.snippet.channelId])
                        }
                        self.videos.append(contentsOf: updatedVideos)
                    case .failure(let error):
                        print("Error fetching channel images: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        self.applySnapshot()
                    }
                }
            case .failure(let error):
                print("Error fetching videos: \(error)")
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension YoutubeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = false
        applySnapshot()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        youtubeLogo.isHidden = true // 검색 버튼 클릭 시 로고 숨김
        isSearching = true
        
        saveSearchHistory(keyword: keyword)
        videos = []
        nextPage = nil
        
        applySnapshot()
        fetchVideos(keyword: keyword)
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension YoutubeViewController: UITableViewDelegate {  //Diffable Datasource를 쓰기 때문에 UITableViewDatasource (cellForRowAt)은 필요없음.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return diffableDataSource.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffableDataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .history(let keyword):
            searchBar.text = keyword
            searchBarSearchButtonClicked(searchBar)
        case .video(let video, _):
            let webVC = WebViewController()
            webVC.videoID = video.id.videoId
            navigationController?.pushViewController(webVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return nil}
        
        if case .history(let keyword) = item {
            
            let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completionHandler in
                guard let self = self else { return }
                // 검색 기록에서 해당 항목 삭제
                self.searchHistory.remove(at: indexPath.row)
                UserDefaults.standard.set(self.searchHistory, forKey: self.searchHistoryKey)
                
                //reload가 아닌 Snapshot 업데이트
                self.applySnapshot()
                completionHandler(true)
            }
            
            // 애니메이션 비활성화 (왼쪽에서 오른쪽 슬라이드 효과 제거)
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        return nil
    }
}

// MARK: - UIScrollViewDelegate

extension YoutubeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y    //스크롤 수직방향 위치
        let contentHeight = scrollView.contentSize.height   //스크롤뷰의 전체 콘텐츠 높이
        let height = scrollView.frame.size.height   //스크롤뷰의 표시되는 화면의 영역 높이
        
        //스크롤 콘텐츠 끝부분 100pt 이내에 도달했는지, 스크롤 가능한 가장 아래위치
        if offsetY > contentHeight - height - 100 && !loading && nextPage != nil {  //로딩중이면 추가요청 방지, 다음 페이지토큰이 있는지 확인
            fetchVideos(keyword: searchBar.text ?? "")  //키워드를 통해 추가 동영상 데이터를 가져오는
            
            /*
             •    - 100의 역할:
             •    데이터를 미리 로드하여 스크롤이 완료될 때까지 사용자에게 부드러운 경험을 제공합니다.
             •    만약 - 100 대신 0을 사용하면, 스크롤이 완전히 끝났을 때만 데이터를 로드합니다. 이는 사용자 경험에 영향을 줄 수 있습니다.
             •    loading 플래그:
             •    API 호출이 끝나기 전에 또 다른 요청을 보내는 것을 방지합니다.
             •    loading은 API 요청이 완료되면 다시 false로 설정됩니다.
             •    nextPage:
             •    YouTube API에서 반환되는 nextPageToken을 통해 페이지네이션을 구현합니다.
             •    nextPage가 nil이면 더 이상 추가 데이터를 요청하지 않습니다.
             */
        }
    }
}
