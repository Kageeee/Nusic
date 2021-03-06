//
//  LikedSongListViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class SongListTabBarViewController: UITabBarController {

    //Tab Bar variables
    var navbar: UINavigationBar = UINavigationBar()
    
    //Data Variables
    var showSongVC: ShowSongViewController?
    var moodObject: NusicMood?
    var isMoodSelected: Bool = false
    
    //Table View
    var sectionTitles: [String?] = Array()
    var sectionSongs: [[NusicTrack]] = Array(Array())
    var likedTrackList:[NusicTrack] = Array() {
        didSet {
            if let likedSongListVC = likedSongListVC {
                likedSongListVC.likedTrackList = likedTrackList
            }
        }
    }
    var suggestedTrackList:[NusicTrack] = Array() {
        didSet {
            self.suggestedTrackList.sort(by: { (track1, track2) -> Bool in
                return (track1.suggestionInfo?.suggestionDate)! > (track2.suggestionInfo?.suggestionDate)!
            })
            if let suggestedSongListVC = suggestedSongListVC {
                suggestedSongListVC.suggestedSongList = suggestedTrackList
            }
        }
    }
    
    //Child View Controllers
    private var likedSongListVC: LikedSongListViewController?
    private var suggestedSongListVC: SuggestedSongListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTabBarController()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupChildViewControllers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar(image: UIImage? = UIImage(named: "PreferredPlayer")) {
        navbar = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
        navbar.translatesAutoresizingMaskIntoConstraints = false
        
        let leftBarButton = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(moveToShowSongVC));
        self.navigationItem.leftBarButtonItem = leftBarButton        
        let navItem = self.navigationItem
        
        navbar.items = [navItem]
        
        if !self.view.subviews.contains(navbar) {
            self.view.addSubview(navbar)
        }
        NSLayoutConstraint.activate([
            navbar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            navbar.heightAnchor.constraint(equalToConstant: 44),
            navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            ])
        
        self.view.layoutIfNeeded()
        
    }
    
    private func setupTabBarController() {
        guard let parent = self.parent as? NusicPageViewController, let showSongVC = parent.showSongVC as? ShowSongViewController else { return }
        self.showSongVC = showSongVC
        self.delegate = self
        self.view.backgroundColor = .clear
        self.tabBar.tintColor = NusicDefaults.foregroundThemeColor
        self.tabBar.barTintColor = NusicDefaults.blackColor
        setupChildViewControllers()
        
    }
    
    private func setupChildViewControllers() {
        guard let viewControllers = self.viewControllers else { return }
        for viewController in viewControllers {
            setupViewController(viewController: viewController)
        }
    }
    
    private func setupViewController(viewController: UIViewController) {
        switch viewController.className {
        case LikedSongListViewController.className:
            self.likedSongListVC = viewController as? LikedSongListViewController
            setupLikedSongListVC()
        case SuggestedSongListViewController.className:
            self.suggestedSongListVC = viewController as? SuggestedSongListViewController
            setupSuggestedSongListVC()
        default:
            print()
        }
    }
    
    private func setupLikedSongListVC() {
        self.likedSongListVC?.isMoodSelected = isMoodSelected
        self.likedSongListVC?.likedTrackList = likedTrackList
        self.likedSongListVC?.moodObject = moodObject
    }
    
    private func setupSuggestedSongListVC() {
        self.suggestedSongListVC?.suggestedSongList = suggestedTrackList
        self.suggestedSongListVC?.updateBadgeCount()
    }
    
    @objc private func moveToShowSongVC() {
        (parent as! NusicPageViewController).scrollToPreviousViewController();
    }

    final func playSelectedCard(track: NusicTrack) {
        
        guard let parent = parent as? NusicPageViewController else { return }
        parent.scrollToPreviousViewController()
        showSongVC?.playSelectedCard(track: track);
    }
    
    final func removeTrackFromLikedTracks(track: NusicTrack, indexPath: IndexPath) {
        
        showSongVC?.removeTrackFromLikedTracks(track: track, indexPath: indexPath, removeTrackHandler: { (isRemoved) in
            track.deleteData(deleteCompleteHandler: { (ref, error) in
                guard let index = self.likedTrackList.index(where: { (likedTrack) -> Bool in
                    return likedTrack.trackInfo == track.trackInfo
                }) else {
                    error?.presentPopup(for: self)
                    return;
                }
                self.likedTrackList.remove(at: index)
                DispatchQueue.main.async {
                    self.likedSongListVC?.sortTableView(by: (self.likedSongListVC?.songListTableViewHeader.currentSortElement)!)
                    self.likedSongListVC?.songListTableView.reloadData()
                }
            })
            
        })
    }
}

extension SongListTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let viewController = viewController as? SuggestedSongListViewController else { return }
        viewController.tabBarItem.badgeValue = String(viewController.suggestedSongList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count)
    }
    
}
