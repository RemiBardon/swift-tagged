@dynamicMemberLookup
public struct Tagged<Tag, RawValue> {
  public var rawValue: RawValue

  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }

  public func map<B>(_ f: (RawValue) -> B) -> Tagged<Tag, B> {
    return .init(rawValue: f(self.rawValue))
  }
}

extension Tagged {
    public subscript<T>(dynamicMember keyPath: KeyPath<RawValue, T>) -> T {
        return self.rawValue[keyPath: keyPath]
    }
}

extension Tagged: CustomStringConvertible {
  public var description: String {
    return String(describing: self.rawValue)
  }
}

extension Tagged: RawRepresentable {}

extension Tagged: CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
    return self.rawValue
  }
}

// MARK: - Conditional Conformances

extension Tagged: Collection where RawValue: Collection {
  public typealias Element = RawValue.Element
  public typealias Index = RawValue.Index

  public func index(after i: RawValue.Index) -> RawValue.Index {
    return rawValue.index(after: i)
  }

  public subscript(position: RawValue.Index) -> RawValue.Element {
    return rawValue[position]
  }

  public var startIndex: RawValue.Index {
    return rawValue.startIndex
  }

  public var endIndex: RawValue.Index {
    return rawValue.endIndex
  }

  public __consuming func makeIterator() -> RawValue.Iterator {
    return rawValue.makeIterator()
  }
}

extension Tagged: Comparable where RawValue: Comparable {
  public static func < (lhs: Tagged, rhs: Tagged) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

extension Tagged: Decodable where RawValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      self.init(rawValue: try decoder.singleValueContainer().decode(RawValue.self))
    } catch {
      self.init(rawValue: try .init(from: decoder))
    }
  }
}

extension Tagged: Encodable where RawValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    do {
      var container = encoder.singleValueContainer()
      try container.encode(self.rawValue)
    } catch {
      try self.rawValue.encode(to: encoder)
    }
  }
}

extension Tagged: Equatable where RawValue: Equatable {}

extension Tagged: Error where RawValue: Error {}

#if canImport(_Concurrency) && compiler(>=5.5.2)
extension Tagged: Sendable where RawValue: Sendable {}
#endif

#if canImport(Foundation)
import Foundation
extension Tagged: LocalizedError where RawValue: Error {
  public var errorDescription: String? {
    return rawValue.localizedDescription
  }
  public var failureReason: String? {
    return (rawValue as? LocalizedError)?.failureReason
  }
  public var helpAnchor: String? {
    return (rawValue as? LocalizedError)?.helpAnchor
  }
  public var recoverySuggestion: String? {
    return (rawValue as? LocalizedError)?.recoverySuggestion
  }
}
#endif

extension Tagged: ExpressibleByBooleanLiteral where RawValue: ExpressibleByBooleanLiteral {
  public typealias BooleanLiteralType = RawValue.BooleanLiteralType

  public init(booleanLiteral value: RawValue.BooleanLiteralType) {
    self.init(rawValue: RawValue(booleanLiteral: value))
  }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType

  public init(extendedGraphemeClusterLiteral: ExtendedGraphemeClusterLiteralType) {
    self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: extendedGraphemeClusterLiteral))
  }
}

extension Tagged: ExpressibleByFloatLiteral where RawValue: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = RawValue.FloatLiteralType

  public init(floatLiteral: FloatLiteralType) {
    self.init(rawValue: RawValue(floatLiteral: floatLiteral))
  }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = RawValue.IntegerLiteralType

  public init(integerLiteral: IntegerLiteralType) {
    self.init(rawValue: RawValue(integerLiteral: integerLiteral))
  }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
  public typealias StringLiteralType = RawValue.StringLiteralType

  public init(stringLiteral: StringLiteralType) {
    self.init(rawValue: RawValue(stringLiteral: stringLiteral))
  }
}

extension Tagged: ExpressibleByStringInterpolation where RawValue: ExpressibleByStringInterpolation {
  public typealias StringInterpolation = RawValue.StringInterpolation

  public init(stringInterpolation: Self.StringInterpolation) {
    self.init(rawValue: RawValue(stringInterpolation: stringInterpolation))
  }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
  public typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType

