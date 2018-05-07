let meCardEscapedCharacter = sequence(
    character(expected: meCardEscapingPrefix),
    character(expected: meCardSpecialCharacters)
) >>- { tuple in result(tuple.1) }


let meCardFieldName = oneOrMore(plus(
    meCardEscapedCharacter,
    character(otherwise: meCardSpecialCharacters)
))


let meCardFieldValue = oneOrMore(plus(
    meCardEscapedCharacter,
    character(otherwise: meCardSpecialCharacters)
))


let meCardField = sequence(
    meCardFieldName,
    sequence(
        character(expected: separator),
        sequence(
            meCardFieldValue,
            character(expected: terminator)
        )
    )
) >>- { tuple -> Parser<(String, String)> in
    let (name, (_, (value, _))) = tuple
    return result((String(name), String(value)))
}


let meCardFields = many(meCardField) >>- { fields -> Parser<[String: String]> in
    return result(Dictionary<String, String>(uniqueKeysWithValues: fields))
}
