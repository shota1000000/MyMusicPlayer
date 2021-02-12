//
//  HomeViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/05/19.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation
import NVActivityIndicatorView

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var artistName = ""
    var musicName = ""
    var previewURL = ""
    var imageString = ""
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    var messageStringArray = [String]()
    var autoIDArray = [String]()
    var player:AVAudioPlayer?
    
    let ref = Database.database().reference()
    
    @IBOutlet weak var selectTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectTableView.delegate = self
        selectTableView.dataSource = self
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.overrideUserInterfaceStyle = .dark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Firebaseのデータに更新があった場合，musicNameArrayなどの中身を編集
        artistNameArray.removeAll()
        musicNameArray.removeAll()
        previewURLArray.removeAll()
        imageStringArray.removeAll()
        messageStringArray.removeAll()
        autoIDArray.removeAll()
        loadDataFirebase()
        
        let indicatorView = NVActivityIndicatorView(frame: view.bounds)
        indicatorView.type = .orbit
        indicatorView.color = .darkGray
        indicatorView.alpha = 0.7
        indicatorView.backgroundColor = .black
        indicatorView.startAnimating()
        view.addSubview(indicatorView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            indicatorView.stopAnimating()
            indicatorView.removeFromSuperview()
        }
    }
    
    func loadDataFirebase(){
        ref.child("Users").observeSingleEvent(of: .value){(snap, error) in
            let snapdata = snap.value as? [String:NSDictionary]
            if snapdata == nil {
                return
            }
            //snapdata!.keys : 階層
            //key : 階層
            for key in snapdata!.keys.sorted(){
                let snap = snapdata![key]
                if let imageName = snap!["image"] as? String{
                    self.imageStringArray.append(imageName)
                }
                if let artistName = snap!["artist"] as? String{
                    self.artistNameArray.append(artistName)
                }
                if let musicName = snap!["music"] as? String{
                    self.musicNameArray.append(musicName)
                }
                if let previewName = snap!["preview"] as? String{
                    self.previewURLArray.append(previewName)
                }
                if let message = snap!["message"] as? String{
                    self.messageStringArray.append(message)
                }
                if let autoID = snap!["autoID"] as? String{
                    self.autoIDArray.append(autoID)
                }
                self.selectTableView.reloadData()
            }
        }
    }
    
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoritePlayVC"{
            //インスタンス化
            let playVC = segue.destination as! FavoritePlayViewController
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let musicNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let artistNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        imageView.sd_setImage(with: URL(string: imageStringArray[indexPath.row]), placeholderImage: UIImage(named: "noimage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        musicNameLabel.text =  musicNameArray[indexPath.row]
        artistNameLabel.text = artistNameArray[indexPath.row]
        
        return cell
    }
    //セルの編集許可を与える
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //セルに対する編集が行われた場合に呼び出される関数
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Firebaseのデータを削除
        ref.child("Users/\(String(autoIDArray[indexPath.row]))").removeValue()
        
        artistNameArray.remove(at: indexPath.row)
        musicNameArray.remove(at: indexPath.row)
        previewURLArray.remove(at: indexPath.row)
        imageStringArray.remove(at: indexPath.row)
        autoIDArray.remove(at: indexPath.row)
        //tableViewCellの削除
        selectTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        artistName = artistNameArray[indexPath.row]
        musicName = musicNameArray[indexPath.row]
        previewURL = previewURLArray[indexPath.row]
        imageString = imageStringArray[indexPath.row]
        
        let urlString = previewURLArray[indexPath.row]
        let url = URL(string: urlString)
        
        performSegue(withIdentifier: "favoritePlayVC", sender: nil)
    }
    
    @IBAction func openMessage(_ sender: Any) {
        //タップしたセルの行番号を取得
        let btn = sender as! UIButton
        let cell = btn.superview?.superview as! UITableViewCell
        let row = selectTableView.indexPath(for: cell)?.row
        //Optional(行数)と出る
        print("\(row)")
        var messageText = UIAlertController(title: "紹介文", message: messageStringArray[row!], preferredStyle: .alert)
        messageText.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(messageText, animated: true)
    }
}
