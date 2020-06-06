//
//  MentionsTVC.swift
//  TweeterTags
//
//  Created by Alessandro Baccin on 22/03/2020.
//  Copyright © 2020 COMP47390-41550. All rights reserved.
//

import UIKit

class MentionsTVC : UITableViewController {
    // MARK: - Private Properties
    var tweet : TwitterTweet? { didSet { tableView.reloadData() }}
    private var tweetMediaAndMentions : [Any] { get{
            return [tweet!.media, tweet!.hashtags, tweet!.userMentions, tweet!.urls]
        }}
    
    //Kinda like parallel arrays, I don't like it too much, but it's very handy
    private var tweetHeaders = ["Images", "Hashtags", "Users", "URLs"]
    
    private struct Identifiers {
        static let searchTweetFromMentionSegue = "unwindSearchTweetFromMention"
        static let showImageSegue = "showImageSegue"
    }
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = tweet?.user.name
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Overriding for UITableViewController
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweetHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tweetMediaAndMentions[section] as! [Any]).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = (tweetMediaAndMentions[indexPath.section] as! [Any])[indexPath.row]
        
        if !tweet!.media.isEmpty && indexPath.section < 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetMediaCell", for: indexPath) as! MediaTVCell
            cell.url = (item as? TwitterMedia)?.url
            return cell
        }
        else if indexPath.section > 0 && indexPath.section < 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetHashtagAndMentionCell", for: indexPath)
            cell.textLabel?.text = (item as? TwitterMention)?.keyword
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetUrlCell", for: indexPath)
            cell.textLabel?.text = (item as? TwitterMention)?.keyword
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(200)
       }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !(tweetMediaAndMentions[section] as! [Any]).isEmpty {
            return tweetHeaders[section]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if let url = URL(string: tweet!.urls[indexPath.row].keyword) {
                UIApplication.shared.open(url as URL)
            }
        }
    }
    
    // MARK: - Preparing for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Identifiers.searchTweetFromMentionSegue:
            let destinationVC = segue.destination as! TweetsTVC
            let cell = sender as! UITableViewCell
            destinationVC.twitterQueryText = cell.textLabel?.text
            break
        case Identifiers.showImageSegue:
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell), let image = tweet?.media[indexPath.row] {
                let destinationVC = segue.destination as! ImageVC
                destinationVC.imageURL = image.url
                destinationVC.title = tweet!.user.name
            }
            break
        default:
            break
        }
    }
}

// MARK: - Declaring MedaTVCell
// Doing it here for simplicity and comodity
class MediaTVCell : UITableViewCell {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var mediaView: UIImageView!
    
    var url : URL? { didSet { updateUI() }}
    
    private func updateUI() {
        if let mediaurl = url {
            spinner?.startAnimating()
            DispatchQueue.global(qos: .background).async  {
                Thread.sleep(forTimeInterval: 2)
                if let data = try? Data(contentsOf: mediaurl) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        if image != nil  {
                            self.mediaView?.image = image

                        } else {
                            self.mediaView?.image = nil
                        }
                        self.spinner?.stopAnimating()
                    }
                }
            }
        }
        else {
            self.mediaView?.image = nil
        }
    }
}
