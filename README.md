# hubot-nerdbeers

The official **[Hubot][hubot]** script dedicated to the NerdBeers meetups.

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

- **hubot nerdbeers** - get the current OKC NerdBeers agenda
- **hubot okc nerdbeers** - get the current OKC NerdBeers agenda
- **hubot okcnerdbeers** - get the current OKC NerdBeers agenda
- **hubot nerdbeers cowsay** - get the current OKC NerdBeers agenda cowsay-style
- **hubot nerdbeers humans** - get the NerdBeers humans.txt
- **hubot nerdbeers suggestions** - get the recent NerdBeers suggestions
- **hubot nerdbeers suggest beer &lt;beer&gt;** - add a beer to the NerdBeers suggestions
- **hubot nerdbeers suggest topic &lt;topic&gt;** - add a topic to the NerdBeers suggestions
- **hubot nerdbeers help** - list the hubot nerdbeers commands

## Enjoy It

This is just for fun and community enjoyment.

##Improve It

Well, the bar isn't too high here. Feel free to help this script suck less by opening issues and/or sending pull requests. 

If you haven't already, be sure to checkout the **[Hubot scripting guide](https://github.com/github/hubot/blob/master/docs/scripting.md)** for tons of info about extending **[Hubot][hubot]**.

## Coding Style

Other than the 79 character line length limit, which I consider to be a suggestion, let's try to follow the **[CoffeeScript Style Guide](https://github.com/polarmobile/coffeescript-style-guide)**. 
