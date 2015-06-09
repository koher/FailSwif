FailSwif
=============================

_FailSwif_ provides the `Failable` type for error handling, which is similar to `Either` except that the second value is restrected to `ErrorType`.

```swift
enum Failable<T, E: ErrorType> {
    case Success(T)
    case Failure(E)
}
```

`Failable` can be used instead of `Optional`.

```swift
let a: Failable<Int, ParseError> = toInt(label.text)

if let value = a.value {
    print(value)
}
```

`Failable` can contain some error information while `Optional` indicates just an error occurs.

```swift
switch a {
case .Success(let value):
    print(value)
case .Failure(.Nil):
    print("The text is nil.")
case .Failure(.IllegalFormat(let string)):
    print("Illegal format: \(string)")
}
```

`map`, `flatMap` and `??` are available for `Failable` as well as `Optional`.

```swift
let b = a.map { $0 * $0 }
let c = a.flatMap { a0 in b.flatMap { b0 in .Success(a0 + b0) } }
let d: Int = a ?? 0
```

`Failable` can work seamlessly with `try`, `throw` and `catch`.

```swift
func toInt(string: String?) -> Failable<Int, ParseError> {
    do {
        return .Success(try toIntThrowable(string))
    } catch let error as ParseError {
        return .Failure(error)
    }
}
```

## Requirements

- Swift 2.0 or later

## License

[The MIT License](LICENSE)
