---
title: "BudgetFixture"
description: "A Proof of Concept AutoFixture Clone in java."
keywords: ["Java", "Testing", "Reflection"]
date: 2022-07-12T22:11:09+02:00
draft: false
taxonomies:
  tags: ["Coding", "Java"]
---

# BudgetFixture

BudgetFixture is a very minimal (budget one could say), proof of concept - clone of the
[AutoFixture](https://github.com/AutoFixture/AutoFixture) package in Java.

My repository can be found [here](https://github.com/AntoniosBarotsis/BudgetFixture).

## What is AutoFixture

AutoFixture is a very handy .NET library that is 

> "designed to minimize the 'Arrange' phase of your unit
  tests in order to maximize maintainability. Its primary goal is to allow developers to focus on what
  is being tested rather than how to setup the test scenario, by making it easier to create object
  graphs containing test data."

What does that mean? In essence, it provides a neat interface for creating class instances for your
tests with random data.

In their README they provide the following example:

```cs
[Fact]
public void IntroductoryTest()
{
    // Arrange
    Fixture fixture = new Fixture();

    int expectedNumber = fixture.Create<int>();
    MyClass sut = fixture.Create<MyClass>();
    // Act
    int result = sut.Echo(expectedNumber);
    // Assert
    Assert.Equal(expectedNumber, result);
}
```

For comparison, this is what I ended up with:

```java
public class Main {
    public static void main(String[] args) {
        Fixture.registerGenerators();

        var test = Fixture.Generate(Person.class);

        System.out.println(test);
        // Person[id=fe4c38b1-aefc-4f6d-a60c-ca4918a3ad79, name=Random string]
    }
}
```

Although these two admittedly look deceivingly similar, I regret to remind you that
I dropped the project at a very early "proof of concept" stage, meaning that it is 
very much lacking a lot of features and configuration options, some of which would
cause certain issues in your tests.

This project was more about seeing if something similar to this was even possible
rather than creating a useful library I'm afraid.

That said, there's some interesting bit of reflection involved which not too many
people care enough about so you might still find it interesting!

## How Did This Start?

A friend of mine recently started working on his own [Fuzzer](https://en.wikipedia.org/wiki/Fuzzing)
which can be found [here](https://github.com/martinmladenov/fuzzer), go give it a star!

The idea is simple: Create certain blueprint classes (he called them Reference classes)
which 

For example, the following method would generate and print 100 random URIs;

```java
private static String getDemoUris(int seed) {
    URIReference symbol = new URIReference();

    StringBuilder sb = new StringBuilder();
    Random rnd = new Random(seed);

    for (int i = 0; i < 100; i++) {
        sb.append(i).append(": ");
        symbol.generate(sb, rnd);
        sb.append("\n");
    }
    return sb.toString();
}
```

Me being me, I started thinking about how this would work in the context of a library.

Having used [Jqwik](https://jqwik.net/) in the past, I liked their idea of defining
`Providers` which were functions that would leverage the library and generate
random output with potential useful constraints.

For instance, here's an example they include in their docs;

```java
@Provide
Arbitrary<Integer> divisibleBy3() {
  return Arbitraries
      .integers()               // an arbitrary integer
      .between(1, 100)          // between 1 and 100
      .filter(i -> i % 3 == 0); // that is also divisible by 3
}
```

This deviates a bit from what I wanted to do but at the same time, it's not like
I had a very clear image of what I wanted to achieve in the first place.

## What Did I Want To Build?

In my case, it would make more sense to have a let's say `intProvider`
or a `UriProvider` instead of a `intThatIsDivisibleBy3`, although it would be nice to
allow the tester to override an `intProvider` with a `intThatIsDivisibleBy3` in a specific
test because why not, which is ironic for me to say considering the aforementioned feature
is left as an exercise to the reader.

I instead decided to go for simple data type providers and use those to build up any complex
type. In the `Person` example from the beginning of the post, for example, I defined `UUID` and
`String` providers (or generators as I ended up calling them) in separate files and used those
behind the scenes to create a `Person` instance.

My idea was to worry about how this could look as a library rather than how the generation
itself would work which is why as you will see I didn't really add any features around it.

## End Result?

I'm pretty happy with how this ended up looking. Most of this is taken from my repo's
[README](https://github.com/AntoniosBarotsis/BudgetFixture).

For this example, let's create a `Person` record which we'll try to generate automatically
later:

```java
// Person.java
public record Person(UUID id, String name) {}
```

This class has 2 different classes in its fields, namely a `UUID` and a `String` so let's
create `Generator`s for both of them:

```java
// UuidGenerator.java
public class UuidGenerator extends Generator<UUID> {
    @Override
    public UUID call() {
        return UUID.randomUUID();
    }
}

// StringGenerator.java
public class StringGenerator extends Generator<String> {
    @Override
    public String call() {
        return "Random string";
    }
}
```

The contents themselves are not important for the sake of the example, hence the `"Random String"`.

Heading back to our `Main` method, running the following piece of code

```java
// Main.java
public class Main {
    public static void main(String[] args) {
        // register UuidGenerator.java & StringGenerator.java
        Fixture.registerGenerators();

        // Generate a Person instance
        var test = Fixture.Generate(Person.class);

        // Check the results
        System.out.println(test);
    }
}
```

Would print something like this:

```txt
Person[id=fe4c38b1-aefc-4f6d-a60c-ca4918a3ad79, name=Random string]
```

I mentioned my [friend's Fuzzer](https://github.com/martinmladenov/fuzzer) earlier as, if that was
also a library, we could use the `Reference` classes provided by it for our generators to very easily
produce complex and randomised attributes for our tests.

## The Plan

Reiterating the previous paragraph but more concretely this time;

The plan is to fulfill the following:

- easily define a generator for a given data type
- register generators manually (and potentially override default)
- have a way to "discover" the generators automatically without the tester
  needing to manually write them out one by one
- have a very simple way of generating new classes

## Getting Started with the Generator

> Why does Java have Type Erasure? :(

This right here was the main reason why I wanted to give this project a shot *again*.
Java implements [Type Erasure](https://docs.oracle.com/javase/tutorial/java/generics/erasure.html).

Having picked up reflection and Metaprogramming in general from C#, this was weird to me initially.
Well, turns out that Java doesn't like reflection as much as C# does *and this is terribly apparent in
any framework/library comparison between the 2 languages*.

But I'm getting sidetracked here. Type erasure is a pretty big problem for this project. To fully
understand why I'll explain how I would be implementing this in a language that does not use
type erasure (say C#). I'll be using pseudo-ish code so don't take it char by char for this example.

It would be possible to have a map (or dictionary depending on your language) of type
`<Class<T>, Callable<T>>` where we are essentially mapping a class to some function that
generates an instance of that class. Sounds simple enough right? Well since that `T` would get
erased at runtime, we'd have no way of using our map as it would essentially get turned into
`<Class, Callable>`. This would make many things easier (and safer) but since it's not available
we'll go with the next best thing: using the class' string representation as the Key.

Since we got that explanation out of the way, let's see how we could create our Generator class then

```java
// Generator.java
public abstract class Generator<T> {
    public abstract T call();
}
```

Pretty simple so far, we have a class of some generic type `T` that also has a method `call` that
returns something of that type `T`. I wanted both the class itself and the `call` method to be abstract
so that concrete generators inherit from a class which will be important later when we try to detect
them.

Coming back to the example from earlier, if we wanted a `StringGenerator` then that would be a
`Generator<String>` type and `call` would return a `String`.

Unfortunately, with Java being Java, getting that `T` is somewhat cumbersome so we'll add a
method to help us with that here

```java
public abstract class Generator<T> {
    public abstract T call();

    final Class<T> getType() {
        // Cast result to a generic class
        ParameterizedType superclass = 
          (ParameterizedType) getClass().getGenericSuperclass();

        // Return first generic type (T)
        return (Class<T>) superclass.getActualTypeArguments()[0];
    }
}
```

Calling this `getType` method on our `StringGenerator` would return `java.lang.String`.

Notice that `call` is declared `public` so that it can be overridden by the tester while
`getType` is both `final` (so it can't be overridden) and also package-private.

To recap, we somewhat found a way around Java's type erasure using the text representation of the
classes instead of the classes themselves and we also made a wrapper abstract class to use for this.
Now, all we have to do is literally everything else!

## Creating the Fixture Class

Second step into the project and here comes the first decision I later regretted: turning this class
into a Singleton.

Test runners nowadays (JUnit included) play around with state scope a lot when running your tests.
Your tests might be ran in parallel, certain objects involved in your tests might get an instance
assigned to them for one single test or a group of tests, and so on. All these are usually fine
if you are dealing with non-static classes. The pitfall of using static classes is that any
change in the underlying configuration options that you provide might produce unexpected
behavior if it takes place halfway through your test execution.

You will see later as I dive through my code that I have a `ConstructorFinder` interface, this is
using the strategy pattern to abstract away how I choose a class constructor (I could either pick
the one with the most attributes or the default one for example). I made this because, depending on
your use case, you might want to configure your class attributes through the constructor instead of the
setters or the other way around and I wanted the tester to be able to choose. This would be fine if
you could choose this option in an individual Fixture instance instead of a singleton. You should
generally try to avoid anything static in your tests and this is exactly why.

As an example, say that all of the entities you use in your tests have full arg constructors
which you want to use when instantiating them, except for this one class which for some reason
uses a no-arg constructor only for which you need to use the setters for. Were you to tell my
fixture class "Hey, I want to use the no-arg constructor for this test" the class would *do* that
and also use that behavior for all the remaining tests which is more than likely, undesirable.

Don't get me wrong, using a singleton somewhere is a good idea for this unless you want every
new Fixture instance to rescan half your package hierarchy. What I should have done instead however
is have the Singleton be some sort of configuration/builder object that would create the actual
Fixture instance which would not be a singleton. This way, the state would not be shared between tests
and that would not cause issues. 

<!-- As I mentioned earlier, this is a proof of concept and not meant to be used as a testing library
but in case you want to build off of it, definitely make the changes I just mentioned, the "global
settings" should be frozen once the instances are created to avoid unexpected behavior. -->

With that out of the way, let's see what my Fixture class looks like.

```java
public class Fixture {
    private static final ConstructorFinder constructorFinder = 
        new LongestConstructorStrategy<>();
        
    private static final HashMap<String, Generator<?>> map = new HashMap<>();

    private Fixture() { }

    private static HashMap<String, Generator<?>> getMap() {
        return map;
    }
}
```

Nothing weird going on with the map as I explained my reasoning earlier. Let's go on a small tangent
and check the `ConstructorFinder` class before moving further down

```java
// ConstructorFinder.java
public interface ConstructorFinder<T> {
    Constructor<T> getConstructor(Class<T> obj) throws NoSuchMethodException;
}
```

Similar to the `Generator` class from earlier, the idea is to, given a class `T`, return a
constructor with generic type `T` which means a constructor that creates an instance of `T`.

As I mentioned earlier, I made 2 implementations of this interface as seen below:

```java
// DefaultConstructorStrategy.java
public class DefaultConstructorStrategy<T> implements ConstructorFinder<T>{
    @Override
    public Constructor<T> getConstructor(Class<T> obj) throws NoSuchMethodException {
        return obj.getConstructor();
    }
}

// LongestConstructorStrategy.java
public class LongestConstructorStrategy<T> implements ConstructorFinder<T> {
    @Override
    public Constructor<T> getConstructor(Class<T> obj) {
        // Get class constructors
        var ctors = obj.getConstructors();

        // Find the one with the most parameters
        var tmp = Arrays.stream(ctors)
            .max(Comparator.comparingInt(x -> x.getParameterTypes().length));

        // tmp is an optional so we need .get()
        return (Constructor<T>) tmp.get();
    }
}
```

These definitely look safe and don't have half a dozen things that could go wrong in a more
realistic code base so let's move on!

Small note here, currently the map allows overrides; if a specific Generator exists and is registered
at runtime, nothing is preventing you from specifying another Generator for the same type, effectively
overriding the previous one. This isn't necessarily bad as you may want to make that override for a
particular test (assuming again, the concerns I listed earlier about singletons are taken care of)
which would look like this;

```java
// Using a Generator we have already
// declared in a separate file
Fixture.Register(new UuidGenerator());

// Or declaring one inline
Fixture.Register(new Generator<String>() {
    @Override
    public String call() {
        return "very cool random text";
    }
});
```

And another small note, I have moved some of these methods to a helper class `Util` to declutter
the original one, I'll be adding the filename at the top to avoid confusion! 

I've also defined a `Tuple` class which looks like this:

```java
// Tuple.java
public record Tuple<T, K>(T _1, K _2) {}
```

### Dealing with the Generators

As I mentioned earlier, I wanted a way to dynamically find all the declared generators and
use them without the user needing to specify them. 

To do that we first need to get all classes in the relevant package. I decided to consider
the "relevant package" to be the package that calls the `registerGenerators` (which is the
method that we are building up to). A nice addition here would be to include a configuration
option (or a function overload) that allows the tester to specify the package where the generators
are defined to save up some time on startup and to allow them to specify a different package.

Anyway, this is the method I ended up with

```java
// Util.java
private static List<Tuple<String, String>> listAllClassesFromPackage(String packageName) {
    // Get resource stream for given package
    InputStream stream = ClassLoader
        .getSystemClassLoader()
        .getResourceAsStream(packageName);

    // If stream is null -> return empty list
    if (stream == null) {
        return List.of();
    }

    // Turn stream into a list
    BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
    var list = reader.lines().toList();

    // Resulting list will be a list of
    // <className, packageName> tuples
    var res = new LinkedList<Tuple<String, String>>();

    for (String s : list) {
        // If s is a class
        if (s.endsWith(".class")) {
            // Add to res
            res.add(new Tuple<>(s, packageName));
        }

        // Recursively add nested package
        res.addAll(listAllClassesFromPackage(packageName + "/" + s));
    }

    return res;
}
```

We first need to get the resource stream of the passed package which might be null if there's nothing
left, in which case we return an empty list. If not, we turn that into a list and iterate through it.
Classes do end in `.class` so we can easily filter those out and add them to the result list (res) along
with the full package name so far. If the current element is not a class (and is, therefore, a package)
we recursively call the same method again only with an updated package name. Finally, we return the list.

But where does this `packageName` initially come from? The following method retrieves it

```java
// Fixture.java
private static String getPackageName() throws ClassNotFoundException {
    // Get stacktrace
    StackTraceElement[] stacktrace = Thread.currentThread().getStackTrace();

    // This corresponds to the context that called this method
    StackTraceElement e = stacktrace[3];

    // Load class and get its package name
    return ClassLoader
        .getSystemClassLoader()
        .loadClass(e.getClassName())
        .getPackageName()
        .replaceAll("\\.", "/");
}
```

This is quite self-explanatory except for the stack trace stuff, what's that all about? This was
*borrowed* from [this](https://stackoverflow.com/a/4065546/12756474) StackOverflow post. Instead of
the `2`, I am using `3` since this get's called from inside another method which adds another
entry to the stack.

Moving back to the Util class, I also made a small wrapper method to get the class given the path to it
which is the following;

```java
// Util.java
private static Class<?> getClass(String className, String packageName) {
    var newClassName = 
        // package
        packageName.replaceAll("/", ".") + "." +
        // className (without .class)
        className.substring(0, className.lastIndexOf('.'));

    try {
        // Retrieve class using the class name
        return Class.forName(newClassName);
    } catch (ClassNotFoundException e) {
        throw new RuntimeException("Class " + newClassName + " was not found");
    }
}
```

Nothing interesting happening here, just including it to avoid confusion later.

Finally, we get to the more interesting stuff. Combining the previous methods together, 
we get the following:

```java
// Util.java
static Set<Class<?>> findAllGenerators(String packageName) {
    // Get all classes for the given package
    // lines is a List<Tuple<className, packageName>>
    var lines = listAllClassesFromPackage(packageName);

    return lines.stream()
        // Sanity check - filter for classes
        .filter(el -> el._1().endsWith(".class"))
        // Map to actual classes
        .map(el -> Util.getClass(el._1(), el._2()))
        // Filter for
        .filter(el ->
            // Classes with the Generator as a superclass
            el.getSuperclass() != null &&
            el.getSuperclass().equals(Generator.class) &&
            // Classes that are not a Main class
            Util.isNotMain(el)
        )
        .collect(Collectors.toSet());
}

private static boolean isNotMain(Class<?> el) {
    try {
        // These would have "$[number]" for some reason,
        // remove those
        var newName = el.getName().replaceAll("\\$\\d+", "");
        // Try to get main method, if there is no main method
        // this throws an exception
        el.getClassLoader().loadClass(newName).getMethod("main", String[].class);
        // If this didn't crash then it is a main method
        return false;
    } catch (NoSuchMethodException ignored) {
        // if the method doesn't exist then it's not main
        return true;
    } catch (ClassNotFoundException e) {
        throw new RuntimeException(e);
    }
}
```

Using the list generated from the `listAllClassesFromPackage`, we have a sanity check filter
for the classes followed by a map that uses the `getClass` method I just mentioned. Now that
we have a stream of Classes we can check to see if they inherit from `Generator`. Now, for some
reason I did not figure out, that would also include the Main class which is why I also make sure
that the current class does not have the `Main` method.

Let's recap really quick because that is a lot to take in; 

- we have a way of getting the package name of the file that called a specific method we made
- we also have a way to scan that package for all classes that inherit from the `Generator` class we 
  created earlier

This means that we can now finally build the `registerGenerators` method!

This method had way too many exceptions to catch so let's look at it without the try-catch
blocks first;

```java
// Fixture.java
public static void registerGenerators() {
    // Get all generator classes
    var res = Util.findAllGenerators(getPackageName());

    // Instantiate and register the new generator
    res.forEach(el -> {
        Register((Generator<?>) el.getConstructor().newInstance());
    });
}

public static <T> void Register(Generator<T> callable) {
    // Put new generator in the map
    getMap().put(callable.getType().getName(), callable);
}
```

Well that seems simple! We call `findAllGenerators` with the relevant package name and then
for each class in the resulting list, we call the `Register` method you can see right after
which just adds them to the Fixture HashMap.

The real method looks more like this

```java
// Fixture.java
public static void registerGenerators() {
    try {
        var res = Util.findAllGenerators(getPackageName());
        res.forEach(el -> {
            try {
                // I know this is a mess, the actual code is here
                Register((Generator<?>) el.getConstructor().newInstance());
                // cheers
            } catch (NoSuchMethodException e) {
                throw new RuntimeException("No constructor was found for class " + el.getName());
            } catch (IllegalAccessException e) {
                try {
                    throw new RuntimeException("Constructor " + el.getConstructor() + " is not public");
                } catch (NoSuchMethodException ignored) {}  // already caught above
            } catch (InstantiationException e) {
                throw new RuntimeException("The class " + el.getName() + " could not be instantiated");
            } catch (InvocationTargetException e) {
                throw new RuntimeException(e);
            }
        });
    } catch (ClassNotFoundException e) {
        throw new RuntimeException(e);
    }
}
```

It is worth noting that you should probably break this logic and error-catching down as this is
way too many try-catches for one method but oh well, not my problem, if it works, it works eh?

## Generating Class Instances

Now that we have a way to dynamically find the declared generators and add them to our
`<dataType, Generator>` map, it is time we start generating some class instances.

I'll take this backward this time and show you the finished method before the parts that make it up
because I want you to see how simple it actually was

```java
// Fixture.java
public static <T> T Generate(Class<T> obj) {
    try {
        // Get class constructor
        var ctor = (Constructor<T>) constructorFinder.getConstructor(obj);

        // Generate a new instance using our generators
        T res = ctor.newInstance(getConstructorParams(ctor));

        // Also use the setters to populate the attributes 
        useSetters(res);

        return res;
    } catch (Exception e) {
        throw new RuntimeException(e);
    }
}
```

That's it! We want to get a constructor of the provided class (using our strategy from earlier),
create a new instance using that constructor (this uses our generators behind the scenes)
and finally (technically also optionally), use our generators on all relevant setters.

Technically speaking, if this was an actual library you would want to let the tester decide whether
or not you should use either the constructor, the setters or both. Perhaps this decision should be
connected to the constructor finder strategy as in, default constructor & setters or
big constructor and no setters. In any case, that is beyond the scope of what I wanted to achieve
so I didn't do much with it.

But enough with that, let's take a look at the `getConstructorParams` method;

```java
private static <T> Object[] getConstructorParams(Constructor<T> ctor) {
    return Arrays.stream(ctor.getParameters()) // Get constructor params
        .map(Parameter::getType)               // Get param type
        .map(Class::getName)                   // Get class name
        .map(el -> getMap().get(el).call())    // Call appropriate generator
        .toArray();
}
```

For this, we want to basically do the exact opposite of what the `Register` method from
earlier does; get the type class names, retrieve and call their corresponding Generators from our
map.

With all this done, we have now created our class instance! As I mentioned earlier, stopping here
would be fine (especially if we assumed that an all-arg constructor is always present) but as I 
mentioned earlier, I wanted to fiddle around with setters as well so let's now take a look at 
`useSetters`;

```java
private static <T> void useSetters(T res) {
    // Create Map<fieldName, fieldType>
    var fieldTypes = Arrays.stream(res.getClass().getDeclaredFields())
        .collect(Collectors.toMap(Field::getName, Field::getType));

    // Get all setters
    var setters = Arrays.stream(res.getClass().getDeclaredMethods())
        .filter(el -> el.getName().toLowerCase(Locale.ROOT).contains("set")).toList();

    // for each field
    fieldTypes.forEach((fieldName, fieldType) -> {
        // Find related setter if exists
        var setter = setters.stream()
            .filter(el -> el.getName().toLowerCase(Locale.ROOT).contains(fieldName))
            .findFirst();

        // If a setter was found
        setter.ifPresent(el -> {
            try {
                // Find generator for given field type
                var generator = getMap().get(fieldType.getName());

                // Pass generator output to setter
                el.invoke(res, generator.call());
            } catch (IllegalAccessException | InvocationTargetException e) {
                throw new RuntimeException(e);
            }
        });
    });
}
```

This first creates a map of all the class field names and types which we'll use later.
It then finds all methods that contain "set" in their method name (so hopefully all setters).
Then for each field, we try to find a setter that contains the field name in its name and if
we do find it we try and get a generator for the current field through our map. Finally, we
invoke the setter with whatever the generator call gives us.

## Closing

All in all, I'm glad I have this idea a shot again. I tried one or two more times in the past
but got stuck somewhere and dropped the project in favor of something else (preferably not Java)
so it was definitely refreshing paying this a visit again after getting some new ideas from here
and there. 

This definitely was one way of spending the last 2 afternoons.

Till next time!