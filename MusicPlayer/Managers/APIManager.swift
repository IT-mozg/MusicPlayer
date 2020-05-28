//
//  APIManager.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 25.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import Foundation
import Alamofire

let apiURL: String = "https://itunes.apple.com/search"

enum Result<T: Decodable> {
    case success(T)
    case failure(Error)
}

enum APIError: Error {
    case noData
}

protocol APIManager {
    func get<T: Decodable>(withURL url: String, type: T.Type, parameters: [String: String]?, _ completion: @escaping (Result<T>)->Void)
}

extension APIManager {
    func get<T: Decodable>(withURL url: String, type: T.Type, parameters: [String: String]?, _ completion: @escaping (Result<T>)->Void) {
        AF.request(url, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder(), headers: nil).responseData { (dataResponse) in
            if let error = dataResponse.error {
                print("Error received requesting dataL \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = dataResponse.data else { return completion(.failure(APIError.noData)) }

            let decoder = JSONDecoder()
            do {
                let objects = try decoder.decode(type.self, from: data)
                completion(.success(objects))

            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }
    }
}

struct ITunesAPIManager: APIManager {
    
    func fetchMusic(searchText: String,  _ completion: @escaping (Result<SearchResponce>)->Void) {
        let parameters = ["term": "\(searchText)", "media": "music"]
        self.get(withURL: apiURL, type: SearchResponce.self, parameters: parameters, { completion($0) })
    }
   
}
