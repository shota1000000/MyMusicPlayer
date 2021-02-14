//
//  TicketViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/06/07.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

class TicketViewController: UIViewController,UITextFieldDelegate {
    var ticketModel = TicketModel()
    @IBOutlet weak var searchTicketTextField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTicketTextField.delegate = self
        searchTicketTextField.becomeFirstResponder()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.overrideUserInterfaceStyle = .dark
        let twitterURL = URL(string: "https://twitter.com/search?q=%E9%9F%B3%E6%A5%BD%E3%83%A9%E3%82%A4%E3%83%96%E6%83%85%E5%A0%B1&src=typed_query")
        let request = URLRequest(url: twitterURL!)
        webView.load(request)
    }
    
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if searchTicketTextField.text != nil && segue.identifier == "selectTicketVC"{
            //インスタンス化
            let selectTicketVC = segue.destination as! SelectTicketViewController
            selectTicketVC.liveNameArray = ticketModel.liveNameArray
            selectTicketVC.liveDateArray = ticketModel.liveDateArray
            selectTicketVC.livePlaceArray = ticketModel.livePlaceArray
            selectTicketVC.liveImageURLArray = ticketModel.liveImageURLArray
            selectTicketVC.liveImageArray = ticketModel.liveImageArray
        }
    }
    
    @IBAction func searchTicketButton(_ sender: Any) {
        ticketModel.getTicketInfo(keyword: searchTicketTextField.text!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performSegue(withIdentifier: "selectTicketVC", sender: nil)
        }
    }
    //キーボードのReturnキーが押された時にキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
