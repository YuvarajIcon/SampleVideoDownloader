//
//  FileManager.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation
import UIKit

final class VideoFileManager {

    static let shared = VideoFileManager()
    private let fileManager = FileManager.default

    private init() {}

    func downloadDirectory() -> URL {
        let downloadDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("DownloadedVideos")
        if !fileManager.fileExists(atPath: downloadDirectory.path) {
            do {
                try fileManager.createDirectory(at: downloadDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Failed to create download directory: \(error)")
            }
        }
        return downloadDirectory
    }

    func moveDownloadedFile(from sourceURL: URL, to destinationURL: URL, completion: @escaping (Error?) -> Void) {
        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteFile(at url: URL, completion: @escaping (Error?) -> Void) {
        do {
            try fileManager.removeItem(at: url)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func fileExists(at url: URL) -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    func saveThumbnail(image: UIImage) -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(UUID().uuidString + ".png")
        do {
            if let data = image.pngData() {
                try data.write(to: fileURL)
                return fileURL.path
            }
        } catch {
            print("Error saving thumbnail locally: \(error)")
        }
        return nil
    }

}
