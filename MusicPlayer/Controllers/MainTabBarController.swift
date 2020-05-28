//
//  MainTabBarController.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 25.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import UIKit
import SwiftUI

class MainTabBarController: UITabBarController {
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDV: TrackDetailView = TrackDetailView.loadFromNib()
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        self.searchVC.trackDetailView = self.trackDV
        setupTrackDetailView()
        
        var library = Library()
        library.trackDetailView = self.trackDV
        let hostVC = UIHostingController(rootView: library)
        
        hostVC.tabBarItem.image = #imageLiteral(resourceName: "library")
        hostVC.tabBarItem.title = "Library"
        let navigationSearchVC = self.generateViewController(rootViewController: searchVC, image: #imageLiteral(resourceName: "search"), title: "Search")
        viewControllers = [
            hostVC,
            navigationSearchVC
          //  navigationLibraryVC
        ]
    }
    
    private func generateViewController(rootViewController controller: UIViewController,
                                        image: UIImage, title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: controller)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        controller.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
    private func setupTrackDetailView() {
        
        trackDV.transitionDelegate = self
        trackDV.switchDelegate = self.searchVC
        view.insertSubview(trackDV, belowSubview: tabBar)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        trackDV.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = trackDV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDV.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDV.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        bottomAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.isActive = true
        
        trackDV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        trackDV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
}


extension MainTabBarController: TrackDetailViewTransitionDelegate {
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?) {
        self.minimizedTopAnchorConstraint.isActive = false
        self.maximizedTopAnchorConstraint.isActive = true
        self.maximizedTopAnchorConstraint.constant = 0
        self.bottomAnchorConstraint.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.tabBar.alpha = 0
            self?.trackDV.miniTrackDetailView.alpha = 0
            self?.trackDV.maximizedStackView.alpha = 1
        })
        
        guard let viewModel = viewModel else { return }
        self.trackDV.set(viewModel: viewModel)
    }
    
    func minimizeTrackDetailController() {
        self.maximizedTopAnchorConstraint.isActive = false
        self.bottomAnchorConstraint.constant = view.frame.height
        self.minimizedTopAnchorConstraint.isActive = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.tabBar.alpha = 1
            self?.trackDV.miniTrackDetailView.alpha = 1
            self?.trackDV.maximizedStackView.alpha = 0
        })
    }
}
