//
//  ImageUtil.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation
import AVFoundation
import UIKit

final class ImageUtil {
    static func generateThumbnail(from urlString: String, completion: @escaping (UIImage?, String) -> Void) {
        guard let videoURL = URL(string: urlString) else { return }
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let thumbnailTime = CMTime(seconds: 1, preferredTimescale: 60)
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: thumbnailTime)]) { _, cgImage, _, _, _ in
            if let cgImage = cgImage {
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail, urlString)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, urlString)
                }
            }
        }
    }
}
