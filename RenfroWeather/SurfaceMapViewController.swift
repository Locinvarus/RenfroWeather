//
//  SurfaceMapViewController.swift
//  RenfroWeather
//
//  Created by Roger Renfro on 3/2/18.
//  Copyright © 2018 Roger Renfro. All rights reserved.
//

import UIKit
import WebKit

fileprivate var foregroundNotification: NSObjectProtocol!

class SurfaceMapViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup gesture recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        updateMap()
        
        // code to be notifed when app returns to foregound from sleep so we can refresh the data
        foregroundNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            
            // do whatever you want when the app is brought back to the foreground
            self.updateMap()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                tabBarController?.selectedIndex = 2
            case UISwipeGestureRecognizerDirection.left:
                tabBarController?.selectedIndex = 4
            default:
                break
            }
        }
    }
    
    func updateMap() {
        //displayWeatherImage(weatherURL: URL(string: "http://www.wpc.ncep.noaa.gov/noaa/noaa.gif")!)
        let myURL = URL(string: "http://www.wpc.ncep.noaa.gov/noaa/noaa.gif")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
