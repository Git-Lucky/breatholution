
import UIKit
import AWSSNS
import UserNotifications

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let SNSPlatformApplicationArn = "arn:aws:sns:us-east-1:601642028643:app/APNS_SANDBOX/Breatholution"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Networker.fetchTimeToBreathe { (date) in
            //TODO: compare dates and don't update unless its actually different
            UserDefaults.standard.set(date, forKey: "breatheDate")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "breatheDateSet"), object: nil, userInfo: ["breatheDate":date])
        }
        
        // Initialize the Amazon Cognito credentials provider
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
           identityPoolId:"us-east-1:7e394d73-1acf-466a-b1d1-f8aa77e06af4")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        UIApplication.shared.registerForRemoteNotifications()
//        registerForPushNotifications(application: application)
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("entering foreground")
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /// Attach the device token to the user defaults
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
        UserDefaults.standard.set(token, forKey: "deviceTokenForSNS")
        /// Create a platform endpoint. In this case, the endpoint is a
        /// device endpoint ARN
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = token
        request?.platformApplicationArn = SNSPlatformApplicationArn
        sns.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                    UserDefaults.standard.set(endpointArnForSNS, forKey: "endpointArnForSNS")
                    let subInput = AWSSNSSubscribeInput()
                    subInput?.endpoint = endpointArnForSNS
                    subInput?.topicArn = "arn:aws:sns:us-east-1:601642028643:broadcastLive"
                    subInput?.protocols = "application"
                    sns.subscribe(subInput!) { (subscribeResponse, error) in
                        print(subscribeResponse,error)
                    }
                }
            }
            return nil
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        print("!!!!!!!!!!!!!!")
        if let aps = userInfo["aps"] as? NSDictionary {
            if let body = aps["body"] as? NSDictionary {
                if let payload = body["payload"] as? NSDictionary {
                    guard let title = payload["title"] as? String else { return }
                    guard let url = payload["resourceUri"] as? String else { return }
                    guard let id = payload["id"] as? String else { return }
                    guard let type = payload["type"] as? String else { return }
                    let broadcast = Broadcast(title: title, url: url, id: id, type: type)
                    print(broadcast)
                    if broadcast.type == "live" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "broadcastStarted"), object: nil, userInfo: ["broadcastDetails":broadcast])
                    } else if broadcast.type == "archived" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "broadcastEnded"), object: nil, userInfo: nil)
                    }
                }
            }
        }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        /// The notifications settings
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if (granted) {
//                DispatchQueue.main.async(execute: {
//                  UIApplication.shared.registerForRemoteNotifications()
//                })
            }
            else {
                //TODO: What to do if they say no...do we start polling for live feed instead of relying on webhooks?
                //Do stuff if unsuccessful…
            }
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //TODO: update to check for specific type of push instead of assuming its broadcast started
        let userInfo = notification.request.content.userInfo["aps"] as! NSDictionary
        let alertDictString = userInfo["alert"] as! String
        let broadcastWebhook = decodeBroadcastWebhook(alertDictString: alertDictString as String)
        if broadcastWebhook?.broadcast.type == "live" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "broadcastStarted"), object: nil, userInfo: ["broadcastDetails":broadcastWebhook!.broadcast])
        } else if broadcastWebhook?.broadcast.type == "archived" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "broadcastEnded"), object: nil, userInfo: nil)
        }
    }
    
    // Called to let your app know which action was selected by the user for a given notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("*********")
        print("User Info = ",response.notification.request.content.userInfo["alert"] as! String)
        completionHandler()
    }
    
    func decodeBroadcastWebhook(alertDictString: String) -> BroadcastWebhook? {
        if let data = alertDictString.data(using: .utf8) {
            do {
                return try JSONDecoder().decode(BroadcastWebhook.self, from:data)
                
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
