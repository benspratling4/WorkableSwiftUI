# WorkableSwiftUI
 SwiftUI is awesome, in theory.  In practice, it's another story.  Here's what you need to make it actually usable.
 
 
 
 ## Identified
 So you changed your data model to structs, and now they dont have unique id's. But what if you need your type to have `Identifiable` conformance, but there's no 'id' in your serialized data model?
 
 For instance, ever want to `ForEach` over an array of items which are uniquely identified by their position in the array?  (and isn't that like the #1 thing you actually want to do with a ForEach?)  Apple's all like "that's deprecated".
 
 WorkableSwiftUI introduces `Identified`, a type which quietly inserts a unique stable id into the data model but won't need to seriliza it out, nor will it demand that it have been in the data model all along.
 
 Now, of course, the auto-created id's aren't written out to disk... that's the whole point, so they aren't stable across serializations / deserializaitons (or app launches), but they are stable in ram.


Let's see an example, suppose you have a `SampleStruct`

```swift
struct SampleStruct : Codable {
	var name:String
	var height:Double
}
```

And your data model is 

```swift
struct ContainerStruct : Codable {
	var samples:[SampleStruct]
}
```

Where are you going to insert the id's?  They aren't in the json.
```json
{
	"samples": [
		{
			"name":"Title"
			"height":13.976
		}
	]
}
```
The fields you have aren't unique id's.  Perhaps someone could edit them and what forces themt o be unique in the array?
Are you going to write awful manual serialization / deserialization code to insert them and then avoid them when serializing?  yuck.  Serialization / deserialization ought to be codeless nowadays.

Just use Identified instead.


```swift
struct ContainerStruct : Codable {
	var samples:[Identified<SampleStruct>]
}
```

It provides conditional Encodable and Decodable conformances which don't require any changes to your file format, but do provide the unique id's when in ram (using UUID).

It also allows you to work with the array as though it is just a `[SampleStruct]` in many cases. 




