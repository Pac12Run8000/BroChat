//
//  ImageService.swift
//  BroChat
//
//  Created by Michelle Grover on 4/1/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class ImageService {
    
    static let cache = NSCache<NSString, UIImage>()
    
    static func downloadAndCacheImage(withUrl:URL, completionHandler:@escaping(_ success:Bool?, _ image:UIImage?, _ error:Error?) -> ()) {
        
        let dataTask = URLSession.shared.dataTask(with: withUrl) { (data, response, error) in
            
            var downloadedImage:UIImage?
            
            guard let data = data else {
                print("Data is not available.")
                completionHandler(false, nil, nil)
                return
            }
            
            downloadedImage = UIImage(data: data)
            
            if (downloadedImage == nil) {
                cache.setObject(downloadedImage!, forKey: withUrl.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completionHandler(true, downloadedImage, nil)
            }
            
        }
        dataTask.resume()
        
    }
    
//    static func downloadImage(withUrl:URL, completionHandler:@escaping(_ success:Bool?, _ image:UIImage?, _ error:Error?) ->()) {
//        let dataTask = URLSession.shared.dataTask(with: withUrl) { (data, response, err) in
//            var downloadedImage:UIImage?
//
//            guard let data = data else {
//                print("No data ...")
//                completionHandler(false, nil, nil)
//                return
//            }
//            downloadedImage = UIImage(data: data)
//
//            if (downloadedImage != nil) {
//                cache.setObject(downloadedImage!, forKey: withUrl.absoluteString as NSString)
//            }
//
//            DispatchQueue.main.async {
//                completionHandler(true, downloadedImage, nil)
//            }
//
//        }
//        dataTask.resume()
//
//    }
}
