//
//  TweetTableViewCell.swift
//  TweeterTags
//
//  Created by Alessandro Baccin on 20/03/2020.
//  Copyright © 2020 COMP47390-41550. All rights reserved.
//

import UIKit

class TweetTVCell : UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var profileIconView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    @IBOutlet weak var profileHandle: UILabel!
    var tweet : TwitterTweet? { didSet { updateUI() }}
    
    // MARK: - UpdatingUI
    private func updateUI() {
        var attributedTweetContent = NSMutableAttributedString(string: tweet!.text)
        attributedTweetContent = colorTwitterMentions(text: attributedTweetContent, mentions: tweet!.hashtags, color: UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1))
        attributedTweetContent = colorTwitterMentions(text: attributedTweetContent, mentions: tweet!.urls, color: UIColor(red: 160/255, green: 99/255, blue: 151/255, alpha: 1))
        attributedTweetContent = colorTwitterMentions(text: attributedTweetContent, mentions: tweet!.userMentions, color: UIColor(red: 43/255, green: 172/255, blue: 174/255, alpha: 1))
        tweetContentLabel?.attributedText = attributedTweetContent
        
        profileHandle?.text = "@\(tweet!.user.screenName)"
        profileNameLabel?.text =  tweet!.user.name
        if let created = tweet?.created {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let time = formatter.string(from: created)
            timestampLabel?.text = time.replacingOccurrences(of: ",", with: " at")
        }
        
        if let url = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .background).async  {
                print("Downloading Image")
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        if image != nil  {
                            self.profileIconView?.image = image
                            self.profileIconView?.roundCornersSmall()
                        } else {
                            self.profileIconView?.image = nil
                        }
                    }
                }
            }
        }
        else {
            self.profileIconView?.image = nil
        }
    }

    // MARK: - Coloring Text
    private func colorTwitterMentions(text: NSMutableAttributedString, mentions: [TwitterMention], color: UIColor) -> NSMutableAttributedString {
        for mention in mentions {
            text.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: mention.nsrange)
        }
        
        return text
    }

}

// MARK: - UIImageViewExtension for rounded corners
private extension UIImageView {
    func roundCornersSmall() {
        self.layer.cornerRadius = 3.0
        layer.masksToBounds = true
    }
}
