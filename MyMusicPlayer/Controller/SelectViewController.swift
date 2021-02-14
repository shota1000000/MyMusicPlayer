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
//import PKHUD
//import ViewAnimator

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
        self.overrideUserInterfaceStyle = .dark
    }
    
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVC"{
            //インスタンス化
            let playVC = segue.destination as! PlayViewController
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
        
        imageView.sd_setImage(with: URL(string: imageStringArray[indexPath.row]), placeholderImage: UIImage(named: "noimage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        musicNameLabel.text = musicNameArray[indexPath.row]
        artistNameLabel.text = artistNameArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        artistName = artistNameArray[indexPath.row]
        musicName = musicNameArray[indexPath.row]
        previewURL = previewURLArray[indexPath.row]
        imageString = imageStringArray[indexPath.row]
        performSegue(withIdentifier: "playVC", sender: nil)
    }
    
    @IBAction func playListButton(_ sender: Any) {
        //タップしたセルの行番号を取得
        let btn = sender as! UIButton
        let cell = btn.superview?.superview as! UITableViewCell
        let row = selectTableView.indexPath(for: cell)?.row
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
                        //Sendが押された時の処理（Firebaseにデータ登録）
                        //KeyValue型の配列を用意
                        let user = ["image":self.imageStringArray[row!],
                                    "music":self.musicNameArray[row!],
                                    "artist":self.artistNameArray[row!],
                                    "preview":self.previewURLArray[row!],
                                    "message":messageTextField?.text as Any,
                                    "autoID":autoID as Any] as [String : Any]
                        //Firebaseにデータを追加
                        self.ref.child("Users").child(autoID!).setValue(user)
                    }
            }
        )
        self.present(message, animated: true, completion: nil)
    }
}


