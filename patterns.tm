use ./patterns.c

struct PatternMatch(text:Text, index:Int, captures:[Text])

lang Replacement
    convert(text:Text -> Replacement)
        return Replacement.from_text(text.replace("@", "@@"))

lang Pat
    convert(text:Text -> Pat)
        return C_code:Pat`Pattern$escape_text(@text)`

    convert(n:Int -> Pat)
        return Pat.from_text("$n")

    func match(pattern:Pat, text:Text, pos:Int = 1 -> PatternMatch?)
        result : PatternMatch
        if C_code:Bool`Pattern$match_at(@text, @pattern, @pos, (void*)&@result)`
            return result
        return none

    func matches(pattern:Pat, text:Text -> Bool)
        return C_code:Bool`Pattern$matches(@text, @pattern)`

    func capture(pattern:Pat, text:Text -> [Text]?)
        return C_code:[Text]?`Pattern$captures(@text, @pattern)`

    func replace(pattern:Pat, text:Text, replacement:Text, backref="@", recursive=yes -> Text)
        return C_code:Text`Pattern$replace(@text, @pattern, @replacement, @backref, @recursive)`

    func translate(replacements:{Pat:Text}, text:Text, backref="@", recursive=yes -> Text)
        return C_code:Text`Pattern$replace_all(@text, @replacements, @backref, @recursive)`

    func is_in(pattern:Pat, text:Text -> Bool)
        return C_code:Bool`Pattern$has(@text, @pattern)`

    func find_in(pattern:Pat, text:Text -> [PatternMatch])
        return C_code:[PatternMatch]`Pattern$find_all(@text, @pattern)`

    func each_match(pattern:Pat, text:Text -> func(->PatternMatch?))
        return C_code:func(->PatternMatch?)`Pattern$by_match(@text, @pattern)`

    func for_each(pattern:Pat, text:Text, fn:func(m:PatternMatch), recursive=yes)
        C_code ` Pattern$each(@text, @pattern, @fn, @recursive); `

    func map(pattern:Pat, text:Text, fn:func(m:PatternMatch -> Text), recursive=yes -> Text)
        return C_code:Text`Pattern$map(@text, @pattern, @fn, @recursive)`

    func split(pattern:Pat, text:Text -> [Text])
        return C_code:[Text]`Pattern$split(@text, @pattern)`

    func by_split(pattern:Pat, text:Text -> func(->Text?))
        return C_code:func(->Text?)`Pattern$by_split(@text, @pattern)`

    func trim(pattern:Pat, text:Text, left=yes, right=yes -> Text)
        return C_code:Text`Pattern$trim(@text, @pattern, @left, @right)`


func main()
    pass
    # >> "Hello world".match($Pat'{id}')
    # >> "...Hello world".match($Pat'{id}')
# func main(pattern:Pat, input=(/dev/stdin))
#     for line in input.by_line()!
#         skip if not line.has_pattern(pattern)
#         pos := 1
#         for match in line.by_pattern(pattern)
#             say(line.slice(pos, match.index-1), newline=no)
#             say("\033[34;1m$(match.text)\033[m", newline=no)
#             pos = match.index + match.text.length
#         say(line.from(pos), newline=yes)
