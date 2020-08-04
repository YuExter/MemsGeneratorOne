//
//  ViewController.swift
//  MemsGeneratorOne
//
//  Created by Jura on 20.07.2020.
//  Copyright © 2020 Jura. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    var fontSize: CGFloat?
    var selectedFont: String?
    var imageData: UIImage?
    var topText: String?
    var bottomText: String?
    var fontText: String?
    var arrayFont = [String]()
    static var currentMem: String?
    static var currentImage: UIImage?
    
    @IBOutlet weak var textLabelTop: UILabel!
    @IBOutlet weak var textLabelBottom: UILabel!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var stepperTop: UIStepper!
    @IBOutlet weak var stepperBottom: UIStepper!
    @IBOutlet weak var textFieldFont: UITextField!
    @IBOutlet weak var activittyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToolBar()
        stepperDefaultValue()
        textFieldTop.delegate = self
        textFieldBottom.delegate = self
        getFont()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupImage()
        getSetupImage()
        
        self.view.endEditing(true)
    }
    @IBAction func memListButton(_ sender: UIBarButtonItem) {
        
        
        performSegue(withIdentifier: "listMems", sender: self)
    }
    @IBAction func sendBotton(_ sender: UIButton) {
        performSegue(withIdentifier: "finishSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "finishSegue" else {return}
        
        guard let destination = segue.destination as? LastVC else {return}
        destination.textTop = topText ?? ""
        destination.textBottom = bottomText ?? ""
        destination.textFont = fontText
        destination.memCurrnet = MainVC.currentMem
    }
    
    
    func setupImage() {
        
        if imageViewOutlet.image == nil {
            activittyIndicator.isHidden = true
            activittyIndicator.hidesWhenStopped = true
        } else {
            activittyIndicator.isHidden = false
            activittyIndicator.hidesWhenStopped = false
            activittyIndicator.startAnimating()
        }
        
        DispatchQueue.main.async {
            do {
                self.imageViewOutlet.image = MainVC.currentImage
                self.activittyIndicator.stopAnimating()
                self.activittyIndicator.isHidden = true
            }
        }
    }
    
    func createToolBar() {
        let elementPicker = UIPickerView()
        elementPicker.delegate = self
        textFieldFont.inputView = elementPicker
        elementPicker.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneItem = UIBarButtonItem(title: "Готово",
                                       style: .plain,
                                       target: self,
                                       action: #selector(dismissKeyboard))
        toolbar.setItems([doneItem], animated: true)
        toolbar.isUserInteractionEnabled = true
        textFieldFont.inputAccessoryView = toolbar
    }
    @objc func dismissKeyboard() {
        fontText = textFieldFont.text ?? ""
        view.endEditing(true)
    }
    func stepperDefaultValue() {
        stepperTop.value = 20
        stepperBottom.value = 20
    }
    @IBAction func tfTopAction(_ sender: UITextField) {
        textLabelTop.text = sender.text
        topText = textFieldTop.text ?? ""
    }
    @IBAction func tfBottomAction(_ sender: UITextField) {
        textLabelBottom.text = sender.text
        bottomText = textFieldBottom.text ?? ""
    }
    @IBAction func stepperTopSizeFont(_ sender: UIStepper) {
        let topFont = textLabelTop.font.fontName
        fontSize = CGFloat(sender.value)
        textLabelTop.font = UIFont(name: topFont, size: fontSize ?? CGFloat(0))
    }
    @IBAction func stepperBottomSizeFont(_ sender: UIStepper) {
        let bottomFont = textLabelBottom.font.fontName
        let fontSize = CGFloat(sender.value)
        textLabelBottom.font = UIFont(name: bottomFont, size: fontSize)
    }
    
    @IBAction func clearButtonItem(_ sender: UIBarButtonItem) {
                self.imageViewOutlet.image = nil
                self.textFieldTop.text = nil
                self.textFieldBottom.text = nil
                self.textFieldFont.text = nil
                self.textLabelTop.text = nil
                self.textLabelBottom.text = nil
        
    }
    
    func getFont() {
        let headers = ["x-rapidapi-host": "ronreiter-meme-generator.p.rapidapi.com",
                       "x-rapidapi-key": "593d858ec7msh44787ba9e3aa6aep106925jsne707a7a50200"]
        
        guard let urlString = URL(string: "https://ronreiter-meme-generator.p.rapidapi.com/fonts") else { return }
        var request = URLRequest(url: urlString)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            
            do {
                self.arrayFont = try JSONSerialization.jsonObject(with: data, options: []) as! [String]
            } catch {
                print(error)
            }
            
        })
        dataTask.resume()
    }
    func generateMem() {
        
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
                LastVC.imageFinish = image
            }
            if (error != nil) {
                print(error ?? "")
            }
        })
        
        dataTask.resume()
    }
    func getSetupImage() {
        let headers = ["x-rapidapi-host": "ronreiter-meme-generator.p.rapidapi.com",
                       "x-rapidapi-key": "593d858ec7msh44787ba9e3aa6aep106925jsne707a7a50200"]
        guard let urlString = URL(string:"https://ronreiter-meme-generator.p.rapidapi.com/meme?meme=\(MainVC.currentMem ?? "")&top=%20&bottom=%20") else { return }
        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            guard let data = data, let image = UIImage(data: data) else {return}
            print(data)
            DispatchQueue.main.async {
                self.imageViewOutlet.image = image

            }
        })
        dataTask.resume()
    }
}

extension MainVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayFont.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayFont[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFont = arrayFont[row]
        textFieldFont.text = selectedFont
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
