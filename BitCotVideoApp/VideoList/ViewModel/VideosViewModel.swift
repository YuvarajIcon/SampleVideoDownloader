//
//  VideosViewModel.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation

protocol VideoUpdateDelegate: AnyObject {
    func videoSaved(forURL: String)
    func videoDeleted(forURL: String)
    func thumbnailLoaded(forURL: String)
}

final class VideosViewModel {
    private let downloadManager: DownloadManager
    private let fileManager: VideoFileManager
    var videos: [Video]
    weak var delegate: VideoUpdateDelegate?

    init(fileManager: VideoFileManager, downloadManager: DownloadManager) {
        self.fileManager = fileManager
        self.downloadManager = downloadManager
        self.videos = Video.fetchAll()
        if self.videos.isEmpty {
            self.videos = self.generateVideos()
            CoreDataManager.shared.save()
        }
        self.downloadManager.delegates.add(delegate: self)
    }

    func downloadVideos() {
        for video in videos {
            guard video.localURL == nil else {
                continue
            }
            guard let url = URL(string: video.downloadURL) else {
                continue
            }
            downloadManager.downloadVideo(from: url)
        }
    }
    
    func loadThumbnails() {
        for video in videos {
            ImageUtil.generateThumbnail(from: video.downloadURL, completion: { [weak self] image, urlString in
                guard let self, let image else { return }
                guard let index = self.videos.firstIndex(where: { $0.downloadURL ==  urlString }) else {
                    return
                }
                self.videos[index].thumbnailURL = self.fileManager.saveThumbnail(image: image)
                CoreDataManager.shared.save()
                self.delegate?.thumbnailLoaded(forURL: urlString)
            })
        }
    }
    
    func downloadVideo(fromURL urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        downloadManager.downloadVideo(from: url)
    }
    
    func stopDownload(forURL urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        guard let index = videos.firstIndex(where: { $0.downloadURL ==  urlString }) else {
            return
        }
        videos[index].progress = 0
        downloadManager.stopDownload(for: url)
    }

    func deleteVideo(ofURL urlString: String, withLocalURL localString: String) {
        guard let localURL = URL(string: localString) else {
            return
        }
        self.fileManager.deleteFile(at: localURL) { [weak self] error in
            guard error == nil, let self = self else {
                print(error as Any)
                return
            }
            guard let index = videos.firstIndex(where: { $0.downloadURL ==  urlString }) else {
                return
            }
            self.videos[index].progress = 0
            self.videos[index].localURL = nil
            CoreDataManager.shared.save()
            delegate?.videoDeleted(forURL: urlString)
        }
    }
}

extension VideosViewModel: DownloadManagerDelegate {
    func downloadProgressChanged(for url: URL, progress: Float) {
        guard let index = videos.firstIndex(where: { $0.downloadURL == url.absoluteString }) else {
            return
        }
        videos[index].progress = NSNumber(value: progress)
    }
    
    func downloadCompleted(for url: URL, localURL: URL) {
        guard let index = videos.firstIndex(where: { $0.downloadURL == url.absoluteString }) else {
            return
        }
        let urlToSaveAt = fileManager.downloadDirectory().appendingPathComponent("\(videos[index].title).mp4")
        videos[index].progress = 1.0
        self.fileManager.moveDownloadedFile(from: localURL, to: urlToSaveAt) { [weak self] error in
            guard error == nil, let self = self else {
                print(error as Any)
                return
            }
            self.videos[index].localURL = urlToSaveAt.absoluteString
            CoreDataManager.shared.save()
            self.delegate?.videoSaved(forURL: url.absoluteString)
        }
    }
    
    func downloadFailed(for url: URL, reason: String) {
        
    }
}
