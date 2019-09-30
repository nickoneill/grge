import UIKit
import WatchConnectivity
import IntentsUI

class SettingsViewController: UIViewController {
    @IBOutlet var baseURLTextField: UITextField?
    @IBOutlet var sharedSecretTextField: UITextField?
    var session: WCSession?

  override func viewDidLoad() {
    super.viewDidLoad()

    let fields: Array<UITextField> = [self.baseURLTextField!, self.sharedSecretTextField!];
    for textField in fields {
      textField.layer.shadowOffset = CGSize(width: 0, height: 1.0)
      textField.layer.shadowOpacity = 0.15;
      textField.layer.shadowColor = UIColor.white.cgColor
      textField.layer.shadowRadius = 1.0;
    }

    if WCSession.isSupported() {
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    let siriButton = INUIAddVoiceShortcutButton(style: .white)
    if let shortcut = INShortcut(intent: GarageIntentIntent()) {
        siriButton.shortcut = shortcut
    }
    self.view.addSubview(siriButton)
    siriButton.translatesAutoresizingMaskIntoConstraints = false
    siriButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    siriButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let defaults = UserDefaults(suiteName: AppGroupName) {
        self.baseURLTextField!.text = defaults.string(forKey: UserSettingsKey.baseURL)
        self.sharedSecretTextField!.text = defaults.string(forKey: UserSettingsKey.sharedSecret)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let defaults = UserDefaults(suiteName: AppGroupName) {
        defaults.set(self.baseURLTextField!.text, forKey: UserSettingsKey.baseURL)
        defaults.set(self.sharedSecretTextField!.text, forKey: UserSettingsKey.sharedSecret)
    }
  }
}

extension SettingsViewController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }

    func sessionDidDeactivate(_ session: WCSession) {
        //
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.session = session
    }


    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // all the documentation I can find says that sending a message from the watch should wake up the
        // iOS app, but if we're creating a session and setting a delegate, that doesn't persist beyond
        // the current app session. Instead, let's do this dumbly and sync the credentials if the
        // settings screen is open.

        let message = [
            UserSettingsKey.baseURL: self.baseURLTextField?.text ?? "",
            UserSettingsKey.sharedSecret: self.sharedSecretTextField?.text ?? ""
        ]

        replyHandler(message)
    }
}
