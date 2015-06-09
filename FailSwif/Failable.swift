import Foundation

public enum Failable<T, E: ErrorType> {
    case Success(T)
    case Failure(E)
    
    public var value: T? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    public var error: E? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error_):
            return error_
        }
    }
    
    public func map<U>(transform: T -> U) -> Failable<U, E> {
        switch self {
        case .Success(let value):
            return .Success(transform(value))
        case .Failure(let error):
            return .Failure(error)
        }
    }
    
    public func flatMap<U>(transform: T -> Failable<U, E>) -> Failable<U, E> {
        switch self {
        case .Success(let value):
            return transform(value)
        case .Failure(let error):
            return .Failure(error)
        }
    }
}

extension Failable: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .Success(let value):
            return "Failable(\(value))"
        case .Failure(let error):
            return "Failable(\(error))"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

public func ??<T, E: ErrorType>(lhs: Failable<T, E>, @autoclosure rhs: () -> T) -> T {
    switch lhs {
    case .Success(let value):
        return value
    case .Failure:
        return rhs()
    }
}

public func ==<T, E: ErrorType where T: Equatable, E:Equatable> (lhs: Failable<T, E>, rhs: Failable<T, E>) -> Bool {
    if let result = (lhs.value.flatMap { l in rhs.value.flatMap { r in l == r } }) { return result }
    if let result = (lhs.error.flatMap { l in rhs.error.flatMap { r in l == r } }) { return result }
    return false
}
