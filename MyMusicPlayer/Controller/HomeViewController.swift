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
    var favoriteModel = FavoriteModel()
    var artistName = ""
    var musicName = ""
    var previewURL = ""
    var imageString = ""
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
        favoriteModel.artistNameArray.removeAll()
        favoriteModel.musicNameArray.removeAll()
        favoriteModel.previewURLArray.removeAll()
        favoriteModel.imageStringArray.removeAll()
        favoriteModel.messageStringArray.removeAll()
        favoriteModel.autoIDArray.removeAll()
        favoriteModel.loadDataFirebase()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.selectTableView.reloadData()
        }
        
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
        return favoriteModel.musicNameArray.count
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
        
        imageView.sd_setImage(with: URL(string: favoriteModel.imageStringArray[indexPath.row]), placeholderImage: UIImage(named: "noimage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        musicNameLabel.text =  favoriteModel.musicNameArray[indexPath.row]
        artistNameLabel.text = favoriteModel.artistNameArray[indexPath.row]
        
        return cell
    }
    //セルの編集許可を与える
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //セルに対する編集が行われた場合に呼び出される関数
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Firebaseのデータを削除
        ref.child("Users/\(String(favoriteModel.autoIDArray[indexPath.row]))").removeValue()
        
        favoriteModel.artistNameArray.remove(at: indexPath.row)
        favoriteModel.musicNameArray.remove(at: indexPath.row)
        favoriteModel.previewURLArray.remove(at: indexPath.row)
        favoriteModel.imageStringArray.remove(at: indexPath.row)
        favoriteModel.autoIDArray.remove(at: indexPath.row)
        //tableViewCellの削除
        selectTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        artistName = favoriteModel.artistNameArray[indexPath.row]
        musicName = favoriteModel.musicNameArray[indexPath.row]
        previewURL = favoriteModel.previewURLArray[indexPath.row]
        imageString = favoriteModel.imageStringArray[indexPath.row]
        
        performSegue(withIdentifier: "favoritePlayVC", sender: nil)
    }
    
    @IBAction func openMessage(_ sender: Any) {
        //タップしたセルの行番号を取得
        let btn = sender as! UIButton
        let cell = btn.superview?.superview as! UITableViewCell
        let row = selectTableView.indexPath(for: cell)?.row
        //Optional(行数)と出る
        //print("\(row)")
        let messageText = UIAlertController(title: "紹介文", message: favoriteModel.messageStringArray[row!], preferredStyle: .alert)
        messageText.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(messageText, animated: true)
    }
}
