import Foundation


func createSubstring(from character: Character) -> Substring {
    return Substring(repeating: character, count: 1)
}


func cons(_ first: Character, _ rest: Substring) -> Substring {
    return createSubstring(from: first) + rest
}


func cons(_ prefix: Substring, _ rest: Substring) -> Substring {
    return prefix + rest
}


func cons<A>(_ first: A, _ rest: [A]) -> [A] {
    return [first] + rest
}


func uncons(_ input: Substring) -> (Character, Substring)? {
    guard let first = input.first else {
        return nil
    }

    return (first, input.suffix(from: input.index(after: input.startIndex)))
}


func concat(_ x: Character, _ y: Character) -> Substring {
    return createSubstring(from: x) + createSubstring(from: y)
}


func concat(_ x: Substring, _ y: Substring) -> Substring {
    return x + y
}


typealias Parser<A> = (Substring) -> [(A, Substring)]


let success = result(Substring(""))


func result<A>(_ value: A) -> Parser<A> {
    return { (input: Substring) in [(value, input)] }
}


func empty<A>(_ input: Substring) -> [(A, Substring)] {
    return []
}


func anyCharacter(_ input: Substring) -> [(Character, Substring)] {
    guard let (first, rest) = uncons(input) else {
        return []
    }

    return [(first, rest)]
}


precedencegroup MonadPrecedenceLeft {
    associativity: left
    higherThan: DefaultPrecedence
}


infix operator >>-: MonadPrecedenceLeft


func >>-<A, B>(_ p: @escaping Parser<A>, _ f: @escaping (A) -> Parser<B>) -> Parser<B> {
    return { (input) in
        return p(input).flatMap { tuple -> [(B, Substring)] in
            let (v, inputV) = tuple
            let q = f(v)
            return q(inputV)
        }
    }
}


func sequence<A, B>(_ p: @escaping Parser<A>, _ q: @escaping Parser<B>) -> Parser<(A, B)> {
    return p >>- { (x) in q >>- { (y) in  result((x, y)) } }
}


func character(when p: @escaping (Character) -> Bool) -> Parser<Character> {
    return anyCharacter >>- { (x: Character) in
        return p(x) ? result(x) : empty
    }
}


func character(expected: Character) -> Parser<Character> {
    return character { (x) in expected == x }
}


func character(otherwise: Character) -> Parser<Character> {
    return character { (x) in otherwise != x }
}


func character(expected: Set<Character>) -> Parser<Character> {
    return character { (x) in expected.contains(x) }
}


func character(otherwise: Set<Character>) -> Parser<Character> {
    return character { (x) in !otherwise.contains(x) }
}


func +<A>(_ p: @escaping Parser<A>, _ q: @escaping Parser<A>) -> Parser<A> {
    return plus(p, q)
}


func plus<A>(_ p: @escaping Parser<A>, _ q: @escaping Parser<A>) -> Parser<A> {
    return { (input) in p(input) + q(input) }
}


func string(expected: Substring) -> Parser<Substring> {
    guard let (first, rest) = uncons(expected) else {
        return success
    }

    return character(expected: first) >>- { _ -> Parser<Substring> in
        return string(expected: rest) >>- { _ -> Parser<Substring> in
            return result(cons(first, rest))
        }
    }
}


func string(expected: String) -> Parser<Substring> {
    return string(expected: Substring(expected))
}


func many(_ p: @escaping Parser<Character>) -> Parser<Substring> {
    return plus(
        p >>- { (first) in many(p) >>- { (rest) in result(cons(first, rest)) } },
        success
    )
}


func many(_ p: @escaping Parser<Substring>) -> Parser<Substring> {
    return plus(
        p >>- { (prefix) in many(p) >>- { (rest) in result(cons(prefix, rest)) } },
        success
    )
}


func many<A>(_ p: @escaping Parser<A>) -> Parser<[A]> {
    return plus(
        p >>- { (first) in many(p) >>- { (rest) in result(cons(first, rest))}},
        result([])
    )
}


func oneOrMore(_ p: @escaping Parser<Character>) -> Parser<Substring> {
    return p >>- { (prefix) in many(p) >>- { (rest) in result(cons(prefix, rest)) } }
}


func oneOrMore(_ p: @escaping Parser<Substring>) -> Parser<Substring> {
    return p >>- { (prefix) in many(p) >>- { (rest) in result(cons(prefix, rest)) } }
}


func oneOrMore<A>(_ p: @escaping Parser<A>) -> Parser<[A]> {
    return p >>- { (prefix) in many(p) >>- { (rest) in result(cons(prefix, rest)) } }
}
