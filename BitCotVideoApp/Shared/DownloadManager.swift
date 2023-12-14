//
//  DownloadManager.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation

protocol DownloadManagerDelegate: AnyObject {
    func downloadProgressChanged(for url: URL, progress: Float)
    func downloadCompleted(for url: URL, localURL: URL)
    func downloadFailed(for url: URL, reason: String)
}

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    
    static let shared = DownloadManager()
    private let backgroundID = "bitcot.background.identifier"
    private var downloadTasks = [URL: URLSessionDownloadTask]()
    var delegates = MulticastDelegate<DownloadManagerDelegate>()
    
    private lazy var backgroundSession: URLSession = {
       let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: backgroundID)
       return URLSession(
            configuration: backgroundConfiguration,
            delegate: self,
            delegateQueue: nil
       )
    }()
    
    private override init() { }

    func downloadVideo(from url: URL) {
        guard downloadTasks[url] == nil else {
            return
        }
        let downloadTask = backgroundSession.downloadTask(with: url)
        downloadTasks[url] = downloadTask
        downloadTask.resume()
    }
    
    func stopDownload(for url: URL) {
        guard let downloadTask = downloadTasks[url] else {
            return
        }
        downloadTask.cancel()
        downloadTasks[url] = nil
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadedFromURL = downloadTask.originalRequest?.url else {
            return
        }
        delegates.invoke(invocation: {
            $0.downloadCompleted(for: downloadedFromURL, localURL: location)
        })
        downloadTasks[downloadedFromURL] = nil
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let downloadedFromURL = downloadTask.originalRequest?.url else {
            return
        }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        delegates.invoke(invocation: {
            $0.downloadProgressChanged(for: downloadedFromURL, progress: progress)
        })
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

    }
}
