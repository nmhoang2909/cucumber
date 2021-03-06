# Cucumber Expressions

Cucumber Expressions are simple patterns for matching Step Definitions with
Gherkin steps.

(The [implementations](IMPLEMENTATIONS.md) list indicates what Cucumber implementations
currently support Cucumber Expressions).

Cucumber Expressions are an alternative to [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression)
that are both easier to read and write.

This is an example of a Cucumber Expression with a single argument `{n}`:

    I have {n} cukes in my belly

This expression would match the text of the following [Gherkin Step](../docs/gherkin.md#steps) (The part after the `Given ` keyword):

    I have 42 cukes in my belly

When this text is matched against the expression, the `{n}` argument would get the
value `"42"` and be passed to the body of the [Step Definition](../docs/step-definitions.md).

## Optional Text

Optional text is simply surrounded by parenthesis:

    I have {n} cuke(s) in my belly

That expression would still match this text:

    I have 42 cukes in my belly

But it would also match this text (note the singular cuke):

    I have 1 cuke in my belly

## Type Transforms

Arguments extracted from a successful match are strings by default. In many cases
you want the type of the argument to be something else, and you can specify the
desired type:

    I have {n:int} cukes in my belly

In this case the argument would be converted to the integer `42` instead.

Cucumber Expressions have built-in support for `int` and `float` types, and any
additional numeric types available in your programming language. You can easily
add support for [custom type transforms](#custom-type-transforms)

### Statically Typed Languages

Statically typed programming languages make it possible to determine the argument
types from the step definition body's signature instead of the Cucumber Expression.

Here is an example in Java:

```
Given("I have {n} cukes in my belly", (int n) -> {
  // no need to specify {n:int} - the signature makes that explicit.
})
```

### Custom Type Transforms {#custom-type-transforms}

The built-in transforms are handy, but you'll often want to register
transforms for additional types:

{% codetabs name="Java", type="java" %}
TransformLookup transformLookup = new TransformLookup(Locale.ENGLISH);
transformLookup.addTransform(new FunctionTransform<>(
  Currency.class,
  singletonList("[A-Z]{3}"),
  Currency::getInstance
));
{% language name="JavaScript", type="js" %}
const transformLookup = new TransformLookup()
transformLookup.addTransform(new Transform(
  ['currency'],
  Currency,
  ['[A-Z]{3}'],
  s => new Currency(s)
))
{% language name="Ruby", type="rb" %}
transform_lookup = TransformLookup.new
transform_lookup.add_transform(Transform.new(
  ['currency'],
  Currency,
  ['[A-Z]{3}'],
  lambda { |s| Currency.new(s)}
))
{% endcodetabs %}

With this in place you'll automatically get instances of `Currency`:

    I have a {currency:currency} account

If the argument name is the same as the type name, you don't need to specify
the type name - it will be derived from the argument name instead:

    I have a {currency} account

### Implicit Transforms

If you're using a statically typed language, and your type constructor accepts
a single `String` argument, then an instance of that type will be created even
if no custom transform is registered:

    I have a {color} ball

If the signature of the Step Definition is, say `(Color)`, then you'll get an instance
of that class as long as the type has a constructor with signature `(String)`.

Registering an explicit transform is still beneficial, because it will allow Cucumber
to suggest snippets for undefined steps with the correct type.

### Step Definition Snippets and Custom Transforms

When Cucumber encounters a [Gherkin step](../docs/gherkin.md#steps) without a
matching [Step Definition](#), it will print a code snippet with a matching
step definition that you can use as a starting point. Consider this Gherkin step:

    Given I have 2 red balls

Cucumber would suggest a Step Definition with the following Cucumber Expression:

    Given I have {arg1:int} red balls

You may have a `Color` class that you want to use to capture the `red` part of the
step, but unless you register a transform for that class, Cucumber won't be able
to recognise that. Let's register a transform for `Color`:

{% codetabs name="Java", type="java" -%}
transformLookup.addTransform(new FunctionTransform<>(
  Color.class,
  singletonList("red|blue|yellow"),
  Color::new
));
{%- language name="JavaScript", type="js" -%}
transformLookup.addTransform(new Transform(
  ['color'],
  Color,
  ['red|blue|yellow'],
  s => new Color(s)
))
{%- language name="Ruby", type="rb" -%}
transform_lookup.add_transform(Transform.new(
  ['color'],
  Color,
  ['red|blue|yellow'],
  lambda { |s| Color.new(s)}
))
{%- endcodetabs %}

This time, Cucumber would recognise that `red` looks like a color and suggest
a Step Definition snippet with the following Cucumber Expression:

    Given I have {arg1:int} {arg2:color} balls

### Regular Expressions

Cucumber has a long relationship with Regular Expressions, and they can still be
used instead of instead of Cucumber Expressions if you prefer.

The Cucumber Expression library's Regular Expression support has automatic type
conversion just like Cucumber Expressions.

In the `Currency` example above, the following Regular Expression would cause
automatic conversion to `Currency`:

    I have a ([A-Z]{3}) account

This also applies to the built-in conversions for `int` and `float`. The following
Regular Expression would automatically convert the argument to `int`:

    I have (\d+) cukes in my belly

## TODOs

* Implement snippets in ruby
* Implement snippets in javascript
* 100% coverage for all impls
* Add tests verifying that the result is null/nil when expression doesn't match
* Handle arity mismatch - when there is mismatch between expression args and types length
* Verify that all impls have the same tests

## Acknowledgements

The Cucumber Expression syntax is inspired by similar expression syntaxes in
other BDD tools, such as [Turnip](https://github.com/jnicklas/turnip), [Behat](https://github.com/Behat/Behat) and [Behave](https://github.com/behave/behave).

Big thanks to Jonas Nicklas, Konstantin Kudryashov and Jens Engel for the original
implementations.
