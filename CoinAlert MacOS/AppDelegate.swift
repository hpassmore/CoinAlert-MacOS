//
//  AppDelegate.swift
//  CoinAlert MacOS
//
//  Created by Howard Passmore on 1/3/17.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // URL we use to get the price of a bitcoin (see https://github.com/d1str0/CoinAlert-Server for more info)
    let priceURL = "https://whatdoesabitcoincost.com/api/current"
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    @IBOutlet weak var statusMenu: NSMenu!
    
    // timer to update the value of a bitcoin
    weak var timer: Timer?

    // called when we click on the Quit CoinAlert button
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        updatePrice()
    }
    
    // called when the application finishes launching. Populate our status menu and start the update timer.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "$..."
        statusItem.menu = statusMenu
        startTimer()
    }
    
    // called to update the price on the menu bar
    func updatePrice() {
        let requestURL: NSURL = NSURL(string: priceURL)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200) {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                        
                        if let json = json as? [String: Any] {
                            self.statusItem.title = "$\(json["currentPrice"]!)"
                        }
                        
                    }catch {
                        //This means the JSON did not deserialize properly
                        print("Error Deserializing Json.")
                        print("\(error)")
                    }
                } else {
                    print("Server returned \(statusCode). Resetting value.")
                    self.statusItem.title = "$..."
                }
            } else {
                print("Unexpected error")
                self.statusItem.title = "$..."
            }
        }
        
        task.resume()
    }
    
    // starts our timer, firing at 30 second intervals to call our updatePrice() method
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(updatePrice), userInfo: nil, repeats: true)
        timer?.fire()
    }
}