  public init(unicodeScalarLiteral: UnicodeScalarLiteralType) {
    self.init(rawValue: RawValue(unicodeScalarLiteral: unicodeScalarLiteral))
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Tagged: Identifiable where RawValue: Identifiable {
  public typealias ID = RawValue.ID

  public var id: ID {
    return rawValue.id
  }
}

extension Tagged: LosslessStringConvertible where RawValue: LosslessStringConvertible {
  public init?(_ description: String) {
    guard let rawValue = RawValue(description) else { return nil }
    self.init(rawValue: rawValue)
  }
}

#if compiler(>=5)
extension Tagged: AdditiveArithmetic where RawValue: AdditiveArithmetic {
  public static var zero: Tagged {
    return self.init(rawValue: .zero)
  }

  public static func + (lhs: Tagged, rhs: Tagged) -> Tagged {
    return self.init(rawValue: lhs.rawValue + rhs.rawValue)
  }

  public static func += (lhs: inout Tagged, rhs: Tagged) {
    lhs.rawValue += rhs.rawValue
  }

  public static func - (lhs: Tagged, rhs: Tagged) -> Tagged {
    return self.init(rawValue: lhs.rawValue - rhs.rawValue)
  }

  public static func -= (lhs: inout Tagged, rhs: Tagged) {
    lhs.rawValue -= rhs.rawValue
  }
}

//extension Tagged: Numeric where RawValue: Numeric {
//  public init?<T>(exactly source: T) where T: BinaryInteger {
//    guard let rawValue = RawValue(exactly: source) else { return nil }
//    self.init(rawValue: rawValue)
//  }
//
//  public var magnitude: RawValue.Magnitude {
//    return self.rawValue.magnitude
//  }
//
//  public static func * (lhs: Tagged, rhs: Tagged) -> Tagged {
//    return self.init(rawValue: lhs.rawValue * rhs.rawValue)
//  }
//
//  public static func *= (lhs: inout Tagged, rhs: Tagged) {
//    lhs.rawValue *= rhs.rawValue
//  }
//}
//#else
//extension Tagged: Numeric where RawValue: Numeric {
//  public typealias Magnitude = RawValue.Magnitude
//
//  public init?<T>(exactly source: T) where T: BinaryInteger {
//    guard let rawValue = RawValue(exactly: source) else { return nil }
//    self.init(rawValue: rawValue)
//  }
//  public var magnitude: RawValue.Magnitude {
//    return self.rawValue.magnitude
//  }
//
//  public static func + (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
//    return self.init(rawValue: lhs.rawValue + rhs.rawValue)
//  }
//
//  public static func += (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
//    lhs.rawValue += rhs.rawValue
//  }
//
//  public static func * (lhs: Tagged, rhs: Tagged) -> Tagged {
//    return self.init(rawValue: lhs.rawValue * rhs.rawValue)
//  }
//
//  public static func *= (lhs: inout Tagged, rhs: Tagged) {
//    lhs.rawValue *= rhs.rawValue
//  }
//
//  public static func - (lhs: Tagged, rhs: Tagged) -> Tagged<Tag, RawValue> {
//    return self.init(rawValue: lhs.rawValue - rhs.rawValue)
//  }
//
//  public static func -= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
//    lhs.rawValue -= rhs.rawValue
//  }
//}
#endif

extension Tagged: Numeric, SignedNumeric, FloatingPoint where RawValue: FloatingPoint {
  public typealias Exponent = RawValue.Exponent
  public typealias Magnitude = Self

  public init?<T>(exactly source: T) where T: BinaryInteger {
    guard let rawValue = RawValue(exactly: source) else { return nil }
    self.init(rawValue: rawValue)
  }

  public static func * (lhs: Tagged, rhs: Tagged) -> Tagged {
    return self.init(rawValue: lhs.rawValue * rhs.rawValue)
  }

  public static func *= (lhs: inout Tagged, rhs: Tagged) {
    lhs.rawValue *= rhs.rawValue
  }

  public init(sign: FloatingPointSign, exponent: RawValue.Exponent, significand: Self) {
    self.init(rawValue: .init(sign: sign, exponent: exponent, significand: significand.rawValue))
  }

  public init(signOf: Self, magnitudeOf: Self) {
    self.init(rawValue: .init(signOf: signOf.rawValue, magnitudeOf: magnitudeOf.rawValue))
  }

  public init(_ value: Int) {
    self.init(rawValue: .init(value))
  }

  public init<Source>(_ value: Source) where Source: BinaryInteger {
    self.init(rawValue: .init(value))
  }

  public var magnitude: Self { Self.init(rawValue: self.rawValue.magnitude) }

  public static var radix: Int { Self.RawValue.radix }

  public static var nan: Self { Self.init(rawValue: .nan) }

  public static var signalingNaN: Self { Self.init(rawValue: .signalingNaN) }

  public static var infinity: Self { Self.init(rawValue: .infinity) }

  public static var greatestFiniteMagnitude: Self { Self.init(rawValue: .greatestFiniteMagnitude) }

  public static var pi: Self { Self.init(rawValue: .pi) }

  public var ulp: Self { Self.init(rawValue: self.rawValue.ulp) }

  public static var leastNormalMagnitude: Self { Self.init(rawValue: .leastNormalMagnitude) }

  public static var leastNonzeroMagnitude: Self { Self.init(rawValue: .leastNonzeroMagnitude) }

  public var sign: FloatingPointSign { self.rawValue.sign }

  public var exponent: RawValue.Exponent { self.rawValue.exponent }

  public var significand: Self { Self.init(rawValue: self.rawValue.significand) }

  public static func / (lhs: Self, rhs: Self) -> Self {
    Self.init(rawValue: lhs.rawValue / rhs.rawValue)
  }

  public static func /= (lhs: inout Self, rhs: Self) {
    lhs.rawValue /= rhs.rawValue
  }

  public mutating func formRemainder(dividingBy other: Self) {
    self.rawValue.formRemainder(dividingBy: other.rawValue)
  }

  public mutating func formTruncatingRemainder(dividingBy other: Self) {
    self.rawValue.formTruncatingRemainder(dividingBy: other.rawValue)
  }

  public mutating func formSquareRoot() {
    self.rawValue.formSquareRoot()
  }

  public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
    self.rawValue.addProduct(lhs.rawValue, rhs.rawValue)
  }

  public var nextUp: Self {
    Self.init(rawValue: self.rawValue.nextUp)
  }

  public func isEqual(to other: Self) -> Bool {
    self.rawValue.isEqual(to: other.rawValue)
  }

  public func isLess(than other: Self) -> Bool {
    self.rawValue.isLess(than: other.rawValue)
  }

  public func isLessThanOrEqualTo(_ other: Self) -> Bool {
    self.rawValue.isLessThanOrEqualTo(other.rawValue)
  }

  public func isTotallyOrdered(belowOrEqualTo other: Self) -> Bool {
    self.rawValue.isTotallyOrdered(belowOrEqualTo: other.rawValue)
  }

  public var isNormal: Bool { self.rawValue.isNormal }

  public var isFinite: Bool { self.rawValue.isFinite }

  public var isZero: Bool { self.rawValue.isZero }

  public var isSubnormal: Bool { self.rawValue.isSubnormal }

  public var isInfinite: Bool { self.rawValue.isInfinite }

  public var isNaN: Bool { self.rawValue.isNaN }

  public var isSignalingNaN: Bool { self.rawValue.isSignalingNaN }

  public var isCanonical: Bool { self.rawValue.isCanonical }

  public mutating func round(_ rule: FloatingPointRoundingRule) {
    self.rawValue.round(rule)
  }
}

extension Tagged: BinaryFloatingPoint where RawValue: BinaryFloatingPoint {
  public typealias RawSignificand = RawValue.RawSignificand
  public typealias RawExponent = RawValue.RawExponent

