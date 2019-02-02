//
//  DetailViewController.swift
//  PlayingVideos
//
//  Created by colorsLion2 on 29/01/19.
//  Copyright © 2019 colorsLion2. All rights reserved.
//

import UIKit
import AVKit
import CoreData

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,AVPlayerViewControllerDelegate {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var relatedVideosTableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    
    var videoId = String()
    var videos:[Article]?
    var relatedVideos:[Article]?
    var placeHolderImage : UIImage = UIImage(named: "imagePlaceholder.png")!
    
    private let player = AVQueuePlayer()
    private var token: NSKeyValueObservation?
    var videoUrls = [String]()
    var avPlayerView = AVPlayerViewController()
    var currentDuration : Int!
    var pausedDuration : Int!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var coredataVideos = [VideosInfo]()
    var duration = Int()
    var currentUrl = String()
    var currentVideoObject:Article?
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail"
        
        relatedVideosTableView.delegate = self
        relatedVideosTableView.dataSource = self
        
        relatedVideosTableView.register(UINib(nibName: "RelatedVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "RelatedVideoCell")
        
        print("videoId",videoId)
        for video in videos!{
            if video.id == videoId{
               currentVideoObject = video
                break
            }
        }
        relatedVideos = videos?.filter({ (video) -> Bool in
            return video.id != videoId
        })
        videoImageView.sd_setImage(with: URL(string: currentVideoObject!.thumb), placeholderImage: self.placeHolderImage)
        titleLabel.text = currentVideoObject?.title
        descriptionLabel.text = currentVideoObject?.description
        currentUrl = (currentVideoObject?.url)!
        self.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         fetchRecords()
    }
    func fetchRecords(){
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription1 = NSEntityDescription.entity(forEntityName: "VideosInfo", in: appDelegate.managedObjectContext)
        fetchRequest1.entity = entityDescription1
        do{
            coredataVideos = try appDelegate.managedObjectContext.fetch(fetchRequest1) as! [VideosInfo]
            for coredataVideo in coredataVideos {
                if coredataVideo.url == currentVideoObject?.url{
                    duration = Int(coredataVideo.pausedDuration)
                    print("duration",duration)
                    break
                }
            }
        }
        catch{
        }
    }
    override func viewDidLayoutSubviews() {
        tableViewHeightConstraint.constant = relatedVideosTableView.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relatedVideos!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RelatedVideoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RelatedVideoTableViewCell
        if relatedVideos != nil{
            let video = relatedVideos![indexPath.row]
            cell?.relatedVideoImage.sd_setImage(with: URL(string: video.thumb), placeholderImage: self.placeHolderImage)
            cell?.titleLAbel.text = video.title
            cell?.descriptionLabel.text = video.description
            return cell!
        }else{
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    @IBAction func playAction(_ sender: Any) {
        videoUrls.removeAll()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let index = Int(videoId)! - 1
        var j : Int! = index
        for _ in videos!{
            if j <= videos!.count - 1{
            }else{
                j = 0
            }
            videoUrls.append(videos![j!].url)
            j += 1
        }
        self.addAllVideosToPlayer()
        present(avPlayerView, animated: true, completion: {
            let seconds = Float64(self.duration)
            let targetTime: CMTime = CMTimeMakeWithSeconds(seconds, preferredTimescale: Int32(Double(NSEC_PER_SEC)))
            self.player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            self.player.play()
        })
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        saveVideoInfoInCoredata(duration: 0)
        count += 1
        currentUrl = videoUrls[count]
        for video in videos!{
            if video.url == currentUrl{
                currentVideoObject = video
                break
            }
        }
    }
      func addAllVideosToPlayer() {
        avPlayerView.player = player
        for videoUrl in videoUrls {
            let url = URL(string: videoUrl)!
            let playerItem = AVPlayerItem(url: url)
            player.insert(playerItem, after: player.items().last)
            token = player.observe(\.currentItem) { [weak self] player, _ in
                if self!.player.items().count == 1 { self?.addAllVideosToPlayer() }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "rate") {
            if player.rate > 0 {
                print("video started")
            }
            else{
                print("paused")
                self.currentDuration = Int(CMTimeGetSeconds(self.player.currentTime()))
                self.pausedDuration = self.currentDuration
                print("pausedDuration",self.pausedDuration)
                self.saveVideoInfoInCoredata(duration: self.pausedDuration)
            }
        }
    }
    deinit {
        self.player.removeObserver(self, forKeyPath: "rate")
    }
    
    func saveVideoInfoInCoredata(duration:Int){
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription1 = NSEntityDescription.entity(forEntityName: "VideosInfo", in: appDelegate.managedObjectContext)
        fetchRequest1.entity = entityDescription1
        do{
            coredataVideos = try appDelegate.managedObjectContext.fetch(fetchRequest1) as! [VideosInfo]
            var isExists = false
            if coredataVideos.count > 0{
                for coredataVideo in coredataVideos {
                    if coredataVideo.url == currentUrl{
                        isExists = true
                        coredataVideo.setValue(currentVideoObject?.id, forKey: "id")
                        coredataVideo.setValue(currentVideoObject?.thumb, forKey: "thumb")
                        coredataVideo.setValue(currentVideoObject?.url, forKey: "url")
                        coredataVideo.setValue(duration, forKey: "pausedDuration")
                        do {
                            try appDelegate.managedObjectContext.save()
                            print("saved",appDelegate.managedObjectContext)
                        } catch {
                            print("Could not save")
                        }
                        return
                    }
                    else{
                        isExists = false
                    }
                }
                if isExists == false{
                    let managedContext = appDelegate.managedObjectContext
                    let entity = NSEntityDescription.entity(forEntityName: "VideosInfo",in: managedContext)
                    let record = NSManagedObject(entity: entity!,insertInto:managedContext)
                    record.setValue(currentVideoObject?.id, forKey: "id")
                    record.setValue(currentVideoObject?.thumb, forKey: "thumb")
                    record.setValue(currentVideoObject?.url, forKey: "url")
                    record.setValue(duration, forKey: "pausedDuration")
                    coredataVideos.append(record as! VideosInfo)
                    do {
                        try appDelegate.managedObjectContext.save()
                        print("saved",appDelegate.managedObjectContext)
                    } catch {
                        print("Could not save")
                    }
                }
                else{
                    return
                }
            }
            else{
                let managedContext = appDelegate.managedObjectContext
                let entity = NSEntityDescription.entity(forEntityName: "VideosInfo",in: managedContext)
                let record = NSManagedObject(entity: entity!,insertInto:managedContext)
                record.setValue(currentVideoObject?.id, forKey: "id")
                record.setValue(currentVideoObject?.thumb, forKey: "thumb")
                record.setValue(currentVideoObject?.url, forKey: "url")
                record.setValue(duration, forKey: "pausedDuration")
                coredataVideos.append(record as! VideosInfo)
                do {
                    try appDelegate.managedObjectContext.save()
                    print("saved",appDelegate.managedObjectContext)
                } catch {
                    print("Could not save")
                }
            }
        }
        catch{
        }
    }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
