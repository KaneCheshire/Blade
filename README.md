# Blade

A super simple dependency injection library written in Swift. 

## QuickStart

There are only two main steps to using Blade bfeore you can start injecting.

### 1: Registering types

Before Blade knows how to inject a type, you need to register a provider so that it can be injected elsewhere in the project. 

A typical place to do this is in the AppDelegate:

```swift
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
	// Since `Resolver.register` also supports autoclosures, you can also write this simply as `Resolver.register(MyInjectedType())`
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

	init(injectedArgument: MyInjectedType = Resolver.resolve() {
		// Do something with injectedArgument
	}
}
```

## Qualifiers

There might be times when you want to return different instances of an object depending on the circumstance that it's being used.

Blade currently only supports providing a qualifier type when registering a type, and you can use that same qualifier type when resolving, 
either using the `Inject`/`LazyInject` property wrappers, or when using `Resolver` directly.

The first step is to declare a new type that conforms to Qualifier. This could be a `struct`, a `class`, or an `enum`. I recommend using an `enum`, since 
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

	init(injectedArgument: MyInjectedType = Resolver.resolve(qualifiedBy: MyQualifier.self) {
		// Do something with injectedArgument
	}
}
```

## Good to know

Blade is very new, and very simple. 

Compared to alternatives like [Cleanse](https://github.com/square/Cleanse) for Swift and Dagger for Java, Blade is simple, easy to learn and easy to use, 
but as a result may not be suitable for large or complex projects.

I'm really keen for you to use it, and let me know what problems you have or whether you think the API needs to change, or if new features are needed.

Blade has no notion of modules or scopes (although it does have [Qualifiers](#qualifiers)). If this impacts you, I'd love to learn more about the use case where
this is required over what Blade currently offers, and whether it's something that Blade should include or whether Blade should commit to being simple and
only used in simple projects.

## Installation

Blade is only available via Swift Package Manager. From Xcode 11 and newer you can specify Blade as a remote dependency and Xcode will automatically
handle resolving and including the dependency for you. 
