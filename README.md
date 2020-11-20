# L2S - A (clojure-like) Lisp to Swift Transcoder

### Project Status: Experimental (1% finished)

To be clear, this is a hobby project that I started to learn about clojure and writing a lisp parser. Currently there are zero plans to bring this to any state where you could write elaborate lisp programs and transcode them to Swift.

### "Right, so what exactly can you do with those 1%?"
These [unit tests](Lisp2SwiftTests/Lisp2SwiftTests.swift) will give you an idea what's covered so far.
The following program compiles to Swift 5 and is runnable as a standalone Swift program (in form of a script).
It pretty much summarises what this project can do at the moment and there really isn't much more that is possible.
Also there is no concept of an iOS or Mac app in this project.

[guessing-game.l2s](guessing-game.l2s):

```
(defn guessing-game [randomnum]
  (let [guessed (readline)]
    (if (== guessed randomnum)
      (print "Nice one, you got it!")
      (do
        (print "Nope, try again!")
        (guessing-game randomnum)))))

(print "Guess the number I have in mind [0-9]")
(guessing-game (str (random 0 9)))
```

### "Sweet, how can I run this "Guessing Game"?"
```
git clone https://github.com/csch/Lisp2Swift.git
cd Lisp2Swift
./build.sh
./l2sr.sh -f guessing-game.l2s

```

### Command line scripts ###
```
./l2sc.sh '(print "hello")'      # Compiles into Swift and prints it to console
./l2sc.sh -f guessing-game.l2s   # Same as above but reads from a file

./l2sr.sh '(print "hello")'      # Compiles into Swift and runs it
./l2sr.sh -f guessing-game.l2s   # Same as above but reads from a file
```

### Available L2S functions ###
There's not much here yet :)

| Function   | Description | 
| :---------- | :---------- | 
|  `+`        | Only allows adding two arguments of type `Int` or `Double` | 
|  `==`       | Returns `true` if numbers or strings are equal (returns `false` for `"1" == 1`) | 
|  `str`      | Returns a string if it's an `Int` or `Double` otherwise returns the argument | 
|  `print `   | Whatever Swift does but only allows one argument | 
| `readline`  | Calls Swift's `readline()` |
| `random`    | Takes two arguments `a, b`of type `Int` and returns an `Int` where `a..<b` |


### What could be done next? ###
0. Comments! Currently any `;;;` would result in an error :(
1. Use `dashed-variable` names, also errors out because Swift doesn't compile `dashed-vars` (utilise/rename `sanitiseFunction()`)
2. All of the functions above are provided as Swift wrapper functions that are injected into every transcoded program.
This is obviously a major headache if everything you want to use from Swift has to be provided as a Swift-wrapper.
To fix this it would be cool to use Clojure's `.` approach and call any Swift functionality like so:
```
(print (str (. Int max)))
```
3. `true`, `false` are unknown symbols so far
4. Enable/improve operator handling
5. Implement vectors to be used as constants and arguments
...