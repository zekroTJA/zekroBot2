Main = require '../main'
client = Main.client
Discord = require 'discord.js'
Embeds = require '../util/embeds'
Settings = require '../core/settings'


exports.ex = (msg, args) ->
    if args.length < 1
        Embeds.error msg.channel, "Please use `help game` to get information about this command!", "INVALID INPUT"
        return

    out = {}

    Settings.getGame (cb_curr) ->
        curr = cb_curr
        console.log curr
        switch args[0]
            when 'msg', 'name'
                if args.length > 1
                    curr.name = args[1..].join(' ') + " | #{Main.config.prefix}help"
                else
                    Embeds.error msg.channel, "Please enter a valid game name!", "INVALID INPUT"
                    return
            when 'type'
                validtypes = ['PLAYING', 'WATCHING', 'LISTENING', 'STREAMING']
                if args.length > 1 and validtypes.indexOf(args[1].toUpperCase()) > -1
                    curr.type = args[1].toUpperCase()
                else
                    Embeds.error msg.channel, "Please enter a valid game type!", "INVALID INPUT"
                    return
            when 'url'
                if args.length > 1
                    curr.url = args[1]
                else
                    Embeds.error msg.channel, "Please enter a valid game url!", "INVALID INPUT"
                    return

        console.log("curr after", curr)

        curr.name = if curr.name then curr.name else "zekro.de | #{Main.config.prefix}help"
        curr.type = if curr.type then curr.type else 'PLAYING'
        curr.url = if curr.url then curr.url else "https://twitch.tv/zekrotja"

        client.user.setActivity curr.name, {url: curr.url, type: curr.type}
        Embeds.default msg.channel, """
                                    Set game to 
                                    ```
                                    Name:    #{curr.name}
                                    Type:    #{curr.type}
                                    URL:     #{curr.url}
                                    ```
                                    """
        Settings.setGame curr, (cb) -> console.log cb