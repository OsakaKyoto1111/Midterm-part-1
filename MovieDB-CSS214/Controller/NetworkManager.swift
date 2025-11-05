//
//  NetworkManager.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 20.10.2025.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private lazy var urlComponent: URLComponents = {
        var urlComponent = URLComponents()
        urlComponent.host = "api.themoviedb.org"
        urlComponent.scheme = "https"
        urlComponent.queryItems = [
                URLQueryItem(name: "api_key", value: "201c3209762c5d4a8baf2a743dd97ddc")
        ]
        return urlComponent
    }()
    
    private let urlImage: String = "https://image.tmdb.org/t/p/w500/"
    
    func loadMovie(completion: @escaping ([Result]) -> Void) {
        urlComponent.path = "/3/movie/now_playing"
        guard let url = urlComponent.url else { return }
        print(url)
        let session = URLSession(configuration: .ephemeral)
        DispatchQueue.global().async {
            let task = session.dataTask(with: url) {data,response,error in
                guard let data = data else { return }

                if let movie = try? JSONDecoder().decode(Movie.self, from: data) {
                    DispatchQueue.main.async {
                        completion(movie.results!)
                    }
                }
            }
            
            task.resume()
        }
    }
    func searchMovies(query: String, page: Int = 1, completion: @escaping (SearchResponse?) -> Void) {
        var urlComponent = self.urlComponent
        urlComponent.path = "/3/search/movie"
        
        var items = urlComponent.queryItems ?? []
        items.append(URLQueryItem(name: "query", value: query))
        items.append(URLQueryItem(name: "page", value: "\(page)"))
        urlComponent.queryItems = items
        
        guard let url = urlComponent.url else { return }
        
        let session = URLSession(configuration: .ephemeral)
        DispatchQueue.global().async {
            session.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                do {
                    let search = try JSONDecoder().decode(SearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(search)
                    }
                } catch {
                    print("❌ JSON decode error:", error)
                    completion(nil)
                }
            }.resume()
        }
    }
    func loadMoviesByGenre(genreID: Int, page: Int = 1, completion: @escaping (SearchResponse?) -> Void) {
        var urlComponent = self.urlComponent
        urlComponent.path = "/3/discover/movie"
        
        var items = urlComponent.queryItems ?? []
        items.append(URLQueryItem(name: "with_genres", value: "\(genreID)"))
        items.append(URLQueryItem(name: "page", value: "\(page)"))
        urlComponent.queryItems = items
        
        guard let url = urlComponent.url else { return }
        
        let session = URLSession(configuration: .ephemeral)
        DispatchQueue.global().async {
            session.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    completion(nil)
                    return
                }
                do {
                    let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(response)
                    }
                } catch {
                    print("Error loading movies by genre:", error)
                    completion(nil)
                }
            }.resume()
        }
    }
    
    func loadMovieDetail(movieID: Int, completion: @escaping (MovieDetail) -> Void) {
        urlComponent.path = "/3/movie/\(movieID)"
        guard let url = urlComponent.url else { return }
        let session = URLSession(configuration: .ephemeral)
        DispatchQueue.global().async {
            session.dataTask(with: url) { data, response, error in
                guard let data else { return }
                guard let movie = try? JSONDecoder().decode(MovieDetail.self, from: data) else { return }
                DispatchQueue.main.async {
                    completion(movie)
                }
            }.resume()
        }
    }
    
    func loadImage(posterPath: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: urlImage + posterPath) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(data)
                }
            }
        }
    }
    
    func loadCasts(movieID: Int, completion: @escaping ([Cast]) -> Void) {
        urlComponent.path = "/3/movie/\(movieID)/casts"
        guard let url = urlComponent.url else { return }
        let session = URLSession(configuration: .ephemeral)
        DispatchQueue.global().async {
            session.dataTask(with: url) { data, response, error in
                guard let data else { return }
                guard let casts = try? JSONDecoder().decode(Casts.self, from: data) else { return }
                DispatchQueue.main.async {
                    completion(casts.cast)
                }
            }.resume()
        }
    }
    
    func loadVideo(movieID: Int, completion: @escaping ([ResultV]) -> Void) {
        urlComponent.path = "/3/movie/\(movieID)/videos"
        guard let url = urlComponent.url else { return }
        let session = URLSession(configuration: .ephemeral)
        DispatchQueue.global().async {
            session.dataTask(with: url) { data, response, error in
                guard let data else { return }
                guard let videos = try? JSONDecoder().decode(Video.self, from: data) else { return }
                DispatchQueue.main.async {
                    completion(videos.results)
                }
            }.resume()
        }
    }
}
