//
//  SearchViewController.swift
//  MovieDB-CSS214
//
//  Created by Sapuan Talaspay on 11/5/25.
//


import UIKit
import SnapKit

final class SearchViewController: UIViewController,
                                  UISearchResultsUpdating,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegate {

    private var searchController = UISearchController(searchResultsController: nil)
    private var collectionView: UICollectionView!
    private var movies: [Result] = []
    private var sortOrder: SortOrder = .none
    private var currentPage = 1
    private var totalPages = 1
    private var currentQuery = ""
    private var isLoading = false
    private var viewState: ViewState = .categories
    private var currentGenreID: Int?

    enum ViewState { case categories, searchResults }
    enum SortOrder { case none, ascending, descending }

    private let resultsCountLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        return l
    }()

    private let sortButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "sorting")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7)
        b.layer.cornerRadius = 20
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.2
        b.layer.shadowRadius = 4
        b.layer.shadowOffset = CGSize(width: 0, height: 2)
        b.alpha = 0
        return b
    }()

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7)
        b.layer.cornerRadius = 20
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.2
        b.layer.shadowRadius = 4
        b.layer.shadowOffset = CGSize(width: 0, height: 2)
        b.alpha = 0
        b.addTarget(self, action: #selector(backToCategories), for: .touchUpInside)
        return b
    }()

    private let genres = [
        (id: 28, name: "Боевик", sampleMovieID: 27205),
        (id: 12, name: "Приключения", sampleMovieID: 12445),
        (id: 16, name: "Мультфильм", sampleMovieID: 260514),
        (id: 35, name: "Комедия", sampleMovieID: 35),
        (id: 18, name: "Драма", sampleMovieID: 550),
        (id: 27, name: "Ужасы", sampleMovieID: 77336),
        (id: 878, name: "Фантастика", sampleMovieID: 155)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground

        setupSearchController()
        setupSortButton()
        setupBackButton()
        setupResultsCountLabel()
        setupCollectionView()
    }

    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search for movies..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }

    private func setupSortButton() {
        view.addSubview(sortButton)
        sortButton.addTarget(self, action: #selector(showSortSheet), for: .touchUpInside)
        sortButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(40)
        }
    }

    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(40)
        }
    }

    private func setupResultsCountLabel() {
        resultsCountLabel.alpha = 0
        view.addSubview(resultsCountLabel)
        resultsCountLabel.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 16
        let itemsPerRow: CGFloat = 2
        let totalSpacing = (itemsPerRow + 1) * spacing
        let itemWidth = (view.frame.width - totalSpacing) / itemsPerRow
        let itemHeight = itemWidth * 1.4

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        collectionView.register(GenrePosterCell.self, forCellWithReuseIdentifier: "GenrePosterCell")

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(resultsCountLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces),
              !query.isEmpty else {
            if viewState == .searchResults {
                viewState = .categories
                currentGenreID = nil
                currentQuery = ""
                movies = []
                collectionView.reloadData()
                resultsCountLabel.alpha = 0
                updateButtonsVisibility()
            }
            return
        }

        viewState = .searchResults
        currentGenreID = nil
        currentQuery = query
        currentPage = 1
        isLoading = true

        NetworkManager.shared.searchMovies(query: query, page: currentPage) { [weak self] response in
            guard let self = self, let response = response else { return }
            self.movies = response.results ?? []
            self.totalPages = response.totalPages ?? 1
            self.isLoading = false

            let total = response.totalResults ?? self.movies.count
            DispatchQueue.main.async {
                self.resultsCountLabel.text = "Найдено: \(total) фильмов"
                self.resultsCountLabel.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.resultsCountLabel.alpha = 1
                    self.updateButtonsVisibility()
                }
                self.applySort()
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pos = scrollView.contentOffset.y
        let height = collectionView.contentSize.height
        let frame = scrollView.frame.height
        if pos > height - frame * 1.5 { loadNextPageIfNeeded() }
    }

    private func loadNextPageIfNeeded() {
        guard !isLoading, currentPage < totalPages, sortOrder == .none, viewState == .searchResults else { return }
        isLoading = true
        let start = movies.count
        currentPage += 1

        if let genreID = currentGenreID {
            NetworkManager.shared.loadMoviesByGenre(genreID: genreID, page: currentPage) { [weak self] response in
                self?.handlePaginationResponse(response, start: start)
            }
        } else {
            NetworkManager.shared.searchMovies(query: currentQuery, page: currentPage) { [weak self] response in
                self?.handlePaginationResponse(response, start: start)
            }
        }
    }

    private func handlePaginationResponse(_ response: SearchResponse?, start: Int) {
        guard let response = response else { return }
        let new = response.results ?? []
        movies.append(contentsOf: new)
        totalPages = response.totalPages ?? totalPages
        isLoading = false

        let indices = (start..<movies.count).map { IndexPath(item: $0, section: 0) }
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates { self.collectionView.insertItems(at: indices) }
        }
    }

    private func loadMoviesByGenre(_ genreID: Int) {
        viewState = .searchResults
        currentGenreID = genreID
        currentQuery = ""
        isLoading = true
        currentPage = 1

        NetworkManager.shared.loadMoviesByGenre(genreID: genreID, page: currentPage) { [weak self] response in
            guard let self = self, let response = response else { return }
            self.movies = response.results ?? []
            self.totalPages = response.totalPages ?? 1
            self.isLoading = false

            DispatchQueue.main.async {
                let name = self.genres.first(where: { $0.id == genreID })?.name ?? "Жанр"
                self.resultsCountLabel.text = name
                self.resultsCountLabel.alpha = 1
                self.collectionView.reloadData()
                self.updateButtonsVisibility()
            }
        }
    }

    private func loadPosterForGenre(_ genreID: Int, sampleMovieID: Int, completion: @escaping (URL?) -> Void) {
        NetworkManager.shared.loadMovieDetail(movieID: sampleMovieID) { detail in
            let urlString = "https://image.tmdb.org/t/p/w500" + (detail.posterPath ?? "")
            completion(URL(string: urlString))
        }
    }

    @objc private func backToCategories() {
        viewState = .categories
        currentGenreID = nil
        currentQuery = ""
        sortOrder = .none
        movies = []
        resultsCountLabel.alpha = 0
        collectionView.reloadData()
        updateButtonsVisibility()
    }

    @objc private func showSortSheet() {
        let sheet = SortBottomSheetViewController()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        sheet.selected = sortOrder

        sheet.onSelect = { [weak self] order in
            guard let self = self else { return }
            self.sortOrder = order
            self.currentPage = 1
            self.applySort()
            self.animateButton()
        }
        present(sheet, animated: true)
    }

    private func animateButton() {
        UIView.animate(withDuration: 0.15, animations: {
            self.sortButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.sortButton.transform = .identity
            }
        })
    }

    private func applySort() {
        switch sortOrder {
        case .ascending:  movies.sort { ($0.voteAverage ?? 0) < ($1.voteAverage ?? 0) }
        case .descending: movies.sort { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        case .none: break
        }
        UIView.transition(with: collectionView, duration: 0.25, options: .transitionCrossDissolve) {
            self.collectionView.reloadData()
        }
    }

    private func updateButtonsVisibility() {
        let isSearch = viewState == .searchResults
        UIView.animate(withDuration: 0.3) {
            self.backButton.alpha = isSearch ? 1 : 0
            self.sortButton.alpha = isSearch ? 1 : 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewState {
        case .categories: return genres.count
        case .searchResults: return movies.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewState {
        case .categories:
            guard indexPath.item < genres.count else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenrePosterCell", for: indexPath) as! GenrePosterCell
            let genre = genres[indexPath.item]
            cell.configure(with: genre.name, posterURL: nil)

            loadPosterForGenre(genre.id, sampleMovieID: genre.sampleMovieID) { url in
                DispatchQueue.main.async {
                    if let cell = collectionView.cellForItem(at: indexPath) as? GenrePosterCell {
                        cell.configure(with: genre.name, posterURL: url)
                    }
                }
            }
            return cell

        case .searchResults:
            guard indexPath.item < movies.count else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            cell.configure(with: movies[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewState {
        case .categories:
            guard indexPath.item < genres.count else { return }
            let genre = genres[indexPath.item]
            loadMoviesByGenre(genre.id)

        case .searchResults:
            guard indexPath.item < movies.count, let id = movies[indexPath.item].id else { return }
            let vc = MovieDetailViewController()
            vc.movieID = id
            NetworkManager.shared.loadVideo(movieID: id) { result in
                let key = result.first(where: { $0.type == "Trailer" })?.key ?? result.first?.key
                vc.trailerKey = key
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
