//
//  WebcamViewController.swift
//  RenfroWeather
//
//  Created by Roger Renfro on 3/2/18.
//  Copyright © 2018 Roger Renfro. All rights reserved.
//

import UIKit
import WebKit

fileprivate var foregroundNotification: NSObjectProtocol!

class WebcamViewController: UIViewController, WKUIDelegate {

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
        
        updateWebcam()
        
        // code to be notifed when app returns to foregound from sleep so we can refresh the data
        foregroundNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            // do whatever you want when the app is brought back to the foreground
            self.updateWebcam()
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
                tabBarController?.selectedIndex = 0
            case UISwipeGestureRecognizerDirection.left:
                tabBarController?.selectedIndex = 2
            default:
                break
            }
        }
    }
    
    func updateWebcam() {

        //displayWeatherImage(weatherURL: URL(string: "http://www.weather.lochinvarus.com/images/webcam.jpg")!)
        let myURL = URL(string: "http://www.weather.lochinvarus.com/images/webcam.jpg")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
