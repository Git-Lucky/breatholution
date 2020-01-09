import Foundation

struct BroadcastResults: Decodable {
    let results: [Broadcast]
}

struct Broadcast: Decodable {
    let title: String
    let url: String
    let id: String
    let type: String
    
    init(title: String, url: String, id: String, type: String) {
        self.title = title
        self.url = url
        self.id = id
        self.type = type
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case url = "resourceUri"
        case id
        case type
    }
}

struct BroadcastWebhook: Decodable {
    let broadcast: Broadcast
    let action: String
    let collection: String
    
    init(broadcast: Broadcast, action: String, collection: String) {
        self.broadcast = broadcast
        self.action = action
        self.collection = collection
    }
    
    enum CodingKeys: String, CodingKey {
        case broadcast = "payload"
        case action
        case collection
    }
}
/*
 {
   "results": [
     {
       "author": "Sveninge Bambuser",
       "clientVersion": "0.9.24 libbambuser com.bambuser.myapp 1.1.3",
       "created": 1466083683,
       "customData": "{\"foo\":\"bar\"}",
       "height": 480,
       "id": "3ea88ab0-7f98-11e6-9b48-fbbdc08b78b9",
       "ingestChannel": "04e32ddd-112d-7f2e-ef9a-2c8dbf104471",
       "lat": 59.345258,
       "length": 411,
       "lon": 18.093741,
       "positionAccuracy": 75,
       "positionType": "network",
       "preview": "https://archive.bambuser.com/3ea88ab0-7f98-11e6-9b48-fbbdc08b78b9.jpg",
       "resourceUri": "https://cdn.bambuser.net/broadcasts/3ea88ab0-7f98-11e6-9b48-fbbdc08b78b9?da_signature_method=HMAC-SHA256&da_id=62e69c26-1c9b-4832-223a-42a5b9d87894&da_timestamp=1474482206&da_static=1&da_ttl=0&da_signature=91143d7410b18a92bfd6d0c2981aa6acb733208d2b6e86d7114e9aea01585c81",
       "tags": [
         {
           "text": "test"
         }
       ],
       "title": "Test broadcast foo",
       "type": "archived",
       "width": 720
     },
     {
       "author": "Sveninge Bambuser",
       "clientVersion": "0.9.24 libbambuser com.bambuser.myapp 1.1.3",
       "created": 1454496122,
       "customData": "{\"foo\":\"bar\"}",
       "height": 480,
       "id": "42580552-7f98-11e6-9b48-fbbdc08b78b9",
       "ingestChannel": "04e32ddd-112d-7f2e-ef9a-2c8dbf104471",
       "lat": -14.235004,
       "length": 19986084,
       "lon": -51.92528,
       "positionAccuracy": 3195790,
       "positionType": "country",
       "preview": "https://archive.bambuser.com/42580552-7f98-11e6-9b48-fbbdc08b78b9.jpg",
       "resourceUri": "https://cdn.bambuser.net/broadcasts/42580552-7f98-11e6-9b48-fbbdc08b78b9?da_signature_method=HMAC-SHA256&da_id=62e69c26-1c9b-4832-223a-42a5b9d87894&da_timestamp=1474482206&da_static=1&da_ttl=0&da_signature=5a87a6484f131c43149f8ee27065928fd7e9500b65e98bcd2e6a206b2d93e632",
       "tags": [],
       "title": "Test broadcast bar",
       "type": "live",
       "width": 640
     }
   ],
   "next": "eyJicm9hZGNhc3Rfb3JkZXJfaWRfYWZ0ZXIiOiIxMzYxMTkyMjkyXzkwMDk1IiwiaW1hZ2VfY3JlYXRlZF9hZnRlciI6IjEzNjExOTIyOTIifQ=="
 }
 
 
{
  "action": "add",
  "collection": "broadcast",
  "payload": {
    "author": "Sveninge Bambuser",
    "created": 1474033783,
    "customData": "",
    "height": 540,
    "id": "9353eaec-794f-11e6-97c0-f19001529702",
    "ingestChannel": "cfc8626c-9a0e-ab78-6424-3eb0978d8e45",
    "lat": 63.205312,
    "length": 0,
    "lon": 17.13011,
    "positionAccuracy": 25,
    "positionType": "GPS",
    "preview": "https://archive.bambuser.com/9353eaec-794f-11e6-97c0-f19001529702.jpg",
    "resourceUri": "https://cdn.bambuser.net/broadcasts/9353eaec-794f-11e6-97c0-f19001529702?da_signature_method=HMAC-SHA256&da_id=9353eaec-794f-11e6-97c0-f19001529702&da_timestamp=1474033783&da_static=1&da_ttl=0&da_signature=eaf4c9cb29c58b910dcbad17cf7d8a3afa4e6a963624ba4c4fd0bb5bade1cdd6",
    "tags": [
      {
        "text": "whoa"
      }
    ],
    "title": "Amazing!",
    "type": "live",
    "width": 960
  },
  "eventId": "93df93061a891c23"
}
*/
