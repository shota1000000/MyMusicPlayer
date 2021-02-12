//
//  SearchViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/05/20.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import WebKit

class SearchViewController: UIViewController,UITextFieldDelegate {
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.overrideUserInterfaceStyle = .dark
        
        let twitterURL = URL(string: "https://twitter.com/search?q=%E3%82%A2%E3%83%BC%E3%83%86%E3%82%A3%E3%82%B9%E3%83%88%E6%83%85%E5%A0%B1&src=typed_query")
        let request = URLRequest(url: twitterURL!)
        webView.load(request)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        startParse(keyword: searchTextField.text!)
    }
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if searchTextField.text != nil && segue.identifier == "selectVC"{
            //インスタンス化
            let selectVC = segue.destination as! SelectViewController
            selectVC.artistNameArray = self.artistNameArray
            selectVC.imageStringArray = self.imageStringArray
            selectVC.musicNameArray = self.musicNameArray
            selectVC.previewURLArray = self.previewURLArray
        }
    }
    
    func startParse(keyword:String){
        
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&country=jp"
        let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        //AlamoFireを使ってリクエストを投げる
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{
            (response) in
            print(response)
            
            switch response.result{
                
            case .success:
                let json:JSON = JSON(response.data as Any)
                print(json)
                
                var resultCount:Int = json["resultCount"].int!
                
                for i in 0 ..< resultCount{
                    //ジャケット写真
                    var artWorkUrl = json["results"][i]["artworkUrl60"].string
                    //音声URL
                    let previewURL = json["results"][i]["previewUrl"].string
                    //アーティスト名
                    let artistName = json["results"][i]["artistName"].string
                    //曲名
                    let trackCensoredName = json["results"][i]["trackCensoredName"].string
                    
                    if let range = artWorkUrl!.range(of: "60x60bb"){
                        
                        artWorkUrl?.replaceSubrange(range, with: "320x320bb")
                    }
                    
                    if artWorkUrl != nil{
                        self.imageStringArray.append(artWorkUrl!)
                    }
                    if previewURL != nil{
                        self.previewURLArray.append(previewURL!)
                    }
                    if artistName != nil{
                        self.artistNameArray.append(artistName!)
                    }
                    if trackCensoredName != nil{
                        self.musicNameArray.append(trackCensoredName!)
                    }
                    
                    if self.musicNameArray.count == resultCount{
                        
                        self.performSegue(withIdentifier: "selectVC", sender: nil)
                    }
                }
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    
    //キーボードのReturnキーが押された時にキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
