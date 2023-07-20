---
title: "Simple JWT"
description: "A simple JWT authorization scheme."
keywords: ["Csharp", "Authorization"]
date: 2022-06-29T18:16:47+02:00
draft: false
taxonomies:
  tags: ["Coding", "Csharp"]
---

# Simple JWT Authorization with .NET

Recently I have been working on a side project that needed a very simple toy-like auth
scheme to be implemented. The last few times I implemented JWTs in .NET it was for a full-blown
application which means that I made use of things like `IdentityModel` and `UserManager`,
if you want a look at how I made that work you could take a look at the source code of
[Demeter](https://github.com/AntoniosBarotsis/Demeter).

In this case, I did not need *Authentication*, just *Authorization*. The two are defined as followed
in the [MS Docs](https://docs.microsoft.com/en-us/azure/active-directory/develop/authentication-vs-authorization).

> Authentication is the process of proving that you are who you say you are. [...]
> Authorization is the act of granting an authenticated party permission to do something.
> It specifies what data you're allowed to access and what you can do with that data.

For my use case, simulating a credential check is enough; I don't need to store and check
password salted hashes to make sure a user is indeed who he is supposed to be as this is a toy app
that I am working on with supposedly just one user. All this means that if you are looking for a 
tutorial on how to implement Auth for your new project, this is probably not the article for you,
it is just a less verbose way of dealing with JWT generation and validation that works for me.

That being said, let's get started.

## Setup

The only package I used is [JWT.Extensions](https://www.nuget.org/packages/JWT.Extensions.AspNetCore).
I created 3 classes that make everything work:

- `JwtConfig`: Holds the JWT secret which is provided in the `application.json` file. Could also be
  used for other pieces of configuration such as the token lifespan
- `Secured`: An attribute that when attached to a controller or a specific endpoint requires a 
  valid token to be provided in the request header 
- `TokenService`: A very simple interface to the `JWT.Extensions` API that helps us create and 
  validate tokens.

## The `JwtConfig`

Let's start with the config class first. The idea with this is pretty simple; have a section in our
`appsettings.json` file where we define crucial security information in plain text, what could
possibly go wrong! On a more serious note, while this is fine for developing, you should definitely
use something like [app secrets](https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets?view=aspnetcore-6.0&tabs=windows)
or plain old environment variables for this. Once again, my app is not supposed to be secure so I don't
care.

The class itself is pretty simple in my case:

```cs
public record JwtConfig(string Secret = "fallback-secret");
```

And here's my settings file

```json
{
  "JwtConfig": {
    "secret": "jwt-secret"
  },
  "Logging": {
    ...
  },
  ...
}
```

Now that that's out of the way, let's make sure we use the secret from our settings file in the
`JwtConfig` instances.

I made it so the class is registered as a singleton in the DI container, the binding itself is
pretty simple:

```cs
// Program.cs
var jwtConfig = new JwtConfig();
builder.Configuration.Bind(nameof(jwtConfig), jwtConfig);
builder.Services.AddSingleton(jwtConfig);
```

I used `nameof` just because I wanted to be sure that the config file's section is titled the
exact same as the class itself to avoid confusion, this is just a string so swapping it out for
`"JwtConfig"` would change nothing.

Since we are here, let's also configure some basic settings for our tokens 

```cs
// Program.cs
builder.Services.AddAuthentication(options =>
    {
        options.DefaultChallengeScheme = JwtAuthenticationDefaults.AuthenticationScheme;
        options.DefaultAuthenticateScheme = JwtAuthenticationDefaults.AuthenticationScheme;
    })
    .AddJwt(options => { options.Keys = new[] { jwtConfig.Secret }; });

builder.Services.AddSingleton<IAlgorithmFactory>(new HMACSHAAlgorithmFactory());
```

This is taken straight from their [documentation](https://github.com/jwt-dotnet/jwt#register-authentication-handler-to-validate-jwt) 
so I won't be explaining it too much, just know that we are telling the package to use
the key we just defined and we are also using the `HMACSHA` algorithm.

It is worth noting that this throws us a warning as this is no longer considered secure
and it is recommended to "consider switching to RSASSA or ECDSA". Once again, for the purposes
of my use case, this is not a concern.

## The `TokenService`

This is where most of the interesting stuff happens. Let's first create the class, get our
`jwtConfig` secret and assign it to a `JwtBuilder` instance which we'll use later.

```cs
public class TokenService
{
    private readonly JwtBuilder _jwtBuilder;

    public TokenService(JwtConfig jwtConfig)
    {
        _jwtBuilder = JwtBuilder.Create()
            .WithAlgorithm(new HMACSHA512Algorithm())
            .WithSecret(jwtConfig.Secret);
    }
}
```

Creating the token itself is also pretty much copy-pasted from their 
[docs](https://github.com/jwt-dotnet/jwt#register-authentication-handler-to-validate-jwt).

```cs
public string Create(string username)
{
    return _jwtBuilder
        .AddClaim("exp", DateTimeOffset.UtcNow.AddHours(1).ToUnixTimeSeconds())
        .AddClaim("username", username)
        .Encode();
}
```

I only use the expiration date and username for claims.

Lastly, verification. 

```cs
public bool Verify(string token)
{
    try
    {
        var json = _jwtBuilder
            .MustVerifySignature()
            .Decode(token);

        return json is not null;
    }
    catch (Exception)
    {
        return false;
    }
}
```

I only need a true or false return as I don't care why the token was not valid. In case the token is a 
valid JWT but it is expired, `json` will be null. If on the other hand, the signature is invalid,
then an exception will be thrown for whatever reason.

## The `Secured` Attribute

As I mentioned earlier, all this is glued together by the use of attributes. For this to work,
we need to implement the `IAuthorizationFilter` interface. This will make it so our code will be
executed to determine whether a request should be authorized or not.

The code for this is also simple but let's go over it step by step

```cs
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class Secured : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var jwtConfig = context.HttpContext.RequestServices.GetService<JwtConfig>();
        if (jwtConfig == null) throw new ArgumentNullException();

        var tokenService = new TokenService(jwtConfig);
        var token = context
            .HttpContext
            .Request
            .Headers["Authorization"]
            .ToString()
            .Replace("Bearer ", "");

        if (!tokenService.Verify(token))
            context.Result = new JsonResult(new { message = "Unauthorized" })
                { StatusCode = StatusCodes.Status401Unauthorized };
    }
}
```

As I mentioned earlier, I want this to apply to both endpoints and entire controllers, hence
the first line. In order to implement `IAuthorizationFilter`, we need to define the `OnAuthorization`
method. We use the `IServiceProdiver` to retrieve our `JwtConfig` instance and make sure it is not null.
We then instantiate `TokenService` and retrieve the token from the request header. Finally, we make sure
to throw an Unauthorized message to the user if the token is invalid, otherwise, the request pipeline
will proceed as expected. 

And that's it! We can now add our newly created attribute to whichever controller or endpoint we want
and it will be locked behind a valid JWT requirement.

## Closing

This pretty much concludes the article! As I mentioned earlier, this is a very specific and lacking
implementation, the main point of the article was to showcase how you could use your own attributes
to simplify the process which to me feels simpler (and less verbose) compared to some of my previous
implementations. 

This is probably the most boring article I've written so far but I promise you that the project I am
going to use this for is interesting. It's also a lot harder than anything I've tried before so don't
expect that the be out anytime soon.

Till next time :)