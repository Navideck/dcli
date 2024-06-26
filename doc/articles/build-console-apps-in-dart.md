# build CLI apps in dart - part 1

> [Read part 2](https://medium.com/@bsutton.noojee/dshell-build-console-apps-in-dart-part-2-39719cb6d051)

DCli is a library and development environment for building console apps using Dart.

> DCli runs on Linux, MacOS and Windows.

Dart you say, what is this Dart thing?

Dart is a relatively new programming language from Google with a Java/JavaScript heritage with the bad bits taken out. Dart is becoming a mainstream language, if you are interested as to why, google flutter.

> If you are looking to learn Dart, DCli is an easy way to get started.

If you want to learn more about Dart, the Dart language tour is a great place to start:

[https://dart.dev/language](https://dart.dev/language)

But I digress, let’s get back to talking about DCli.

DCli was designed to make building CLI scripts and even whole CLI apps a joy.

So DCli starts with Dart and then adds a library of commands that mimic many of the operations of bash. This combination creates the perfect building blocks for a CLI script.

> Before we get started, a quick word about developing with Dart and specifically with DCli.\
> When developing scripts we often don’t have a GUI so an IDE isn’t always available. With that in mind DCli is a pure CLI application so you can easily develop DCli scripts using Vi or whatever other CLI editor you prefer. Having said that, I recommend using an IDE whenever it’s available. A debugger, syntax highlighting, auto complete and automatic insertion of import statements will seriously improve your productivity.\
> My recommendation for an IDE is Visual Code. It’s lightweight, supported by Google and does a nice job of getting the job done.\
> I’ve included a link at the bottom of this article regarding installing Visual Code.

But let’s dive in and look at some examples of DCli.

If you would like you can work through examples as we go by installing DCli.

Start by installing Dart:

[https://dart.dev/get-dart](https://dart.dev/get-dart)

Now install DCli:

```
dart pub global activate dcli
dcli install
```

You’re now ready to start developing with DCli.

Let’s have a look at an example DCli script.

hello\_world.dart

```dart
#! /usr/bin/env dcli
import 'package:dcli/dcli.dart';

void main() {
  print('Hello World');
}
```

To run the above script:

run hello\_world.dart

```bash
chmod +x hello_world.dart
./hello_world.dart
```

Note: if you are on Windows the 'chmod' command isn't required.

The first time you run a script, DCli needs to do some housekeeping. DCli (or in reality DArt) downloads any dependencies that your script requires.

Don’t worry about the start time of your script, the second time you run the script the start time will be much faster. If you need serious speed DCli can compile your script to a native executable. But more about that in part 2.

Let’s pull the code apart line by line.

Line 1 is called a ‘shebang’. It essentially tells your OS that the script is to be executed with DCli. You should include this in all your DCli scripts.&#x20;

Line 2 imports the dcli package making all of its yummy goodness available.

Line 4 is the entry point for the script.

Line 5: we print ‘hello world’

Rather than creating a script yourself let DCli do it for you.

Type: dcli create hellow.dart

```bash
dcli create hellow.dart
Creating project.
Running pub get...
Resolving dependencies...
+ args 1.5.2
+ charcode 1.1.2
+ collection 1.14.12
+ dcli 0.25
+ equatable 1.0.2
+ file 5.1.0
+ file_utils 0.1.4
+ globbing 0.3.0
+ intl 0.16.1
+ logger 0.8.2
+ matcher 0.12.6
+ meta 1.1.8
+ money2 1.3.0
+ path 1.6.4
+ pub_semver 1.4.2
+ pubspec 0.1.3
+ quiver 2.1.2+1
+ recase 3.0.0
+ source_span 1.5.5
+ stack_trace 1.9.3
+ string_scanner 1.0.5
+ term_glyph 1.1.0
+ uri 0.11.3+1
+ utf 0.9.0+5
+ yaml 2.2.0
Changed 25 dependencies!
Making script executable
Project creation complete.
To run your script:
   ./hellow.dart
```

>

The ‘dcli create’ command creates a sample ‘hello world’ dart script, does all the required housekeeping, and marks the script as executable.

{% hint style="info" %}
dcli ships with a number of starter templates that provide common starting points for writing scripts. Run 'dcli create help' for details.
{% endhint %}

## Calling external app <a href="#12db" id="12db"></a>

One of bash’s superpowers is that it can call any external application. Well so can DCLI.

```dart
#! /usr/bin/env dcli
import 'package:dcli/dcli.dart';

void main() {
  'grep error /var/log/syslog'.run;
}
```

Line 5 of the above example runs the grep command. Any output from grep is written directly to the console.

{% hint style="warning" %}
For Dart users, this code may look a little confusing. How do you run a String? DCli uses the Dart ‘extensions’ feature to extend the String class. In this case, we have added a ‘run’ property. Watch out for additional String overloads in the examples below.
{% endhint %}

## Using forEach <a href="#67dc" id="67dc"></a>

We can ‘run’ a command but how do we process the output? Simple, we use the ‘forEach’ method:

```dart
#! /usr/bin/env dcli
import 'package:dcli/dcli.dart';

void main() {
    'grep error /var/log/syslog'.forEach((line) => print(line));

  'grep error /var/log/syslog'.forEach((line) { print('matched $line'); });

  'grep error /var/log/syslog'.forEach((line) => print(line), stderr:(line) => print(red(line)));
}
```

{% hint style="info" %}
Dart supports anonymous functions (or more broadly lambda’s and closures) just as Javascript and Java do. The above forEach function takes a lambda.
{% endhint %}

In line 5, the lambda is the part:

```dart
(line) => print(line)
```

Essentially ‘(line)’ is an argument passed to the lambda. This is essentially the ‘method signature’ of the anonymous function. Each time grep outputs a line, the forEach method calls the above lambda.

The ‘line’ argument will contain the line output by grep to stdout.

The `=>` operator (sometimes referred to as a ‘fat arrow’) tells us that this lambda is expecting a single expression on the right-hand side of the `=>` operator. In this case, we pass the line argument to the print statement which prints the line to the console.

> In case you are not familiar with ‘stdout’ every CLI app has three file handles passed to it by the OS. stdin, stdout, and stderr. Stdin can be read and contains any data piped to the app, the Dart print command writes to stdout (which normally goes to the console) and stderr is where a CLI app should write any error messages to. Read the page on [stdout/stderr/stdin](../dart-basics/stdin-stdout-stderr.md) for more details.

Let's now compare line 5 to line 7.

Line 5: … .forEach((line) => print(line));

Line 7: … .forEach((line) { print(‘matched $line’); });

What we are seeing here are the two forms of a Dart lambda.

Line 5 uses the fat arrow which expects a single expression.

Line 7: drops the fat arrow in exchange for a statement block ‘{}’.

The advantage of the statement block is that you can include multiple statement  (each terminated by a semi-colon).

The second point of interest in line 7 is the use of ‘$line’ in the print statement. This is a Dart string interpolation feature. You can insert any variable into a string by preceding it with a ‘$’. You can in fact include any expression by encapsulating the expression with ${}. e.g. print('${line.substring(3)}').

Line 9 now gets a little more interesting:

```dart
… .forEach(
(line) => print(line)
    ,stderr:(line) => print(red(line)));
```

So what’s going on here? The first half of the line is recognizable from line 5, but what about the second half:

```dart
stderr:(line) => print(red(line))
```

Some of this makes sense:

```dart
(line) => print(red(line))
```

This looks just like the lambda we previously used to print lines to the console. You can probably guess that the call to ‘red(line)’ changes the colour of the line written to the console to red.

{% hint style="info" %}
dcli provides a number of functions for applying colour to text by using the ansi terminal escape sequences. DCLI also supports cursor positioning commands via the Terminal class.
{% endhint %}

But what is the ‘stderr:’ all about?

When you run a command like grep, it outputs any text to stdout, but if an error occurs it writes the error message to stderr. When we used the ‘.run’ method with grep, both stdout, and stderr are written to the console. But when we use forEach, as we did in Lines 5 and 7 we are only writing stdout to the console and essentially suppressing stderr (just like sending it to /dev/null).

Suppressing stderr is not such a good idea but often convenient so forEach lets us ignore stderr. If we want or need to process stderr then that’s where the ‘stderr:’ syntax comes in.

If you are a Dart programmer you will immediately realize that this is a named parameter. But for the non-Dart programmers let’s stop for a moment and explain named parameters.

> You can read more on Dart parameters in the above mentioned Dart language tour or in this blog article I wrote on choosing parameters:
>
> [https://onepub.dev/Blog?id=sppsdavuhn](https://onepub.dev/Blog?id=sppsdavuhn)

Dart functions and methods support three types of arguments.

Positional, optional, and named.

When declaring a named argument in a Dart method we use braces to designate it. So the signature of the forEach method is:

```dart
forEach(LineAction stdout, {LineAction? stderr});
```

> Dart types are 'null be default'. LineAction is a type which can never be null so you can't pass a null to the stdout argument. LineAction? is the same type but it may null so you can pass null to the stderr argument or just don't pass it and it will default to null.&#x20;

When calling a function with a named argument we use the name and a colon. e.g.

```dart
forEach((line) => print(line), stderr: (line) => print(line));
```

The first positional argument is:

```dart
(line) => print(line)
```

The second named argument is:

```dart
stderr: (line) => print(line)
```

The stderr named argument is optional which is why we could write Line 5 without mentioning stderr.

forEach is probably one of the most important methods in DCLI as we use it repeatedly to process lines of data.

## Let’s talk about piping. <a href="#0af9" id="0af9"></a>

Another great feature of bash is its ability to call multiple applications and ‘pipe’ the data from one application to the next. Well, we can do the same with DCLI.

```dart
(‘grep error /var/log/syslog’ | ‘head -n 5’ | ‘tail -n 1’.)forEach((line) 
    => print(‘The fifth error is: $line’);
```

The above line calls grep to find all the lines containing ‘error’, passes the results to the ‘head’ command which outputs just the first 5 lines, then tail outputs just the last line of those five, and finally we use Dart to print the fifth line.

> In reality I rarely use piping with DCLI as there are usually better ways with the Dart and DCLI libraries to achieve the same results.

## Built-in commands <a href="#f592" id="f592"></a>

DCli provides a Swiss army knife of built-in functions for building CLI scripts.

> For bash users; Dart supports top level functions just as bash does however unlike bash, the functions can be in any order. Dart also supports classes.

```dart
find('*.png', recursive: false).forEach((line) => print(line);
```

Find is one of the many built-in commands that ships with DCli. By default, find does a recursive search from the current directory but in this case, we only want to search the current directory so we pass the optional named argument ‘recursive’ with a value of false. Once again we see the forEach method in use to process each of the filenames returned by find.

Alternatively, we may want to store the found png files in a list. The DCli commands that support forEach also supports ‘toList’ so if we want to save the list of png files we can simply do:

```dart
var files = find('*.png').toList() ;
```

To create a directory we do:

```dart
createDir('/home/me/a/path/to/far', recursive: true);
```

The optional, named argument ‘recursive’ tells DCli to create any intermediate paths that don’t already exist.

To ask the user a question:

```dart
var answer = ask('Y/N');
```

To delete a file:

```dart
delete('notneeded.txt');
```

To move a file:

```dart
move('from path', 'to path');
```

To check if a file or directory exists:

```dart
if (exists('/home/does/it/exist')) {
    print('found it')
};
```

You can access and set environment variables with the ‘env’ function:

```dart
var username = env['USERNAME'];
env['password'] = 'a password';
```

DCli also directly exposes some environment variables such as:

```dart
HOME — your home directory

PATH — a String array containing the paths on your PATH.
```

## Paths, Paths and more Paths <a href="#3c23" id="3c23"></a>

When writing CLI scripts you tend to spend a lot of your time manipulating directory paths. Dart makes this easy through neat ‘path’ package.

To use the `path` package we need to add it as a dependency. When you create a DCLI script, DCLI automatically creates a 'pubspec.yaml' file which is used to hold the list of dependencies as well as other configuration details. `pubspec.yaml` is akin to C's make file or Nodes `package.json` file.

To add the `path` dependency to your pubspec.yaml run:

```
dart pub add path
```

To use the `path` package in a script we need to import it at the top of the dart file.

```
import 'package:path/path.dart';
```

The path package provides a set of global functions that allow you to create and manipulate directory paths.

Some of the most commonly used are:

```dart
import 'package:path/path.dart';

join('/home', 'my') == '/home/my'
canonicalize('/home/../home') == '/home'
absolute('test') == '/home/me/test'
basename('/home/fred.txt') == 'fred.txt'
dirname('/home/fred.txt') == '/home'
```

You can see additional details on the path package at:

{% embed url="https://pub.dev/packages/path" %}

### Packages, packages and more packages <a href="#489f" id="489f"></a>

One of DCLI's great strengths is how easy it is to extend DCLI. The Dart eco-system includes thousands of packages that provide all sorts of functions.&#x20;

{% embed url="https://pub.dev" %}

You can find a list of packages specifically designed for writing CLI scripts on the OnePub website:

[https://onepub.dev/search?searchProvider=Category\&category=develop.cli](https://onepub.dev/search?searchProvider=Category\&category=develop.cli)

## Accepting Arguments <a href="#90ae" id="90ae"></a>

To make your CLI script useful you will more than likely want to process arguments passed to your script. Dart is similar to C and Java in that its entry point is called ‘main’ and it takes an array of arguments.

```dart
#! /usr/bin/env dcli
import 'dart:io';
import 'package:dcli/dcli.dart';

void main(List<String> args) {
    
  print('${args.length} were passed');
  int index = 0;
  for (var arg in args)
  {
    print('arg $index = $arg);
  }
  exit(1);
}
```

Line 2 imports Dart’s io library so we can use the ‘exit’ function below.

Line 5 shows us the main entry point. The main method returns void which means we need to use the ‘exit’ function to return an exit code from the script.

Line 5 also declares that main takes a List of Strings called ‘args’. Dart supports Generics. I’ve provided some references at the bottom of this article on Dart and using Generics with Dart.

Line 7 prints the no. of arguments passed. Again we are using the Dart ‘$’ notation that lets us embed variables into a Dart String.

### Summary <a href="#404c" id="404c"></a>

There is a lot more to DCli but I think you can see by the above examples that DCli is a simple and expressive method of writing CLI scripts.

You should now have enough information to start writing basic CLI scripts using DCli.

Well, I think that’s enough for one day.

Part 2 will build a complete CLI app using DCli.

{% embed url="https://github.com/bsutton/dcli" %}

I’m also looking for collaborators or you could write your own article about DCli :)

Regards,

Brett

### [**Read part 2.**](https://medium.com/@bsutton.noojee/dshell-build-console-apps-in-dart-part-2-39719cb6d051) <a href="#7d34" id="7d34"></a>

References:

Dart packages: [https://pub.dev](https://pub.dev/packages/dshell)

Note you can NOT use packages designed for Flutter or Web.

DCli: [https://pub.dev/packages/dcli](https://pub.dev/packages/dshell)

DCli git repo: [https://github.com/onepub-dev/dcli](https://github.com/bsutton/dshell)

Path: [https://pub.dev/packages/path](https://pub.dev/packages/path)

Args: [https://pub.dev/packages/args](https://pub.dev/packages/args)

A great getting-started guide for dart

{% embed url="https://dart.dev/guides/language/language-tour" %}

An overview of Dart Generics.

Generics: [https://www.tutorialspoint.com/dart\_programming/dart\_programming\_generics.htm](https://www.tutorialspoint.com/dart\_programming/dart\_programming\_generics.htm)

Visual Code: links to installing visual code an installing the required extensions.

[https://dartcode.org/](https://dartcode.org/)

*
