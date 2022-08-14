---
title: "C# and the ELK stack"
description: "Integrating the ELK stack with C#."
tags: ["Coding", "Csharp"]
keywords: ["Csharp", "Elasticsearch", "Kibana", "Monitoring", "ELK"]
date: 2021-10-28T22:04:54+02:00
draft: false
---

## What is the ELK stack?

With today's applications growing in complexity rapidly, debugging and efficiently digesting logs have become crucial.
That is the problem that the [ELK stack](https://www.elastic.co/what-is/elk-stack) is trying to solve.

The ELK stack consists of:
- Elasticsearch: A distributed search engine with highly refined analytics capabilities
- Logstash: A data-processing pipeline that collects data and delivers it to Elasticsearch
- Kibana: A visualization platform built expressly for Elasticsearch

These three together make for a great way of digesting aggregated logs from your application through visualisations.

## What will we be creating?

We will be making a simple API (the default weather forecast template), have it produce logs using Serilog into elasticsearch and viewing them
through kibana.

For this post I will be assuming you have used C## before and thus you have a ready-to-go set up on your machine.

## Coding

Let's first make our project using the dotnet cli, I will name mine `elk`

```bash
dotnet new webapi -n elk
```

Verify that everything is working fine by running the API

```bash
dotnet run
```

and visiting `https://localhost:5001/weatherforecast`. I am using [Insomnia](https://insomnia.rest/) for my http client but Postman or your browser
would also work.

{{< image src="/img/cs_elk/helloWorld.jpg" >}}

### Setting up middleware

I will be setting up middleware to handle logging as it is a cleaner solution than logging in each request. You can read more about middleware
[here](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/write?view=aspnetcore-5.0).

I created the following file:

```cs
// MyMiddleware.cs
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace elk
{
    public class MyMiddleware
    {
        private readonly ILogger<MyMiddleware> _logger;
        private readonly RequestDelegate _next;

        public MyMiddleware(RequestDelegate next, ILogger<MyMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            _logger.LogInformation("Hello from middleware");
            await _next(context);
        }
    }
}
```

and added the following line to the `Configure` method in `Startup.cs`

```cs
// Startup.cs -> Configure
app.UseMiddleware<MyMiddleware>();
```

If we now run the app and make a request to our endpoint we can see `Hello from middleware` logged to the console.

Knowing that that works lets change the middleware a bit so it can catch and handle exceptions

```cs
// MyMiddleware.cs
using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace elk
{
    public class MyMiddleware
    {
        private readonly ILogger<MyMiddleware> _logger;
        private readonly RequestDelegate _next;

        public MyMiddleware(RequestDelegate next, ILogger<MyMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception exception)
            {
                _logger.LogError(exception, "Something went wrong");
                
                await HandleExceptionAsync(context, exception);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception ex)
        {
            context.Response.StatusCode = 500;
            return context.Response.WriteAsync("An exception occured");
        }
    }
}
```

If we now run the app again we should see nothing logged in the console. If we add a `throw new Exception();` statement in our controller
we should get a `500` Response back saying that an exception occured and also see the exception logged in the terminal.

I am going to add the following to the controller so we get errors at random from the endpoint

```cs
if (rng.Next(0, 10) < 2)
    throw new Exception();
```

### Setting up the Elasticsearch and Kibana containers

I will be using Docker to run Elasticsearch and Kibana so first thing I want to do is make a `docker-compose.yml` file.

```yml
## docker-compose.yml
version: "2.4"
services:
  es:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.14.2
    container_name: es
    ports:
      - "9200:9200"
    cpu_count: 1
    mem_limit: 4g
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    environment:
      - cluster.name=es-docker
      - cluster.initial_master_nodes=node1
      - node.name=node1
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
  kib:
    image: docker.elastic.co/kibana/kibana:7.14.2
    container_name: kib
    ports:
      - "5601:5601"
    depends_on:
      - es
    cpu_count: 1
    mem_limit: 4g
    environment: 
      ELASTICSEARCH_URL: http://es:9200
      ELASTICSEARCH_HOSTS: http://es:9200
```

A few things about this;
- It seems that at the time of writing this, version 3 does not support resource limits without using swarm hence the downgrade to 2.4 
  (please use resource limits if you want your computer to be usable)
- The `cluster.initial_master_nodes` and `node.name` must have the same value as I want to use a one node cluster
- The `ELASTICSEARCH_URL` and `ELASTICSEARCH_HOSTS` params are needed since by default these will try to find the elasticsearch server at
  `http://localhost:9200`.

### Setting up Serilog

We will be using the `Serilog.AspNetCore` (for logging), `Serilog.Sinks.Elasticsearch` (for pushing our logs to elastic) and
`Serilog.Enricher.Environment` (for adding properties from System.Environment) packages.

Once you have those installed, go to the `appsettings.json` file, remove the Logging section and add the following:

```json
"Serilog": {
  "MinimumLevel": {
    "Default": "Information",
    "Override": {
      "Microsoft": "Information",
      "System": "Warning"
    }
  }
}
```

We need to make some changes in our `Program.cs` file both for logging in the terminal as well as pushing our logs to Elastic.

```cs
// Program.cs
public static IHostBuilder CreateHostBuilder(string[] args)
{
    return Host.CreateDefaultBuilder(args)
        .UseSerilog((context, configuration) =>
        {
            configuration
                .Enrich.FromLogContext()
                .Enrich.WithMachineName()
                .WriteTo.Console()
                .WriteTo.Elasticsearch(
                    new ElasticsearchSinkOptions(new Uri(context.Configuration["ElasticConfig:url"]))
                    {
                        IndexFormat = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}-" +
                                      $"{context.Configuration["ASPNETCORE_ENVIRONMENT"].ToLower()}_{DateTime.UtcNow:yyyy-MM-dd}",
                        AutoRegisterTemplate = true
                    })
                .Enrich.WithProperty("Environment", context.HostingEnvironment.EnvironmentName)
                .ReadFrom.Configuration(context.Configuration);
        })
        .ConfigureWebHostDefaults(webBuilder => { webBuilder.UseStartup<Startup>(); });
}
```

Most of this you can find online but for as a short explanation:
- We enrich our logs with the log context, machine name and the environment (dev/prod)
- We push our logs both to the console and to elastic
- The logs in elastic will have the format `appname-dev/prod_date`. Something to keep in mind for this is that it looks like some characters
  like `:` do not work in these patterns or at least didn't work for me hence the underscore.

What's cool about this is that we do not have to change our existing logger related code! We can also however use Serilog directly:

- Change the `using Microsoft.Extensions.Logging;` import to `using Serilog;`
- Remove the generic from the `ILogger`s
- Change `_logger.LogError` to `_logger.Error`

Another thing we can do is edit the Exception data and log some debugging critical parameter.

```cs
// WeatherForecastController.cs
if (rng.Next(0, 10) < 2)
{
    var myException = new Exception();
    myException.Data.Add("someVeryImportantAttribute", 42);
    throw myException;
}
```

```cs
// MyMiddleware.cs
catch (Exception exception)
{
    _logger.Error(exception, "Something went wrong, {message}", exception.Data["someVeryImportantAttribute"]);
    
    await HandleExceptionAsync(context, exception);
}
```

If we now run the app logs will start getting pushed to elastic (make sure to also make a few requests so you get some errors!).

### Kibana

We can now visit `http://localhost:5601` to access kibana.

Once there, go to `Spaces > Manage Spaces` from the top right and select default. On the left you should see `Index patterns` and if you go there
you can essentially define the log pattern that you want kibana to consider, in my case that is `elk-development_*`. We can then go to
`Analytics > Discover` and voilà!

{{< image src="/img/cs_elk/logs.jpg" >}}

If you made the Exception data change mentioned earlier you should be able to see that as well

{{< image src="/img/cs_elk/data.jpg" >}}

The true power of this comes from how you can query your logs. You could for example query for `level: Error` to get all your error logs

{{< image src="/img/cs_elk/errors.jpg" >}}

You could also make queries like `fields.ElapsedMilliseconds > 10` or `fields.RequestPath: /weatherforecast`, you can read more about the
possible queries [here](https://www.elastic.co/guide/en/kibana/current/kuery-query.html).

One thing I always love spending way too much time on is visualizations and I can definitely see this being the most powerful feature in
Kibana

{{< image src="/img/cs_elk/plots.jpg" >}}

## Conclusion

Overall I think this was a pretty cool learning experience for me as I had never done proper error handling or used middleware before in
C## (or used docker hardware limits but we do not talk about that). I think that although I definitely see the ELK stack being invaluable
to a big company, I feel like I will not be using or recommend others to use if for small or personal projects as it is relatively hard
to set up locally and expensive to host (especially if before this you just had a single app instance running).

Long story short; it is definitely pretty cool but like normal logging should be enough for the majority of cases 👍.

And of course by no means will implementing all of this compensate for bad error handling.

Thanks for reading!

You can find the code [here](https://github.com/AntoniosBarotsis/elk).
