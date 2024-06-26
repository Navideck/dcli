# build CLI apps in dart - part 2

In [part 1](https://medium.com/@bsutton.noojee/dshell-build-console-apps-in-dart-a2d8b76b13be), we took a whirlwind tour of DCli.

In part 2, let’s take some of those pieces and build an app or two.

Before we move forward just a couple of thoughts and some answers to some of the questions I received after part one.

After my initial article the first question was; what magic is DCli doing and how does that magic affect what I can do with Dart?

The answer is very little.

{% hint style="info" %}
DCli allows you to use any Dart feature that is supported in a console app
{% endhint %}

The second question is, why doesn’t DCli use futures?

The answer is that DCli does use futures and you too can use futures in a DCli script.

The longer answer is; that in a CLI script, futures are a pain and for most requirements don’t provide any advantage. DCli goes to considerable lengths to shield you from having to use futures so unless you are doing something tricky; stay away from them.

With that done let’s get back to building our first app.

> You can see some additional sample apps in the [example's](../examples/overview/) section of this manual.

Every Linux system ships with the ‘**which**’ command. The ‘which’ command is used to find which directory an application is run from.

For example, if you type:

```
which grep
```

‘Which’ will report:

```
/bin/grep
```

‘Which’ searches each directory in your PATH until it finds the one containing the grep command.

Our version of ‘which’, called **dwhich**, searches for the command and validates each path as it goes. We are also going to include a verbose flag to print progress messages.

Start by creating a DCli script:

```
dcli create dwhich.dart
```

To make life easier we are going to use a couple of helper packages, `args` for parsing command line arguments and `path` for manipulating directory paths. So we first need to add these two packages as dependencies. From the command line (in the `dwhich` directory that dcli just created run:

```
dart pub add args
dart pub add path
```

Now copy the below contents into your dwhich.dart script.

```
#! /usr/bin/env dcli
import 'dart:io';
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// dwhich appname - searches for 'appname' on the path
void main(List<String> args) {
  var parser = ArgParser();
  parser.addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false);

  var results = parser.parse(args);

  var verbose = results['verbose'] as bool;

  if (results.rest.length != 1) {
    print(red('You must pass the name of the executable to search for.'));
    print(green('Usage:'));
    print(green('   which ${parser.usage}<exe>'));
    exit(1);
  }

  var command = results.rest[0];

  for (var path in PATH) {
    if (verbose) {
      print('Searching: ${truepath(path)}');
    }
    if (!exists(path))
    {
	printerr(red('The path $path does not exist.'));
 	continue;
    }
    if (exists(join(path, command))) {
      print(red('Found at: ${truepath(path, command)}'));
    }
  }
}
```

Given our requirements we need to pass two arguments to dwhich:

```
dwhich [-v] <appname>
```

The -v flag is optional and \<appname> is the name of the application we are going to search the path for.

To make processing the command line arguments easy we are going to use the ArgParser class from the ‘[args](https://pub.dev/packages/args)’ package that we added as a dependency.

So let’s break things down.

Line 7 we create an instance of the ArgParser

Line 8 we tell the ArgParser that we can accept an optional flag on the command line. The user can either type ‘ —verbose’ or ‘-v’ to cause ‘dwhich’ to output verbose details.

Line 10 parses the command args and gives us the results.

Line 12 extracts the ‘verbose’ flag from the results map and converts it to a bool.

Line 14 checks ‘results.rest’ to see if the expected `appname` argument was passed. The `appname` is stored in ‘results.rest’ which is a simple String list containing all of the arguments passed to main(), after the verbose switch was removed.

Line 22 takes the first argument from ‘result.rest’ which contains the name of the application that the user wants to search for and stores it into the variable ‘command’.

Line 23 uses DCli's ‘PATH’ global variable to loop through all of the paths in the OS’ PATH environment variable. DCli conveniently converts the PATH environment variable to a List\<String> containing each of the paths.

Line 27 validates that each path included in PATH is valid and prints an error if it isn’t. Here we use ‘printerr’ rather than ‘print’. ‘printerr’ writes to stderr whilst ‘print’ writes to stdout.

> You should always use printerr to print error messages.

Line 32 uses the ‘join’ function from the ‘path’ package to create a path by joining the current ‘path’ and the ‘command’ and then tests if the command exists at that path.

Line 33: print a message when we find the command. Note the use of the function ‘truepath’. Truepath is a convenience function provided by DCli. Truepath combines three operations into one. The following two lines give the same result:

```
/// if your current working directory is /home/me/dwhich’;
truepath(‘apps’, bin’, ‘..’, ‘dart); == ‘/home/me/dwhich/apps/dart’
canonicalize(absolute(join(‘apps’, bin’, ‘..’, ‘dart));
```

So why do we need to do all of that?

Line 33 prints the command's path for the user. To make the user's life easier you should always print an absolute path. It is no end of frustration for a user to read an error message that mentions a path but only gives a relative path. Whilst sometimes it will be obvious what path the file is relative to, often it’s not. So good practice is to always print an absolute path.

The canonicalize call is for safety. Hackers have often used THIS ONE TRICK (sorry) to break out of sandboxes.

Where does the following path point to?

```
/home/me/../../usr
```

When canonicalized, the above path reduced to:

```
/usr
```

So by canonicalizing the path we make it easier to read and if your code is checking for a prefix of /home (thinking that’s safe) then the call to canonicalize will show your code that the path isn’t actually safe.

So use truepath whenever you show a user a path or when you need to validate a path.

So we now have a ‘dwhich’ command and it was surprisingly simple to implement.

Let’s try and run it. If you created the script using ‘dcli create’ the script is ready to run:

```
./dwhich.dart grep
```

or

```
./dwhich.dart -v grep
```

If you created the script by hand then you must first mark it as executable (not required on Windows):

```
chmod +x dwhich.dart
./dwhich.dart grep
```

Remember that the first time you run your script, DCli needs to do some housekeeping!

## Make it go faster <a href="#6a03" id="6a03"></a>

Let’s make our dwhich command go faster by compiling it.

Run

```
dcli compile dwhich.dart
```

This will output an executable called ‘dwhich’.

Let’s run our new executable:

```
./dwhich
```

Notice how much faster the compiled ‘dwhich’ starts.

## Install and copy to other servers <a href="#fb70" id="fb70"></a>

We can also install our dwhich command into the OS PATH by passing the ‘—install’ flag to the compile command.

```
dcli compile — install dwhich.dart
```

DCli will copy the resulting executable to the \~/.dcli/bin directory which was added to your path when you installed DCli.

You can now run dwhich as:

dwhich grep

**But wait there’s more;**

Now that we have compiled our ‘dwhich’ command we have a single file executable.

When DCli compiles a script it includes all of the script's dependencies and a minimal Dart runtime. A compiled DCli script is typically about 8MB in size.

**But wait there’s even more….**

Now we have a compiled executable we can copy just the executable to any binary-compatible machine and run it (linux -> linux, windows->windows). There is no need to install Dart nor DCli on the target machine.

Hopefully, you are now starting to get a feel for how the pieces of DCli fit together.

Let’s build one more app before we finish up.

## duntar.dart <a href="#7f15" id="7f15"></a>

I don’t know about you, but I often have to untar a file or a .tar.gz file and I can never remember the correct set of switches to get the correct result.

So I built a little script that remembers for me; after all isn’t that what scripting is all about?

```
#! /usr/bin/env dcli
import 'dart:io';
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

/// duntar <tarfile>
/// untars a file
void main(List<String> args) {
  var parser = ArgParser();
  var results = parser.parse(args);

  if (results.rest.length != 1)
  {
    print('untars a .tar or .tar.gz file');
    print('');
    printerr(red('You must provide the name of the file to untar'));
    print('The file will be untared in the current working directory');
    exit(1);
  }

  var tarFile = results.rest[0];

  if (tarFile.endsWith('.tar.gz'))
  {
    'tar -zxvf $tarFile'.run;
  }
  else if (tarFile.endsWith('.tar'))
  {
    'tar -xvf $tarFile'.run;
  }
  else
  {
    print("The tar file $tarFile does not have a know extension of '.tar.gz' or '.tar'");
  }
}
```

So duntar takes the name or path of a tar file or tar.gz file, checks the extension, and runs untar with the correct switches.

So once again let’s pull the command apart.

Line 9 we have seen before. Declare an ArgParser and ask it to parse the command line arguments.

Line 12 checks that the tar name was passed by checking the size of ‘results.rest’. I should note at this point that we really didn’t need ArgParser as we could have simply accessed ‘args’ directly.

Line 14 and friends print a message telling the user to try again.

Line 21 extracts the name of the tar file from the results.rest array.

Line 23 checks if the tarFile ends with .tar.gz and if so runs the correct tar command.

Line 27 checks again for a .tar file and again runs tar.

Line 31 is a catch all incase they passed in a file that isn’t supported.

## Homework <a href="#9949" id="9949"></a>

So for some homework why don’t you try to make duntar support some additional file types such as .zip or 7z. You could end up with a single app that will uncompress any file type.

## Wrap up <a href="#ef5e" id="ef5e"></a>

So that’s it for this part.

To me at least DCliis beginning to feel like a really useful tool. I love Dart and it’s really nice being able to script in a modern language.

I’ve dropped a few more examples in a git repo.

[https://github.com/onepub-dev/dcli\_scripts](https://github.com/bsutton/dshell\_scripts)

Feel free to issue a pull request and contribute your own little tool. They don’t need to be high quality, just useful.

Finally, if you’re new to Dart, DCli is a great way to get started as it lets you work directly with the language rather than through the prism of a large framework like Flutter.

### Links as promised: <a href="#b886" id="b886"></a>

DCli — [https://pub.dev/packages/dcli](https://pub.dev/packages/dshell)

DCli scripts — [https://github.com/onepub-dev/dcli\_scripts](https://github.com/bsutton/dshell\_scripts)

The above example code and more little tools.

ArgParser — [https://pub.dev/packages/args](https://pub.dev/packages/args)

Money2 — [https://pub.dev/packages/money2](https://pub.dev/packages/money2)

A completely unrelated package that I wrote that lets you parse, format, and do maths with Money and Currencies.
