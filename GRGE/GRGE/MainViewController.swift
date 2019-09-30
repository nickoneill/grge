import UIKit
import Intents

class MainViewController: UIViewController {
  static private let instructionsText = "Press and hold in the area above"
  static private let keepHoldingText = "Keep holding…"
  static private let requestMadeText = "Sending request…"
  static private let successText = "Hooray! Door triggered."
  static private let errorText = "Uh oh. Something went wrong."
  
  @IBOutlet var settingsButton: UIButton?
  @IBOutlet var mainButton: UIButton?
  @IBOutlet var mainLabel: UILabel?
  
  private var touchTimer: Timer?
  private var textTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        mainLabel!.text = MainViewController.instructionsText

        let settingsIconImage = UIImage(named: "gears")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        settingsButton!.setImage(settingsIconImage, for: UIControl.State.normal)
        settingsButton!.tintColor = UIColor.white

        setupIntents()
    }

    func setupIntents() {
        print("setup")
          let intent = GarageIntentIntent()
          intent.suggestedInvocationPhrase = "Toggle Garage"

          let interaction = INInteraction(intent: intent, response: nil)

          interaction.donate { (error) in
            if error != nil {
              if let error = error as NSError? {
                print("interaction donate failed: \(error)")
//                os_log("Interaction donation failed: %@", log: OSLog.default, type: .error, error)
              } else {
                print("donated intent")
//                os_log("Successfully donated interaction")
              }
            }
          }
    }

    public func toggleGarage() {
        triggerDoor()
    }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  @IBAction func onTouchDown(button: UIButton) {
    if textTimer != nil { return }

    touchTimer = Timer(timeInterval: 3.0,
                       repeats: false,
                       block: {_ in
                         self.clearTouchTimer()
                         self.triggerDoor()
                       })
    RunLoop.current.add(touchTimer!, forMode: RunLoop.Mode.common)
    setMainLabelText(MainViewController.keepHoldingText)
  }
  
  @IBAction func onTouchUp(button: UIButton) {
    if textTimer != nil { return }

    clearTouchTimer()
    setMainLabelText(MainViewController.instructionsText)
  }
  
  func setMainLabelText(_ text: String) {
    UIView.transition(with: mainLabel!,
                      duration: 0.25,
                      options: UIView.AnimationOptions.transitionCrossDissolve,
                      animations: { self.mainLabel!.text = text },
                      completion: nil)
  }
  
  func setMainLabelText(_ text: String, forDuration: TimeInterval) {
    clearTextTimer()
    setMainLabelText(text)
    textTimer = Timer(timeInterval: 3.0,
                      repeats: false,
                      block: {_ in
                        self.clearTextTimer()
                        self.setMainLabelText(MainViewController.instructionsText)
                      }
    )
    RunLoop.main.add(textTimer!, forMode: RunLoop.Mode.common)
  }
  
  func clearTextTimer() {
    if textTimer != nil {
      textTimer!.invalidate()
      textTimer = nil
    }
  }
  
  func clearTouchTimer() {
    if touchTimer != nil {
      touchTimer!.invalidate()
      touchTimer = nil
    }
  }
  
  func triggerDoor() {
    guard let defaults = UserDefaults(suiteName: AppGroupName) else {
        setMainLabelText("no shared group")
        return
    }

    guard let baseURL = defaults.string(forKey: UserSettingsKey.baseURL),
        let sharedSecret = defaults.string(forKey: UserSettingsKey.sharedSecret) else {
        setMainLabelText("Must set base URL and shared secret")
        return
    }

    guard let url = URL(string: baseURL) else {
        setMainLabelText("base URL doesn't appear to be valid")
        return
    }

    setMainLabelText(MainViewController.requestMadeText)
    GarageAPI.shared.toggleGarage(at: url, withSecret: sharedSecret)

//    let task = URLSession.shared.dataTask(with: url!, completionHandler: {
//      data, response, error in
//
//      self.isolationQueue.async(flags: .barrier) {
//        self.requestPending = false
//      }
//
//      if let errorStr = error?.localizedDescription {
//        print("error:", errorStr)
//        DispatchQueue.main.async {
//          self.setMainLabelText(MainViewController.errorText, forDuration: 5.0)
//        }
//      } else if let httpResponse = response as? HTTPURLResponse {
//        print("Status: \(httpResponse.statusCode)")
//        if  httpResponse.statusCode == 200 {
//          DispatchQueue.main.async {
//            self.setMainLabelText(MainViewController.successText, forDuration: 5.0)
//          }
//        } else {
//          DispatchQueue.main.async {
//            self.setMainLabelText(MainViewController.errorText, forDuration: 5.0)
//          }
//        }
//        if data != nil {
//          let body = String(data:data!, encoding:String.Encoding.utf8)
//          print("Response body: \(body!)")
//        }
//      }
//    })
//    task.resume()
  }
}
