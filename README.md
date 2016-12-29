# Nodes AWS

![Swift](http://img.shields.io/badge/swift-3.0-brightgreen.svg)
[![Build Status](https://travis-ci.org/nodes-vapor/aws.svg?branch=master)](https://travis-ci.org/nodes-vapor/aws)
[![codebeat badge](https://codebeat.co/badges/52c2f960-625c-4a63-ae63-52a24d747da1)](https://codebeat.co/projects/github-com-nodes-vapor-aws)
[![codecov](https://codecov.io/gh/nodes-vapor/aws/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/aws)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/aws)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/aws)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/nodes-ios/Serializable/blob/master/LICENSE) 
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg) 


This package makes it easy to use AWS resources from Swift.

## 📝 Requirements
- Swift 3.0+

## 📦 Installation

### Swift Package Manager

Add the following to your Package.swift file

```swift
import PackageDescription

let package = Package(
    name: "YourPackage",
    dependencies: [
        .Package(url: "https://github.com/nodes-vapor/aws.git", majorVersion: 1)
    ]
)
```

## 💻 Usage

Currently the following AWS Services are available:
- EC2
- S3

If you need other resources you can use Raw call, to call the AWS API directly.

### EC2

**Describe instances**

```swift
do {
	let instances = try EC2(
	    accessKey: "my-key", 
	    secretKey: "my-secret", 
	    region: "my-region").describeInstances()
} catch {

}
```

### S3

**Upload a file to S3**

```swift
do {
    try S3(
        accessKey: "my-key", 
        secretKey: "my-secret", 
        region: "my-region", 
        bucket: "my-s3-bucket").uploadFile("/path/to/local/file", "/folder/in/s3/bucket")
} catch {

}
```

### Raw call

If you need a resource not made in one of the functions, you can use the system to call the AWS API directly.

**Describe instances example**

```swift
do {
	return try CallAWS().call(
		method: "GET", 
		service: "ec2", 
		host: "ec2.amazonaws.com", 
		region: "my-region", 
		baseURL: "https://ec2.amazonaws.com", 
		key: "my-key", 
		secret: "my-secret", 
		requestParam: "Action=DescribeInstances")
} catch {

}
```

## 🔧 Compatibility

This package has been tested on Mac OS X and Ubuntu 16.04

## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**AWS** is available under the MIT license. See the [LICENSE](https://github.com/nodes-ios/Serializable/blob/master/LICENSE) file for more info.