//
//  FauxResult.swift
//  Postal-macOS
//
//  Created by Brian Schick on 1/29/18.
//  Copyright © 2018 snips. All rights reserved.
//

public protocol ResultProtocol {
	associatedtype Value
	associatedtype Error: Swift.Error
	
	init(value: Value)
	init(error: Error)
	
	var result: PostalResult<Value, Error> { get }
}

public struct AnyError: Swift.Error {
	public let error: Swift.Error
	
	public init(_ error: Swift.Error) {
		if let anyError = error as? AnyError {
			self = anyError
		} else {
			self.error = error
		}
	}
}

public enum PostalResult<Value, Error: Swift.Error>: ResultProtocol, CustomStringConvertible, CustomDebugStringConvertible {
	case success(Value)
	case failure(Error)
	
	public init(value: Value) {
		self = .success(value)
	}
	
	public init(error: Error) {
		self = .failure(error)
	}
	
	public init(_ value: Value?, failWith: @autoclosure () -> Error) {
		self = value.map(PostalResult.success) ?? .failure(failWith())
	}
	
	public init(_ f: @autoclosure () throws -> Value) {
		self.init(attempt: f)
	}
	
	public init(attempt f: () throws -> Value) {
		do {
			self = .success(try f())
		} catch var error {
			if Error.self == AnyError.self {
				error = AnyError(error)
			}
			self = .failure(error as! Error)
		}
	}
	
	public func dematerialize() throws -> Value {
		switch self {
		case let .success(value):
			return value
		case let .failure(error):
			throw error
		}
	}
	
	public func analysis<PostalResult>(ifSuccess: (Value) -> PostalResult, ifFailure: (Error) -> PostalResult) -> PostalResult {
		switch self {
		case let .success(value):
			return ifSuccess(value)
		case let .failure(value):
			return ifFailure(value)
		}
	}
	
	public static var errorDomain: String { return "com.antitypical.PostalResult" }
	
	public static var functionKey: String { return "\(errorDomain).function" }
	
	public static var fileKey: String { return "\(errorDomain).file" }
	
	public static var lineKey: String { return "\(errorDomain).line" }
	
	public static func error(_ message: String? = nil, function: String = #function, file: String = #file, line: Int = #line) -> NSError {
		var userInfo: [String: Any] = [
			functionKey: function,
			fileKey: file,
			lineKey: line,
			]
		
		if let message = message {
			userInfo[NSLocalizedDescriptionKey] = message
		}
		
		return NSError(domain: errorDomain, code: 0, userInfo: userInfo)
	}
	
	public var description: String {
		switch self {
		case let .success(value): return ".success(\(value))"
		case let .failure(error): return ".failure(\(error))"
		}
	}
	
	
	public var debugDescription: String {
		return description
	}
	
	public var result: PostalResult<Value, Error> {
		return self
	}
}
