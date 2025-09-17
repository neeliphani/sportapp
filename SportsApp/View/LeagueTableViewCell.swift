//
//  LeagueTableViewCell.swift
//  SportsApp
//
//  Created by Alaa on 19/05/2023.
//

import UIKit
import Foundation
import ObjectiveC

class LeagueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leagueName: UILabel!
    @IBOutlet weak var leagueImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.leagueImage.contentMode = .scaleAspectFill
        
        self.leagueImage.layer.cornerRadius =   self.leagueImage.frame.size.height / 2
        self.leagueImage.layer.masksToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

private let remoteImageCache = NSCache<NSString, UIImage>()
private var remoteImageURLKey: UInt8 = 0
private var remoteImageTaskKey: UInt8 = 0

extension UIImageView {

    private var remoteImageURL: String? {
        get { objc_getAssociatedObject(self, &remoteImageURLKey) as? String }
        set { objc_setAssociatedObject(self, &remoteImageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var remoteImageTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, &remoteImageTaskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &remoteImageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setRemoteImage(from urlString: String?, placeholder: UIImage? = nil) {
        remoteImageTask?.cancel()
        remoteImageTask = nil

        let trimmedURLString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines)
        remoteImageURL = trimmedURLString

        updateImageOnMainThread(placeholder)

        guard let urlString = trimmedURLString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else { return }

        if let cachedImage = remoteImageCache.object(forKey: urlString as NSString) {
            updateImageOnMainThread(cachedImage, expectedURL: urlString)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            defer { self.remoteImageTask = nil }

            guard error == nil,
                  let data = data,
                  let downloadedImage = UIImage(data: data) else { return }

            remoteImageCache.setObject(downloadedImage, forKey: urlString as NSString)
            self.updateImageOnMainThread(downloadedImage, expectedURL: urlString)
        }

        remoteImageTask = task
        task.resume()
    }

    private func updateImageOnMainThread(_ image: UIImage?, expectedURL: String? = nil) {
        let applyImage = { [weak self] in
            guard let self = self else { return }
            if let expectedURL = expectedURL, self.remoteImageURL != expectedURL {
                return
            }
            self.image = image
        }

        if Thread.isMainThread {
            applyImage()
        } else {
            DispatchQueue.main.async(execute: applyImage)
        }
    }
}
