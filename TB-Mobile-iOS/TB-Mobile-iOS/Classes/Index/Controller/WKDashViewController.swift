//
//  WKDashViewController.swift
//  TB-Mobile-iOS
//
//  Created by dongmingming on 2018/10/31.
//  Copyright © 2018年 DongMingMing. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class WKDashViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    var myRequest: URLRequest!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        URLProtocol.registerClass(MyURLProtocol.self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        URLProtocol.unregisterClass(MyURLProtocol.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setNavTitle("数据看板")
        
        
        // wkwebview
        webView = WKWebView(frame: CGRect(x: 0, y: -60, width: kScreen_W, height: kScreen_H + 60))
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        // Appdelegate
        let app = UIApplication.shared.delegate as! AppDelegate
        
        let possibleCachedResponse = app.cachedResponseForCurrentRequest(webUrl)
        if possibleCachedResponse == nil {
            if #available(iOS 10.0, *) {
                let context = app.persistentContainer.viewContext
                // no exist
                // create NSManagedObject instance to match the Xcdatamodeld files in the corresponding data model。
                let cachedResponse = NSEntityDescription
                    .insertNewObject(forEntityName: "CachedURLResponse",
                                     into: context) as NSManagedObject
                let htmlPath = Bundle.main.path(forResource:"bundle.897b646d204a361b42e8", ofType:"js")
                
                do{
                    let recData = try Data.init(contentsOf: URL(fileURLWithPath: htmlPath!))
                    
                    cachedResponse.setValue(recData, forKey: "data")
                    cachedResponse.setValue("\(rootURL)/static/bundle.897b646d204a361b42e8.js", forKey: "url")
                    //        cachedResponse.setValue(Date(), forKey: "timestamp")
                    cachedResponse.setValue("application/javascript" ,forKey: "mimeType")
                    cachedResponse.setValue("", forKey: "encoding")
                    
                }
                catch {
                    
                }
                // save (Core Data, the Data should be placed in the main thread, or concurrency is easy to collapse)
                DispatchQueue.main.async(execute: {
                    do {
                        try context.save()
                    } catch {
                        print("不能保存：\(error)")
                    }
                })
            }
        }
        
        self.req()
    }

    func req() {
        
        let url = URL(string:rootURL)
        myRequest = URLRequest(url: url!)
        webView.load(myRequest)
        
        // show MBProgressHUD
        hudManager.showHud(self)
        
    }
    
    
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.hudManager.hideHud(self)
            var username = userDefault.object(forKey: "username") as! String
            if (!username.contains("@limaicloud.com") && !username.contains("@qq.com")) {
                username = username + "@limaicloud.com"
            }
            let password = userDefault.object(forKey: "password") as! String
            let js = "var username = document.getElementById('username-input');" +
                "username.value = '\(username)';" +
                "username.dispatchEvent(new Event('input'));" +
                "var password = document.getElementById('password-input');" +
                "password.value = '\(password)';" +
                "password.dispatchEvent(new Event('input'));" +
            "document.getElementsByTagName('button')[0].click();"
    
            webView.evaluateJavaScript(js) { (result, error) in
    
            }
    
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
