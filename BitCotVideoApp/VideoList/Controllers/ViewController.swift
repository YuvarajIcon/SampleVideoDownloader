//
//  ViewController.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    // MARK: Outlets
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(VideoCell.self, forCellReuseIdentifier: "videoCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let viewModel = VideosViewModel(fileManager: VideoFileManager.shared, downloadManager: DownloadManager.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        viewModel.loadThumbnails()
        DownloadManager.shared.delegates.add(delegate: self)
        tableView.reloadData()
    }
    
    private func setupUI() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    private func reload(forURL url: String, animate: Bool = false) {
        guard let index = viewModel.videos.firstIndex(where: { $0.downloadURL == url }) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            tableView.reloadRows(at: [indexPath], with: animate ? .automatic : .none)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoCell
        let video = viewModel.videos[indexPath.row]
        cell.delegate = self
        let state: CellButtonState = if video.isAvailableOffline == true {
            .delete
        } else if video.progress == 0 {
            .download
        } else {
            .stop
        }
        cell.configure(with: viewModel.videos[indexPath.row], state: state)
        cell.indexPath = indexPath
        return cell
    }
}

extension ViewController: CellDelegate {
    func buttonTapped(at indexPath: IndexPath) {
        let video = viewModel.videos[indexPath.row]
        if video.isAvailableOffline {
            self.deleteVideo(at: indexPath)
        } else if video.progress == 0 {
            self.downloadVideo(at: indexPath)
        } else {
            self.stopVideo(at: indexPath)
        }
        tableView.reloadData()
    }
    
    func imageTapped(at indexPath: IndexPath) {
        guard let rawString = viewModel.videos[indexPath.row].localURL,
            let localURL = URL(string: rawString) else {
            return
        }
        let player = AVPlayer(url: localURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        self.present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    private func deleteVideo(at indexPath: IndexPath) {
        let video = viewModel.videos[indexPath.row]
        let url = video.downloadURL
        guard let localURL = video.localURL else {
            return
        }
        viewModel.deleteVideo(ofURL: url, withLocalURL: localURL)
    }
    
    private func downloadVideo(at indexPath: IndexPath) {
        let url = viewModel.videos[indexPath.row].downloadURL
        viewModel.downloadVideo(fromURL: url)
    }
    
    private func stopVideo(at indexPath: IndexPath) {
        let url = viewModel.videos[indexPath.row].downloadURL
        viewModel.stopDownload(forURL: url)
        CoreDataManager.shared.save()
        tableView.reloadData()
    }
}

extension ViewController: DownloadManagerDelegate {
    func downloadProgressChanged(for url: URL, progress: Float) {
        self.reload(forURL: url.absoluteString)
    }
    
    func downloadCompleted(for url: URL, localURL: URL) { }
    
    func downloadFailed(for url: URL, reason: String) { }
}

extension ViewController: VideoUpdateDelegate {
    func videoSaved(forURL url: String) {
        self.reload(forURL: url, animate: true)
    }
    
    func videoDeleted(forURL url: String) {
        self.reload(forURL: url, animate: true)
    }
    
    func thumbnailLoaded(forURL url: String) {
        self.reload(forURL: url)
    }
}

