//
//  ViewController.swift
//  Copyright © 2020 MiXeR54. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
  @IBOutlet weak var colorPriceChange: UIView!
  @IBOutlet weak var companyNameLabel: UILabel!
  @IBOutlet weak var companyPickerView: UIPickerView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var companySymbolLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var priceChangeLabel: UILabel!
  
 
    //https://cloud.iexapi.com/v1/ref-data/symbols?&token=pk_2fa13bf6e3094943b01fd89cd8dec82c
    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB",
        "Tesla": "TSLA",
        "Alibaba": "BABA"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.black
//        fetchData()
        
        companyNameLabel.text = "Tinkoff"
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true

        requestQuoteUpdate()
        

    }
//    private func fetchData() {
//        guard let urlFetch = URL(string: "https://cloud.iexapis.com/v1/ref-data/symbols?&token=pk_2fa13bf6e3094943b01fd89cd8dec82c") else {
//            return
//        }
//

    
    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        companySymbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
    }
    

private func requestQuote(for symbol: String) {
    let token = "pk_2fa13bf6e3094943b01fd89cd8dec82c"
    guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=\(token)") else {
        return
    }

    
    let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
        if let data = data,
            (response as? HTTPURLResponse)?.statusCode == 200,
            error == nil {
            self?.parseQuote(from: data)
        } else {
            
            //Simole Error handler with Alert
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "OOPS", message: "Something go wrong", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK:(", style: .default)
                
                alertController.addAction(action)
                self?.present(alertController, animated: true, completion: nil)
                print("Network error! Vse Priehali!")
            }
        }
    }
    
    dataTask.resume()
}

private func parseQuote(from data: Data) {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        guard
            let json = jsonObject as? [String: Any],
            let companyName = json["companyName"] as? String,
            let companySymbol = json["symbol"] as? String,
            let price = json["latestPrice"] as? Double,
            let priceChange = json["change"] as? Double else { return print("Invalid JSON") }
        
        DispatchQueue.main.async { [weak self] in
            self?.displayStockInfo(companyName: companyName,
                                   companySymbol: companySymbol,
                                   price: price,
                                   priceChange: priceChange)
        }
    } catch {
        print("JSON parsing error: " + error.localizedDescription)
    }
}
    private func displayStockInfo(companyName: String,
                                  companySymbol: String,
                                  price: Double,
                                  priceChange: Double) {
    activityIndicator.stopAnimating()
    companyNameLabel.text = companyName
    companySymbolLabel.text = companySymbol
    priceLabel.text = "\(price)"
    priceChangeLabel.text = "\(priceChange)"
        //color indicator
        colorPriceChange.backgroundColor = priceChange > 0
            ? UIColor.green.withAlphaComponent(0.7)
            : UIColor.red.withAlphaComponent(0.7)
        
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
}
extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Array(companies.keys)[row]
}

      func pickerView(_ PickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       requestQuoteUpdate()
      }
    
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
