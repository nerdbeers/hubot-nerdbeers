# hubot-nerdbeers

An underwhelming **[Hubot][hubot]** script dedicated to the nerd beers meetups.

[hubot]: https://github.com/github/hubot

## Install

Install with **npm** using ```--save``` to add to your ```package.json``` dependencies.
```
	> npm install --save hubot-nerdbeers
```

Then add **"hubot-nerdbeers"** to your ```external-scripts.json```.

Example external-scripts.json
```json
["hubot-nerdbeers"]
```

Or if you prefer, just drop **nerdbeers.coffee** in your **[Hubot][hubot] scripts** folder and enjoy.

## Use It

- **hubot nerdbeers** - the known nerdbeers chapters
- **hubot nerdbeers < chapter-id >** - details of chapter
- **hubot nerdbeers agenda < chapter-id >** - agenda for the chapter
- **hubot okcnerdbeers** - shorthand for hubot nerdbeers okc
- **hubot okcnerdbeers agenda** - shorthand for hubot nerdbeers agenda okc

## Enjoy It

This is just for fun and community enjoyment.

##Improve It

Well, the bar isn't too high here. Feel free to help this script suck less by opening issues and/or sending pull requests. 

If you haven't already, be sure to checkout the **[Hubot scripting guide](https://github.com/github/hubot/blob/master/docs/scripting.md)** for tons of info about extending **[Hubot][hubot]**.

## Coding Style

Other than the 79 character line length limit, which I consider to be a suggestion, let's try to follow the **[CoffeeScript Style Guide](https://github.com/polarmobile/coffeescript-style-guide)**. 