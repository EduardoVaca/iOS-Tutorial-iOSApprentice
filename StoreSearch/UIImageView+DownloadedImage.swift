//
//  UIImageView+DownloadedImage.swift
//  StoreSearch
//
//  Created by Eduardo Vaca on 12/12/16.
//  Copyright © 2016 Vaca. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { [weak self] (url, response, error) in
            if error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
             
                DispatchQueue.main.async {
                    // The ImageView may not exists when the request returns
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                }
            }
        }
        downloadTask.resume()
        // Return the task so you can cancel it
        return downloadTask
    }
}
