//
//  MainViewController.swift
//  PlayingVideos
//
//  Created by colorsLion2 on 28/01/19.
//  Copyright © 2019 colorsLion2. All rights reserved.
//

import UIKit
import SDWebImage

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var videosTableView: UITableView!
    
    var videos:[Article]?
    var placeHolderImage : UIImage = UIImage(named: "imagePlaceholder.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"
        self.videosTableView.delegate = self
        self.videosTableView.dataSource = self
        videosTableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        
        let urlString = "https://interview-e18de.firebaseio.com/media.json?print=pretty"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            do {
                self.videos = try JSONDecoder().decode([Article].self, from: data)
                DispatchQueue.main.async {
                    self.videosTableView.reloadData()
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if videos != nil{
        return videos!.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VideoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VideoTableViewCell
        if videos != nil{
        let video = videos![indexPath.row]
        cell?.videoImageView.sd_setImage(with: URL(string: video.thumb), placeholderImage: self.placeHolderImage)
        cell?.videoTitleLabel.text = video.title
        cell?.videoDescriptionLabel.text = video.description
        return cell!
        }else{
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos![indexPath.row]
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        detailVC.videoId = video.id
        detailVC.videos = self.videos
        self.navigationController?.pushViewController(detailVC, animated: true)
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
