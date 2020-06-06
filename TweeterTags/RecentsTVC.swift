//
//  RecentsTVC.swift
//  TweeterTags
//
//  Created by Alessandro Baccin on 21/03/2020.
//  Copyright © 2020 COMP47390-41550. All rights reserved.
//

import UIKit

class RecentsTVC : UITableViewController {
    // MARK: - Private Properties
    private var recentSearches : [String]? {
        get {
            return UserDefaults.standard.object(forKey: "recentSearches") as? [String]
        }
    }
    
    private struct Identifiers {
        static let searchRecentQuerySegue = "searchRecentQuerySegue"
    }
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recents"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Overriding for UITableViewController
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recent = recentSearches else {
            return 0
        }
        return recent.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath)
        cell.textLabel?.text = recentSearches![indexPath.row]
        return cell
    }
    
    // MARK: - Preparing for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Identifiers.searchRecentQuerySegue:
            let destinationVC = segue.destination as! TweetsTVC
            let cell = sender as! UITableViewCell
            destinationVC.twitterQueryText = cell.textLabel?.text
        default:
            break
        }
    }
}
