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
import WebKit

class SearchViewController: UIViewController,UITextFieldDelegate {
    var resultMusicModel = ResultMusicModel()
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
        resultMusicModel.artistNameArray.removeAll()
        resultMusicModel.imageStringArray.removeAll()
        resultMusicModel.musicNameArray.removeAll()
        resultMusicModel.previewURLArray.removeAll()
        resultMusicModel.startParse(keyword: searchTextField.text!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.performSegue(withIdentifier: "selectVC", sender: nil)
        }
    }
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if searchTextField.text != nil && segue.identifier == "selectVC"{
            //インスタンス化
            let selectVC = segue.destination as! SelectViewController
            selectVC.artistNameArray = resultMusicModel.artistNameArray
            selectVC.imageStringArray = resultMusicModel.imageStringArray
            selectVC.musicNameArray = resultMusicModel.musicNameArray
            selectVC.previewURLArray = resultMusicModel.previewURLArray
        }
    }
    //キーボードのReturnキーが押された時にキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
