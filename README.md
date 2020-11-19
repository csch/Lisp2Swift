# L2S - A (clojure-like) Lisp to Swift Transcoder

## Project Status: Experimental (1% finished)

To be clear, this is a hobby project/experiment with currently zero plans to bring this to
any state where you could write elaborate lisp programs and transcode it to Swift.

### "OK, but what exactly CAN you do with it?"

The following program compiles to Swift 5 and is runnable as a standalone Swift program (a script).
The used expressions below are pretty much what this project can do at the moment :)
There is no concept of an iOS or Mac app in this project.

guessing-game.l2s:

```
(defn guessing-game [randomnum]
  (let [guessed (readline)]
    (if (== guessed randomnum)
      (print "Nice one, you got it.")
      (do
	(print "Nope, try again!")
	(guessing-game randomnum)))))

(print "Guess the number I have in mind [0-9]")
(guessing-game (str (random 0 9)))
```

### "Sweet, how can I run this?"
```
git clone URL-HERE/Lisp2Swift
cd Lisp2Swift
-- TODO: copy executable --
./l2sr.sh -f guessing-game.l2s


### Command line scripts ###
```
./l2sc.sh '(print "hello")' // Compiles into Swift and prints it to the console
./l2sc.sh -f MyLisp.l2s     // Same as above but reads l2s from file
./l2sr.sh -f MyLisp.l2s     // Compiles into Swift and pipes to a swift file, then runs this via `swift` command
```


### Implemented functions ### // TODO: make table
- `==`: Wrapped, Returns true if numbers are equal or strings are equal (returns false for "1" == 1)
- `str`: Wrapped, Returns a string if it's a number otherwise returns the argument
- `print`: Non-wrapping, calls `print(...)` but only supports one argument
- `readline`: Non-wrapping, calls `readline()`


### What could be done next? ###
0. Comments! Currently any ;;; would result in an error
1. Use `dashed-variable` names, also errors out because Swift doesn't compile `dashed-vars`
2. All of the functions above are provided as Swift wrapper functions that are injected into every transcoded program.
This is obviously a major headache if everything you want to use from Swift has to be provided as a Swift-wrapper.
To fix this it would be cool to use Clojure's `.` approach and call any Swift functionality like so:
```(print (str (. Int max)))```
3. Eval.swift uses a global variable (map) for `declaredFunctions`. Because of this you could get issues with unit tests at the moment because they would change each other's state. This should be refactored and passed in as `Scope`.
4. `true`, `false` are unknown symbols so far
...