//
//  VideoCell.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation
import AVFoundation
import UIKit

protocol CellDelegate: AnyObject {
    func buttonTapped(at indexPath: IndexPath)
    func imageTapped(at indexPath: IndexPath)
}

enum CellButtonState {
    case download, stop, delete
}

class VideoCell: UITableViewCell {

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let playIconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "play.circle.fill")
        view.tintColor = .white
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .red
        progressView.isHidden = true
        return progressView
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .red
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: CellDelegate?
    var indexPath: IndexPath?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView.image = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(downloadButton)
        thumbnailImageView.addSubview(playIconView)

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 190),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 110),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        playIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playIconView.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 80),
            playIconView.heightAnchor.constraint(equalToConstant: 80)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            progressBar.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            downloadButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            downloadButton.heightAnchor.constraint(equalToConstant: 40),
            downloadButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            downloadButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    func configure(with video: Video, state: CellButtonState) {
        self.titleLabel.text = video.title
        switch state {
        case .download:
            self.progressBar.isHidden = true
            self.playIconView.isHidden = true
            self.downloadButton.setTitle("Download", for: .normal)
        case .stop:
            self.progressBar.isHidden = false
            self.playIconView.isHidden = true
            self.progressBar.progress = video.progress.floatValue
            self.downloadButton.setTitle("Stop", for: .normal)
        case .delete:
            self.progressBar.isHidden = true
            self.playIconView.isHidden = false
            self.downloadButton.setTitle("Delete", for: .normal)
        }
        self.thumbnailImageView.image = UIImage(contentsOfFile: video.thumbnailURL ?? "")
    }
    
    @objc
    private func didTap(_ sender: UIButton) {
        guard let indexPath else {
            return
        }
        delegate?.buttonTapped(at: indexPath)
    }
    
    @objc
    private func imageTapped(_ sender: UIImageView) {
        guard let indexPath else {
            return
        }
        delegate?.imageTapped(at: indexPath)
    }
}
