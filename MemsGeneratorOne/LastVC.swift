//
//  LastVC.swift
//  MemsGeneratorOne
//
//  Created by Jura on 21.07.2020.
//  Copyright © 2020 Jura. All rights reserved.
//

import UIKit

class LastVC: UIViewController {
    
    static var imageFinish: UIImage?
    var textTop = ""
    var textBottom = ""
    var textFont: String?
    static var urlTop: String?
    static var urlBottom: String?
    static var urlFont: String?
    var memCurrnet: String?
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        editText()
        activityViewController()
        imageUpload()
    }
    
    func imageUpload() {
        
        let headers = ["x-rapidapi-host": "ronreiter-meme-generator.p.rapidapi.com",
                       "x-rapidapi-key": "593d858ec7msh44787ba9e3aa6aep106925jsne707a7a50200"]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://ronreiter-meme-generator.p.rapidapi.com/meme?font=\(LastVC.urlFont ?? "Impact")&font_size=50&meme=\(MainVC.currentMem ?? "")&top=\(LastVC.urlTop ?? "")&bottom=\(LastVC.urlBottom ?? "")")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        print(request)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard let data = data, let image = UIImage(data: data) else {return}
            print(data)
            DispatchQueue.main.async {
                self.imageViewOutlet.image = image
            }
            if (error != nil) {
                print(error ?? "")
            }
        })
        dataTask.resume()
    }
 
    func editText() {
        LastVC.urlTop = textTop.components(separatedBy: " ").filter { !$0.isEmpty }.joined(separator: "%20")
        LastVC.urlBottom = textBottom.components(separatedBy: " ").filter { !$0.isEmpty }.joined(separator: "%20")
        LastVC.urlFont = textFont?.components(separatedBy: " ").filter { !$0.isEmpty }.joined(separator: "%20")
    }
    func activityViewController() {
        guard let image = imageViewOutlet.image else { return }
        let items: [Any] = [image]
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    @IBAction func toShareItem(_ sender: UIBarButtonItem) {
        activityViewController()
    }
    
}
