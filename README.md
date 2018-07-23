# Time Server
It's a ruby rack server that returns time in different cities

## How to run
Set up required gems by command below
```
bundle install
```

Then run server
```
ruby server.rb
```

## How to use
Open in your browser http://localhost:8080/time

You will recieve time in UTC. For example:
```
UTC: 2018-07-22 12:00:56
```

You can define cities you want to know time. You have list cities by separating them with commas.
For example:
http://localhost:8080/time?Moscow,New%20York

Will return:

```
UTC: 2018-07-22 12:06:51
Moscow: 2018-07-22 15:06:51
New York: 2018-07-22 08:06:51
```
