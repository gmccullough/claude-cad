# OpenSCAD User Manual: String Functions

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/String_Functions](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/String_Functions)

## str

Convert all arguments to strings and concatenate.

**Usage examples:**

```openscad
number=2;
echo ("This is ",number,3," and that's it.");
echo (str("This is ",number,3," and that's it."));
```

**Results:**

```
ECHO: "This is ", 2, 3, " and that's it."
ECHO: "This is 23 and that's it."
```

This can be used for simple conversion of numbers to strings:

```openscad
s = str(n);
```

## chr

*(Requires version 2015.03)*

Convert numbers to a string containing character with the corresponding code. OpenSCAD uses Unicode, so the number is interpreted as Unicode code point. Numbers outside the valid code point range produce an empty string.

**Parameters:**

| Form | Description |
|------|-------------|
| `chr(Number)` | Convert one code point to a string of length 1 (number of bytes depending on UTF-8 encoding) if the code point is valid. |
| `chr(Vector)` | Convert all code points given in the argument vector to a string. |
| `chr(Range)` | Convert all code points produced by the range argument to a string. |

**Examples:**

```openscad
echo(chr(65), chr(97));      // ECHO: "A", "a"
echo(chr(65, 97));           // ECHO: "Aa"
echo(chr([66, 98]));         // ECHO: "Bb"
echo(chr([97 : 2 : 102]));   // ECHO: "ace"
echo(chr(-3));               // ECHO: ""
echo(chr(9786), chr(9788));  // ECHO: "\u263a", "\u263c"
echo(len(chr(9788)));        // ECHO: 1
```

Note: When used with `echo()` the output to the console for character codes greater than 127 is platform dependent.

## ord

*(Requires version 2019.05)*

Convert a character to a number representing the Unicode code point. If the parameter is not a string, `ord()` returns `undef`.

**Parameters:**

| Form | Description |
|------|-------------|
| `ord(String)` | Convert the first character of the given string to a Unicode code point. |

**Examples:**

```openscad
echo(ord("a"));
// ECHO: 97

echo(ord("BCD"));
// ECHO: 66

echo([for (c = "Hello! ") ord(c)]);
// ECHO: [72, 101, 108, 108, 111, 33, 32, 128578]

txt="1";
echo(ord(txt)-48,txt);
// ECHO: 1,"1" // only converts 1 character
```

## len

Returns the number of characters in a text.

```openscad
echo(len("Hello world"));    // 11
```

## search()

See `search()` for text searching.

## is_string(value)

The function `is_string(value)` returns `true` if the value is a string, `false` otherwise.

```openscad
echo(is_string("alpha")); //true
echo(is_string(22)); //false
```

## User Defined Functions

To complement native functions, you can define your own functions. Some suggestions:

```openscad
//-- Lower case all chars of a string -- does not work with accented characters
function strtolower (string) =
  chr([for(s=string) let(c=ord(s)) c<91 && c>64 ?c+32:c]);

//-- Replace char (not string) in a string
function char_replace (s,old=" ",new="_") =
  chr([for(i=[0:len(s)-1]) s[i]==old?ord(new):ord(s[i])]);

//-- Replace last chars of a string (can be used for file extension replacement of same length)
function str_rep_last (s,new=".txt") =
  str(chr([for(i=[0 :len(s)-len(new)-1])ord(s[i])]),new);

//-- Integer value from string
// Parameters ret and i are for function internal use (recursion)
function strtoint (s, ret=0, i=0) =
  i >= len(s)
  ? ret
  : strtoint(s, ret*10 + ord(s[i]) - ord("0"), i+1);
```

Note the use of `chr()` to recompose a string from an unknown number of characters defined by their ASCII code. This avoids using recursive modules as was required before list management came in.
