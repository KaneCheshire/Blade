# Blade

A super simple dependency injection library written in Swift. 

- [Quick start](#quick-start)
	- [Registering types](#registering-types)
	- [Declaring injected properties](#declaring-injected-properties)
- [Scopes](#scopes)
- [Qualifiers](#qualifiers)
- [Good to know](#good-to-know)

## Quick start

There are only two main steps to using Blade before you can start injecting.

### 1: Registering types

Before Blade knows how to inject a type, you need to register a provider so that it can be injected elsewhere in the project. 

A typical place to do this is in the AppDelegate:

```swift
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
	Resolver.register { MyInjectedType() }
	return true
}
```
### 2: Declaring injected properties

Once you've registered providers, you can then declare where those instances are injected using Blade's property wrappers.

```swift
class MyViewController: UIViewController {

	@Inject
	private var injectedProperty: MyInjectedType // This is resolved when `MyViewController` is created
	
	@LazyInject
	private var lazilyInjectedProperty: MyInjectedType // This is only resolved when first accessing, like when using `lazy var`
}
```

You can also use Blade to inject into initializers, by using `Resolver` directly:

```swift
class MyViewModel {

	init(injectedArgument: MyInjectedType = Resolver.resolve()) {
		// Do something with injectedArgument
	}
}
```
## Scopes

By default, Blade will call the provider you register every time you inject or call `Resolver.resolve()`, but you can change this using a `Scope`.

Scoped objects are only created whenever first resolved or injected, and persist until every object that holds a reference to the scoped object are destroyed.

As an example, let's say you had a User object and you want it to be shared across a registration flow. You could inject it using a scope in every controller.

The first step is to define a new `Scope`, which (similar to a [`Qualifier`](#qualifier)) you do by defining a type that conforms to `Scope`:

```swift

enum RegistrationFlow: Scope {} 

```

Once defined, you register a provider using the scope:

```swift

Resolver.register(scopedTo: RegistrationFlow.self) { User() }

```

And once registered, you can then start injecting into whatever needs a shared `User` object for the flow:

```swift

class UsernameRegistrationController: UIViewController {

	@Inject(RegistrationFlow.self)
	private var user: User
}

class PasswordRegistrationController: UIViewController {

	@Inject(RegistrationFlow.self)
	private var user: User // The same instance of User as injected into `UsernameRegistrationController`
}

```
So long as `PasswordRegistrationController` is created before  `UsernameRegistrationController` is destroyed, the `User` instance
in both controllers will be the same, ready for you to use at the end of the flow.

> *NOTE*: You can only use a Scope with a class types, not value types. So in this case, `User` is a `class`, not a `struct`.

You can also manually resolve objects for scopes:

```swift

class RegistrationManager {

	init(user: User = Resolver.resolve(scopedTo: RegistrationFlow.self)) {
		// Do something with user
	}
}

```
It's important to understand that objects in a scope are only kept until nothing holds a reference to it. If all objects holding a reference to a scoped
object are destroyed, the shared injected/resolved object is also destroyed. The next time an object tries to inject an object with the same scope, a new
instance of the scoped object is created.

The exception to this rule is if you keep a reference elsewhere to the object that you provide when registering a provider for the scope, in that case Blade will
not know that a new instance is required so will keep returning the same object until nothing holds a reference to it any more.

## Qualifiers

There might be times when you want to return different instances of an object depending on the circumstance that it's being used.

Blade currently supports this by you providing a qualifier type when registering a type, and you can use that same qualifier type when resolving, 
either using the `Inject`/`LazyInject` property wrappers, or when using `Resolver` directly.

The first step is to declare a new type that conforms to `Qualifier`. This could be a `struct`, a `class`, or an `enum`. I recommend using an `enum`, since 
we're only use the type, not an instance of the type, and `enum`s don't have initializers:

```swift
enum MyQualifier: Qualifier {}
```

You can then use that qualifier when registering a type:

```swift
Resolver.register { MyInjectedType() } // This provider will be used when no qualifier is used when injecting/resolving
Resolver.register(qualifiedBy: MyQualifier.self) { MyInjectedType() } // This provider will only get used when `MyQualifier` is used when injecting/resolving
```
Once you've registered a provider for a qualifier, you can then specify the qualifier to use when injecting:

```swift
class MyViewController: UIViewController {

	@Inject
	private var injectedProperty: MyInjectedType

	@Inject(MyQualifier.self)
	private var injectedQualifiedProperty: MyInjectedType // This will use the instance provided by the registered provider specifically for `MyQualifier`
}
```

And you can also specify the qualifier if resolving manually:

```swift
class MyViewModel {

	init(injectedArgument: MyInjectedType = Resolver.resolve(qualifiedBy: MyQualifier.self)) {
		// Do something with injectedArgument
	}
}
```

## Good to know

Blade is very new, and very simple.

Compared to alternatives like [Cleanse](https://github.com/square/Cleanse) for Swift and Dagger for Java, Blade is simple, easy to learn and easy to use, 
but as a result may not be suitable for large or complex projects.

I'm really keen for you to use it, and let me know what problems you have or whether you think the API needs to change, or if new features are needed.

Blade has no notion of modules or graphs (although it does have [Scopes](#scopes)) and [Qualifiers](#qualifiers)). If this impacts you, I'd love to learn more about the use case where
this is required over what Blade currently offers, and whether it's something that Blade should include or whether Blade should commit to being simple and
only used in simple projects.

## Installation

Blade is only available via Swift Package Manager. From Xcode 11 and newer you can specify Blade as a remote dependency and Xcode will automatically
handle resolving and including the dependency for you. 
