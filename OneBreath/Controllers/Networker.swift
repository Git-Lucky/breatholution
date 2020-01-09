import Foundation

class Networker {
    
    struct Time: Codable {
        let hour: Int
        let minute: Int
    }
    
    static func fetchTimeToBreathe(completion: @escaping (Date) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "bt9wxxvr83.execute-api.us-east-1.amazonaws.com"
        components.path = "/default/dateToBreathe"
        
        guard let url = components.url else {
            preconditionFailure("Failed to construct URL")
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let fetchedTimeToBreathe = try decoder.decode(Time.self, from: data)
                    
                    let currentDate = Date()
                    
                    // get epoch date for user
                    let epochDate = currentDate.timeIntervalSince1970
                    let timezoneOffset =  TimeZone.current.secondsFromGMT()
                    let timezoneEpochOffset = (epochDate - Double(timezoneOffset))
                    let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
                    
                    // construct epoch time to breathe
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents(in: TimeZone.current, from: timeZoneOffsetDate)
                    dateComponents.hour = fetchedTimeToBreathe.hour
                    dateComponents.minute = fetchedTimeToBreathe.minute
                    dateComponents.second = 0
                    let naiveBreatheDate = calendar.date(from: dateComponents)
                    
                    // compare to see if its already happened
                    let dateComparison = calendar.compare(timeZoneOffsetDate, to: naiveBreatheDate!, toGranularity: .minute)
                    
                    var dateToBreathe: Date
                    if dateComparison == .orderedAscending {
                        dateToBreathe = naiveBreatheDate! + TimeInterval(timezoneOffset)
                    } else {
                        dateToBreathe = naiveBreatheDate!.addingTimeInterval(86400) + TimeInterval(timezoneOffset)
                    }
                    
                    DispatchQueue.main.async {
                        completion(dateToBreathe)
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            }
        }
        
        task.resume()
    }
    
    static func checkForLiveBroadcast(completion: @escaping (Broadcast?) -> Void) {
        print("checking for live broadcast")
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bambuser.com"
        components.path = "/broadcasts"
        
        guard let url = components.url else {
            preconditionFailure("Failed to construct URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.bambuser.v1+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer 7k2t3oug4cyxk83i0kqpeiihg", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let broadcasts = try decoder.decode(BroadcastResults.self, from: data)
                    for broadcast in broadcasts.results {
                        if broadcast.type == "live" {
                            DispatchQueue.main.async {
                                completion(broadcast)
                            }
                            return
                        }
                    }
                    print("no live broadcast")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    print("error: ", error)
                }
            }
        }
        
        task.resume()
    }
}
