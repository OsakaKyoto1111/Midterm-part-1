//
//  MovieDetailViewController.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 20.10.2025.
//

import UIKit
import YouTubeiOSPlayerHelper

class MovieDetailViewController: UIViewController, YTPlayerViewDelegate {
    
    var movieID = 0
    private var genre: [Genre] = []
    private var movieData: MovieDetail?
    private var casts: [Cast] = []
    var trailerKey: String?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var movieImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var movieTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var releaseStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var releaseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var genreCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .systemBackground
        collection.showsHorizontalScrollIndicator = false
        collection.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: "genre")
        return collection
    }()
    
    private lazy var starStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var countRatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var overviewView: UIView = {
        let overview = UIView()
        overview.translatesAutoresizingMaskIntoConstraints = false
        overview.backgroundColor = .systemGray5
        return overview
    }()
    
    private lazy var overviewTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var castLabel: UILabel = {
        let label = UILabel()
        label.text = "Cast"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var castCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .systemBackground
        collection.showsHorizontalScrollIndicator = false
        collection.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: "cast")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var castView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var playerView: YTPlayerView = {
        let player = YTPlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    
        apiRequest()
        playerView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let key = trailerKey {
            playerView.load(withVideoId: key)
        }
    }
    
    func content() {
        guard let movieData else { return }
        print(movieData.id)
        genre = movieData.genres
        genreCollectionView.reloadData()
        movieTitle.text = movieData.title
        releaseLabel.text = "Release date \(movieData.releaseDate ?? "coming soon")"
        NetworkManager.shared.loadImage(posterPath: movieData.posterPath) { data in
            self.movieImage.image = UIImage(data: data)
        }
        setStar(rating: movieData.voteAverage ?? 0)
        ratingLabel.text = String(format: "%.1f/10", movieData.voteAverage ?? 0.0)
        countRatingLabel.text = "\(movieData.voteCount ?? 0)"
        overviewTextLabel.text = movieData.overview
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    private func apiRequest() {
        NetworkManager.shared.loadMovieDetail(movieID: movieID) { movie in
            self.movieData = movie
            self.content()
        }
        
        NetworkManager.shared.loadCasts(movieID: movieID) { cast in
            self.casts = cast
            self.castCollectionView.reloadData()
        }
    }

    private func setStar(rating: Double) {
        let fillStar: Int = Int(rating / 2)
        let halfStar: Bool = Int(rating) % 2 == 1
        
        for _ in 1...fillStar {
            let fillStarImageView = UIImageView(image: UIImage(named: "fill"))
            fillStarImageView.snp.makeConstraints { make in
                make.height.equalTo(20)
                make.width.equalTo(20)
            }
            starStackView.addArrangedSubview(fillStarImageView)
        }
        if halfStar {
            let halfStarImageView = UIImageView(image: UIImage(named: "half_fill"))
            halfStarImageView.snp.makeConstraints { make in
                make.height.equalTo(20)
                make.width.equalTo(20)
            }
            starStackView.addArrangedSubview(halfStarImageView)
        }
        
        let emptyStar = 5 - fillStar - (halfStar ? 1 : 0)
        for _ in 1...emptyStar {
            let emptyStarImageView = UIImageView(image: UIImage(named: "not_fill"))
            emptyStarImageView.snp.makeConstraints { make in
                make.height.equalTo(20)
                make.width.equalTo(20)
            }
            starStackView.addArrangedSubview(emptyStarImageView)
        }
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        
        [movieImage, movieTitle, releaseStackView, ratingStackView, overviewView, playerView, castView].forEach {
            scrollView.addSubview($0)
        }
        
        [castLabel, castCollectionView].forEach {
            castView.addSubview($0)
        }
        
        overviewView.addSubview(overviewTextLabel)
        
        [releaseLabel, genreCollectionView].forEach {
            releaseStackView.addArrangedSubview($0)
        }
        
        [starStackView, ratingLabel, countRatingLabel].forEach {
            ratingStackView.addArrangedSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        movieImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(424)
            make.width.equalTo(309)
        }
        
        movieTitle.snp.makeConstraints { make in
            make.top.equalTo(movieImage.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        releaseStackView.snp.makeConstraints { make in
            make.top.equalTo(movieTitle.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(15)
            make.trailing.equalTo(scrollView.snp.centerX)
        }
        
        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(movieTitle.snp.bottom).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
        }
        
        genreCollectionView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview()
        }
        
        releaseLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        overviewView.snp.makeConstraints { make in
            make.top.equalTo(ratingStackView.snp.bottom).offset(30)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
        }
        
        overviewTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-30)
        }
        
        playerView.snp.makeConstraints { make in
            make.top.equalTo(overviewView.snp.bottom).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalTo(castView.snp.top).offset(-10)
        }
        
        castView.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        castLabel.snp.makeConstraints { make in
            make.top.equalTo(castView.snp.top)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        castCollectionView.snp.makeConstraints { make in
            make.top.equalTo(castLabel.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
            make.bottom.equalTo(castView.snp.bottom)
        }
        
    }
}

extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == genreCollectionView {
            return genre.count
        } else {
            return casts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollectionView {
            let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: "genre", for: indexPath) as! GenreCollectionViewCell
            let genre = genre[indexPath.row].name
            cell.label.text = genre
            return cell
        } else {
            let cell = castCollectionView.dequeueReusableCell(withReuseIdentifier: "cast", for: indexPath) as! CastCollectionViewCell
            let cast = casts[indexPath.row]
            cell.conf(cast: cast)
            return cell
        }
    }
}

extension MovieDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genreCollectionView {
            let label = UILabel()
            let genre = genre[indexPath.row].name
            label.text = genre
            label.sizeToFit()
            return CGSize(width: label.frame.width + 20, height: 30)
        } else {
            let cast = casts[indexPath.row]
            let nameLabel = UILabel()
            let roleLabel = UILabel()
            nameLabel.text = cast.name
            roleLabel.text = cast.character
            nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            roleLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
            nameLabel.sizeToFit()
            roleLabel.sizeToFit()
            let maxWidth = max(nameLabel.frame.width, roleLabel.frame.width) + 130
            return CGSize(width: maxWidth, height: 120)
        }
    }
}
