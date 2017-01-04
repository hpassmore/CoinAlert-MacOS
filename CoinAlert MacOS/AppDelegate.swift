//
//  AppDelegate.swift
//  CoinAlert MacOS
//
//  Created by Howard Passmore on 1/3/17.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    @IBOutlet weak var statusMenu: NSMenu!
    weak var timer: Timer?

    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "$..."
        statusItem.menu = statusMenu
        startTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func updatePrice() {
        let requestURL: NSURL = NSURL(string: "https://whatdoesabitcoincost.com/api/current")!
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.updatePrice()
        }
    }
}

