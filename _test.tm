use ./patterns.tm

func main()
	amelie := "Am\{UE9}lie"
	amelie2 := "Am\{U65}\{U301}lie"
	>> $Pat"e".replace_in("Hello", "X")
	= "HXllo"

	>> $Pat"l".is_in("Hello")
	= yes
	>> $Pat"l{end}".is_in("Hello")
	= no
	>> $Pat"{start}l".is_in("Hello")
	= no

	>> $Pat"o".is_in("Hello")
	= yes
	>> $Pat"o{end}".is_in("Hello")
	= yes
	>> $Pat"{start}o".is_in("Hello")
	= no

	>> $Pat"H".is_in("Hello")
	= yes
	>> $Pat"H{end}".is_in("Hello")
	= no
	>> $Pat"{start}H".is_in("Hello")
	= yes

	>> $Pat"l".replace_in("Hello", "")
	= "Heo"
	>> $Pat"x".replace_in("xxxx", "")
	= ""
	>> $Pat"y".replace_in("xxxx", "")
	= "xxxx"
	>> $Pat"e ".replace_in("One two three four five six", "")
	= "Ontwo threfour fivsix"

	>> $Pat"{start}{space}".replace_in(" one ", "")
	= "one "
	>> $Pat"{space}{end}".replace_in(" one ", "")
	= " one"

	>> amelie.has_pattern($Pat"$amelie2")
	= yes

	>> $Pat"{alpha}".replace_in("one two three", "")
	= "  "
	>> $Pat"{alpha}".replace_in("one two three", "word")
	= "word word word"

	say("Test splitting and joining text:")

	>> "one two three".split_pattern($Pat" ")
	= ["one", "two", "three"]

	>> "one,two,three,".split_pattern($Pat",")
	= ["one", "two", "three", ""]

	>> "one    two three".split_pattern($Pat"{space}")
	= ["one", "two", "three"]

	>> "abc".split_pattern($Pat"")
	= ["a", "b", "c"]

	>> ", ".join(["one", "two", "three"])
	= "one, two, three"

	>> "".join(["one", "two", "three"])
	= "onetwothree"

	>> "+".join(["one"])
	= "one"

	>> "+".join([])
	= ""

	say("Test text.find_patterns()")
	>> " #one  #two #three   ".find_patterns($Pat"#{alpha}")
	= [PatternMatch(text="#one", index=2, captures=["one"]), PatternMatch(text="#two", index=8, captures=["two"]), PatternMatch(text="#three", index=13, captures=["three"])]

	>> " #one  #two #three   ".find_patterns($Pat"#{!space}")
	= [PatternMatch(text="#one", index=2, captures=["one"]), PatternMatch(text="#two", index=8, captures=["two"]), PatternMatch(text="#three", index=13, captures=["three"])]

	>> "    ".find_patterns($Pat"{alpha}")
	= []

	>> " foo(baz(), 1)  doop() ".find_patterns($Pat"{id}(?)")
	= [PatternMatch(text="foo(baz(), 1)", index=2, captures=["foo", "baz(), 1"]), PatternMatch(text="doop()", index=17, captures=["doop", ""])]

	>> "".find_patterns($Pat'')
	= []

	>> "Hello".find_patterns($Pat'')
	= []

	say("Test text slicing:")
	>> "abcdef".slice()
	= "abcdef"
	>> "abcdef".slice(from=3)
	= "cdef"
	>> "abcdef".slice(to=-2)
	= "abcde"
	>> "abcdef".slice(from=2, to=4)
	= "bcd"
	>> "abcdef".slice(from=5, to=1)
	= ""

	>> house := "家"
	= "家"
	>> house.length
	= 1
	>> house.codepoint_names()
	= ["CJK Unified Ideographs-5BB6"]
	>> house.utf32_codepoints()
	= [23478]

	>> "🐧".codepoint_names()
	= ["PENGUIN"]

	>> Text.from_codepoint_names(["not a valid name here buddy"])
	= none

	>> "one two; three four".find_patterns($Pat"; {..}")
	= [PatternMatch(text="; three four", index=8, captures=["three four"])]

	malicious := "{xxx}"
	>> $Pat"$malicious"
	= $Pat"{1{}xxx}"

	>> $Pat"{lower}".replace_in("Hello", "(@0)")
	= "H(ello)"

	>> $Pat"foo(?)".replace_in(" foo(xyz) foo(yyy) foo(z()) ", "baz(@1)")
	= " baz(xyz) baz(yyy) baz(z()) "

	>> "<tag>".translate_patterns({$Pat"<"="&lt;", $Pat">"="&gt;"})
	= "&lt;tag&gt;"

	>> $Pat"BAD(?)", "good(@1)".replace_in(" BAD(x, fn(y), BAD(z), w) ", recursive=yes)
	= " good(x, fn(y), good(z), w) "

	>> $Pat"BAD(?)", "good(@1)".replace_in(" BAD(x, fn(y), BAD(z), w) ", recursive=no)
	= " good(x, fn(y), BAD(z), w) "

	>> "Hello".matches_pattern($Pat"{id}")
	= yes
	>> "Hello".matches_pattern($Pat"{lower}")
	= no
	>> "Hello".matches_pattern($Pat"{upper}")
	= no
	>> "Hello...".matches_pattern($Pat"{id}")
	= no

	>> "hello world".map_pattern($Pat"world", func(m:PatternMatch) m.text.upper())
	= "hello WORLD"

	>> "Abc".repeat(3)
	= "AbcAbcAbc"

	>> $Pat"{space}".trim("   abc def    ")
	= "abc def"
	>> $Pat"{!digit}".trim(" abc123def ")
	= "123"
	>> $Pat"{!digit}".trim(" abc123def ", left=no)
	= " abc123"
	>> $Pat"{!digit}".trim(" abc123def ", right=no)
	= "123def "
	# Only trim single whole matches that bookend the text:
	>> $Pat"Abc".trim("AbcAbcxxxxxxxxAbcAbc")
	= "AbcxxxxxxxxAbc"

	>> $Pat"{..}={..}".replace_in("A=B=C=D", "1:(@1) 2:(@2)")
	= "1:(A) 2:(B=C=D)"

