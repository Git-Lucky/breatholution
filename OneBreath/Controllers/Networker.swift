import Foundation

class Networker {
    
    // https://bt9wxxvr83.execute-api.us-east-1.amazonaws.com/default/dateToBreathe
    
    static func fetchTimeToBreathe(completion: @escaping (Date) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "bt9wxxvr83.execute-api.us-east-1.amazonaws.com"
        components.path = "/default/dateToBreathe"

        guard let url = components.url else {
            preconditionFailure("Failed to construct URL")
        }

        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in

            DispatchQueue.main.async {
                print(data)
                print(response)
                print(error?.localizedDescription)
                completion(Date())
            }
        }

        task.resume()
    }
    
}