  public init(
    sign: FloatingPointSign,
    exponentBitPattern: RawExponent,
    significandBitPattern: RawSignificand
  ) {
    self.init(rawValue: .init(
      sign: sign,
      exponentBitPattern: exponentBitPattern,
      significandBitPattern: significandBitPattern
    ))
  }

  public static var exponentBitCount: Int { RawValue.exponentBitCount }

  public static var significandBitCount: Int { RawValue.significandBitCount }

  public var exponentBitPattern: RawExponent {
    self.rawValue.exponentBitPattern
  }

  public var significandBitPattern: RawSignificand {
    self.rawValue.significandBitPattern
  }

  public var binade: Self {
    Self.init(rawValue: self.rawValue.binade)
  }

  public var significandWidth: Int {
    self.rawValue.significandWidth
  }
}

extension Tagged: Hashable where RawValue: Hashable {}

//extension Tagged: SignedNumeric where RawValue: FixedWidthInteger {}

extension Tagged: Sequence where RawValue: Sequence {
  public typealias Iterator = RawValue.Iterator

  public __consuming func makeIterator() -> RawValue.Iterator {
    return rawValue.makeIterator()
  }
}

extension Tagged: Strideable where RawValue: Strideable {
  public typealias Stride = RawValue.Stride

  public func distance(to other: Tagged<Tag, RawValue>) -> RawValue.Stride {
    self.rawValue.distance(to: other.rawValue)
  }

  public func advanced(by n: RawValue.Stride) -> Tagged<Tag, RawValue> {
    Tagged(rawValue: self.rawValue.advanced(by: n))
  }
}

extension Tagged: ExpressibleByArrayLiteral where RawValue: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = RawValue.ArrayLiteralElement

  public init(arrayLiteral elements: ArrayLiteralElement...) {
    let f = unsafeBitCast(
      RawValue.init(arrayLiteral:) as (ArrayLiteralElement...) -> RawValue,
      to: (([ArrayLiteralElement]) -> RawValue).self
    )

    self.init(rawValue: f(elements))
  }
}

extension Tagged: ExpressibleByDictionaryLiteral where RawValue: ExpressibleByDictionaryLiteral {
  public typealias Key = RawValue.Key
  public typealias Value = RawValue.Value

  public init(dictionaryLiteral elements: (Key, Value)...) {
    let f = unsafeBitCast(
      RawValue.init(dictionaryLiteral:) as ((Key, Value)...) -> RawValue,
      to: (([(Key, Value)]) -> RawValue).self
    )

    self.init(rawValue: f(elements))
  }
}

// MARK: - Coerce
extension Tagged {
  public func coerced<Tag2>(to type: Tag2.Type) -> Tagged<Tag2, RawValue> {
    return unsafeBitCast(self, to: Tagged<Tag2, RawValue>.self)
  }
}
