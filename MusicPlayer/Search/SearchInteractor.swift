//
//  SearchInteractor.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 25.05.2020.
//  Copyright (c) 2020 Vlad Tkachuk. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var apiManager = ITunesAPIManager()
    
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        switch request {
        case .getTracks(let searchTerm):
            presenter?.presentData(response: .presentFooterView)
            apiManager.fetchMusic(searchText: searchTerm) {[weak self] (result) in
                DispatchQueue.main.async {
                    
                
                    switch result {
                    case .success(let searchResponce):
                        self?.presenter?.presentData(response: .presentTracks(searchResponce: searchResponce))
                    case .failure(_):
                        print("error")
                    }
                }
            }
            
        case .removeTracks:
            self.presenter?.presentData(response: .presentEmptyResponse)
        }
    }
    
}
