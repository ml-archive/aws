# Nodes AWS

This package makes it easy to use AWS resources from Swift.

## Installation

@todo

## Usage

### Describe EC2 instances

This function will return all EC2 instances

```swift
do {
	let instances = try EC2(accessKey: "my-key", secretKey: "my-secret", region: "my-region").describeInstances()
} catch {

}
```

### Raw call

If you need a resource not made in one of the functions, you can use the system to call the AWS API directly.

**Describe instances example**

```swift
do {
	return try CallAWS().call(method: "GET", service: "ec2", host: "ec2.amazonaws.com", region: "my-region", baseURL: "https://ec2.amazonaws.com", key: "my-key", secret: "my-secret", requestParam: "Action=DescribeInstances")
} catch {

}
```
