//
//  MediaPlayerViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/8/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation
import Alamofire
import RxCocoa

class MediaPlayerViewController : UIViewController {
    
    deinit {
        downloadTask?.cancel()
    }
    
    fileprivate var downloadTask: Alamofire.DownloadRequest? = nil
    
    var mediaItem: MediaItem? = nil
    let imageURL: Variable<NSURL?> = Variable(nil)
    let image: Variable<UIImage?> = Variable(nil)
    let playableContentURL: Variable<NSURL?> = Variable(nil)
    
    fileprivate var player: AVPlayer = AVPlayer()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playbackIcon: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var blurredView: UIVisualEffectView!
    @IBOutlet weak var lockImageView: UIImageView!
    
    fileprivate let bag = DisposeBag()
    
    @IBAction func invertPlaybackRate(_ sender: AnyObject) {
        player.rate == 0 ? play() : pause()
    }
    
    fileprivate func play() {
        player.play()
        playbackIcon.isHidden = true
    }
    
    fileprivate func pause() {
        player.pause()
        playbackIcon.isHidden = false
    }
    
    fileprivate var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.view.layer.insertSublayer(playerLayer!, at: 0)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
            .subscribe(onNext: { [weak p = player] _ in
                p?.pause()
                p?.seek(to: kCMTimeZero)
                p?.play()
            })
            
            .disposed(by: bag)
        
        Driver.just(mediaItem)
            .filter { $0 != nil }.map { $0! }
            .filter { [unowned self] media in
                if media.type == .photo {
                    self.imageURL.value = NSURL(string: media.mediaURL)!
                    return false
                }
                
                return media.type == .video
            }
            .drive(onNext: { [unowned self] media in
                
                var url :URL? = nil
                
                self.activityIndicator?.isHidden = false
                
                self.downloadTask =
                    Alamofire.download(media.mediaURL,
                                       method: .get,
                                       parameters: nil,
                                       encoding: URLEncoding.default,
                                       headers: nil,
                                       to: { (temporaryURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                                        
                                        var tuple = Alamofire.DownloadRequest.suggestedDownloadDestination()(temporaryURL , response)
                                        
                                        tuple.options = [.removePreviousFile]
                                        url = tuple.destinationURL
                                        
                                        return tuple
                    })
                
                self.downloadTask?
                    .response { [weak self] (_) in
                        self?.activityIndicator?.isHidden = true
                        
                        self?.playableContentURL.value = url as NSURL?
                }
            })
            .disposed(by: bag)
        
        imageURL.asObservable()
            .flatMap { maybeUrl -> Observable<UIImage?> in
                guard let url = maybeUrl else { return Observable.just(nil) }
                
                return ImageRetreiver.imageForURLWithoutProgress(url.absoluteString!).asObservable()
            }
            .bind(to: image)
            
            .disposed(by: bag)
        
        image.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(imageView.rx.image)
            
            .disposed(by: bag)
        
        playableContentURL.asObservable()
            .map { ($0 == nil, $0 != nil ? AVPlayerItem(url: $0! as URL) : nil) }
            .subscribe(onNext: { [unowned self] (value: (Bool, AVPlayerItem?) ) in
                self.playbackIcon.isHidden = value.0
                self.player.replaceCurrentItem(with: value.1)
                }
            )
            .disposed(by: bag)
        
        let isLocked = mediaItem?.observableEntity()?.asDriver().map({ !$0.isLocked }) ?? Driver.just(true)
        
        isLocked.drive(blurredView.rx.isHidden).disposed(by: bag)
        isLocked.drive(lockImageView.rx.isHidden).disposed(by: bag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = self.view.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        pause()
    }
    
}
