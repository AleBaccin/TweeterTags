//
//  TweetsTVC.swift
//  TweeterTags
//
//  Created by Alessandro Baccin on 18/03/2020.
//  Copyright © 2020 COMP47390-41550. All rights reserved.
//
import UIKit

class TweetsTVC : UITableViewController, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var twitterQueryTextField: UITextField!
    // MARK: - Private Properties
    private var tweets = [[TwitterTweet]]()
    private var lastSearch : TwitterRequest?
    var twitterQueryText : String? = "#ucd" {
        didSet {
            twitterQueryTextField?.text = twitterQueryText
            tweets.removeAll()
            tableView.reloadData()
            updateDefaults()
            refresh()
        }
    }
    private var searchesQueue : [String] {
        get {
            let defaults = UserDefaults.standard
            guard let queue = defaults.object(forKey: "recentSearches") as? [String] else {
                return []
            }
            return queue
        }
    }
    
    // MARK: - UserDefaults
    private func updateDefaults() {
        var temp = searchesQueue
        if temp.first?.lowercased() != twitterQueryText?.lowercased() && !temp.contains(twitterQueryText!) {
            if let query = twitterQueryText {
                temp.insert(query, at: 0)
            }
        }
        if temp.count > 100 {
            temp.removeLast()
        }
        let defaults = UserDefaults.standard
        defaults.set(temp, forKey: "recentSearches")
    }
    
    // MARK: - Segue Identifiers
    private struct Identifiers {
        static let showTweetDetailsSegue : String = "showTweetDetails"
    }
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        twitterQueryTextField.delegate = self
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        tweets.removeAll()
        tableView.reloadData()
        refresh()
    }
    
    // MARK: - Search
    private func refresh() {
        guard let query = twitterQueryText, !query.isEmpty else {
            return
        }
        
        print("The Query: \(query)")
        
        let request = TwitterRequest(search: query, count: 8)
        lastSearch = request
        request.fetchTweets { [weak self] (fetchedTweets) -> Void in
            
            DispatchQueue.main.async { () -> Void in
                if request == self?.lastSearch {
                    for tweet in fetchedTweets {
                        print(tweet.text)
                    }
                    self?.tweets.append(fetchedTweets)
                    self?.tableView.insertSections([0], with: .top)
                }
            }
        }
    }
    
    // MARK: - Delegate for UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let temp = textField.text {
            let textfieldQuery = temp.trimmingCharacters(in: .whitespacesAndNewlines)
            if textfieldQuery.first != "#"  {
                if textfieldQuery.count > 0 && textfieldQuery.isAlphanumeric() {
                    twitterQueryText = "#" + textfieldQuery
                }
                else if textfieldQuery.first == "@" {
                    if textfieldQuery.count > 0 && String(textfieldQuery.dropFirst()).isAlphanumeric() {
                        twitterQueryText = textfieldQuery
                    }
                }
            }
            else{
                if textfieldQuery.count > 0 && String(textfieldQuery.dropFirst()).isAlphanumeric() {
                    twitterQueryText = textfieldQuery
                }
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Overriding for UITableViewController
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTVCell
        let tweet = tweets[indexPath.section][indexPath.row]
        
        cell.tweet = tweet
        
        return cell
    }
    
    // MARK: - Segue Operations
    @IBAction func unwindFromMentionsTVC(_ unwindSegue: UIStoryboardSegue) {
        print("unwinding")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Identifiers.showTweetDetailsSegue:
            let destinationVC = segue.destination as! MentionsTVC
            let cell = sender as! TweetTVCell
            destinationVC.tweet = cell.tweet!
        default:
            break
        }
    }
}

// MARK: - String Extension from https://stackoverflow.com/questions/35992800/check-if-a-string-is-alphanumeric-in-swift
private extension String {
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }

    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }

}
