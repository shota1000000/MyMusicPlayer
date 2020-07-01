//
//  SelectViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/05/23.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation
import PKHUD
import ViewAnimator

class SelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var artistName = ""
    var musicName = ""
    var previewURL = ""
    var imageString = ""
    
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    
    
    var player:AVAudioPlayer?
    
    let ref = Database.database().reference()
    
    @IBOutlet weak var selectTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectTableView.delegate = self
        selectTableView.dataSource = self
        
    }
    
    
    func moveToSelect(){
        
        performSegue(withIdentifier: "playVC", sender: nil)
        
    }
    
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "playVC"{
            
            //インスタンス化
            let playVC = segue.destination as! PlayViewController
            playVC.artistNameArray = self.artistNameArray
            playVC.imageStringArray = self.imageStringArray
            playVC.musicNameArray = self.musicNameArray
            playVC.previewURLArray = self.previewURLArray
            
            playVC.artistName = self.artistName
            playVC.imageString = self.imageString
            playVC.musicName = self.musicName
            playVC.previewURL = self.previewURL
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return musicNameArray.count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let musicNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let artistNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        

        imageView.sd_setImage(with: URL(string: imageStringArray[indexPath.row]), placeholderImage: UIImage(named: "noImage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        musicNameLabel.text =  musicNameArray[indexPath.row]
        artistNameLabel.text = artistNameArray[indexPath.row]
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        artistName = artistNameArray[indexPath.row]
        musicName = musicNameArray[indexPath.row]
        previewURL = previewURLArray[indexPath.row]
        imageString = imageStringArray[indexPath.row]
        
        
        let urlString = previewURLArray[indexPath.row]
        let url = URL(string: urlString)
        
        
        downLoadMusicURL(url: url!)
        
        moveToSelect()
        
    }
    
    
    func downLoadMusicURL(url: URL){
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            
            //再生
            //self.play(url: url!)
            
            
            
        })
        
        downloadTask.resume()
        
    }
    
    func play(url:URL){
        
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
            
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
            
        }
        
    }
    
    
    @IBAction func playListButton(_ sender: Any) {
        //タップしたセルの行番号を取得
        let btn = sender as! UIButton
        let cell = btn.superview?.superview as! UITableViewCell
        let row = selectTableView.indexPath(for: cell)?.row
        //Optional(行数)と出る
        print("\(row)")

        let childAutoID = ref.child("Users").childByAutoId()
        let autoID = childAutoID.key

        //ポップアップメッセージ用意
        var messageTextField: UITextField?

        let message = UIAlertController(
            title: "メッセージ",
            message: "この曲の紹介文を入力してください。",
            preferredStyle: UIAlertController.Style.alert)
        message.addTextField(
            configurationHandler: {(textField: UITextField!) in
                messageTextField = textField
                textField.placeholder = "メッセージ"
                messageTextField = textField
        })
        message.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        message.addAction(
            UIAlertAction(
                title: "Send",
                style: UIAlertAction.Style.default) { _ in
                    if (messageTextField?.text) != nil {
                        
                        //OKが押された時の処理（Firebaseにデータ登録）
                        //KeyValue型の配列を用意
                        let user = ["image":self.imageStringArray[row!],
                                    "music":self.musicNameArray[row!],
                                    "artist":self.artistNameArray[row!],
                                    "preview":self.previewURLArray[row!],
                                    "message":messageTextField?.text,
                                    "autoID":autoID] as [String : Any]

                        //Firebaseにデータを追加
                        self.ref.child("Users").child(autoID!).setValue(user)
                        
                        
                }
            }
        )
        
        self.present(message, animated: true, completion: nil)
        
        
        
    }
    
    
}


