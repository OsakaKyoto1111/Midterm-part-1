//
//  ViewController.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 06.10.2025.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var movieLabel: UILabel = {
        let label = UILabel()
        label.text = "MovieDB"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "movie")
        
        table.separatorStyle = .none
        return table
    }()
    
    var movieData: [Result] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        apiRequest()
    }

    private func setupUI() {
        view.addSubview(movieLabel)
        view.addSubview(movieTableView)
        
        NSLayoutConstraint.activate([
            movieLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            movieLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            movieLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            movieTableView.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 20),
            movieTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            movieTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            movieTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func apiRequest() {
        NetworkManager.shared.loadMovie { result in
            self.movieData = result
            self.movieTableView.reloadData()
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath) as! MovieTableViewCell
        let movie = movieData[indexPath.row]
        cell.movieTitle.text = movie.title
        
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/"+movie.posterPath!) else { return cell }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.movieImage.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        let movieID = movieData[indexPath.row].id!
        movieDetailVC.movieID = movieID
        NetworkManager.shared.loadVideo(movieID: movieID) { result in
            let trailer = result.first(where: { $0.type == "Trailer" }) ?? result.first!
            movieDetailVC.trailerKey = trailer.key!
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(movieDetailVC, animated: true)
            }
        }
    }
}
