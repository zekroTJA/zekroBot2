Main = require '../main'
client = Main.client
Discord = require 'discord.js'
Embeds = require '../util/embeds'


getRoles = (args, guild, msg) ->
    roles = []
    args.forEach (a) ->
        r = guild.roles.find (r) -> r.id == if a.indexOf('<@&') > -1 then a.replace(/[<>@&]/g, '') else a
        if !r
            r = guild.roles.find (r) -> r.name.toLowerCase().indexOf(a.toLowerCase()) > -1
        if r
            roles.push r
    return roles


exports.ex = (msg, args) ->
    guild = msg.member.guild
    chan = msg.channel

    if args.indexOf('list') == 0
        Main.mysql.query "SELECT * FROM perms WHERE guild = '#{guild.id}'", (err, res) ->
            if !err
                out_map = {}
                if res and res.length > 0
                    res.forEach (r) ->
                        # [
                        #    {role: '213123123', id:1}
                        #    {role: '123412344', id:1}
                        # ]
                        out_map[r.lvl] = if out_map[r.lvl] then "#{out_map[r.lvl]}, #{r.role}" else r.role
                    out = Object.keys(out_map).map((lvl) -> "#{lvl}  -  #{out_map[lvl]}").join('\n')
                else
                    out = "No role permissions defined."
                Embeds.default chan, out
            else
                Embeds.error chan, "An error occured while setting the values to the database: ```#{err}```", "UNEXPECTED ERROR"
        return

    if args.length < 2
        Embeds.error chan, "Please use `help perms` to get information about this command!", "INVALID INPUT"
        return

    if args[0] == "reset" and parseInt(args[1]) > 0
        Main.mysql.query "DELETE FROM perms WHERE guild = '#{guild.id}' && lvl = '#{args[1]}'"
        Embeds.default chan, "Reset roles for permission level **#{args[1]}**."
        return

    if parseInt(args[0]) < 1
        Embeds.error chan, "Please use `help perms` to get information about this command!", "INVALID INPUT"
        return

    lvl = args[0]
    if not parseInt(lvl) >= 0
        Embeds.error(chan, 'Please enter a valid level to set for role(s).')
        return

    roleinvs = args[1..].join(' ').split(',').map((s) -> s.replace(/^ /g, ''))

    roles = getRoles(roleinvs, guild, msg)
    if roles.length < 1
        Embeds.error chan, "Can not find any role with the identifiers ```#{args[1..].join(', ')}```", "INVALID INPUT"
        return

    Main.cmd.setPerms roles.map((r) -> r.id), lvl
    roles.forEach (r) ->
        Main.mysql.query "UPDATE perms SET lvl = '#{lvl}' WHERE role = '#{r.id}'", (err, res) ->
            if !err and res
                if res.affectedRows == 0
                    Main.mysql.query "INSERT INTO perms (role, lvl, guild) VALUES ('#{r.id}', '#{lvl}', '#{guild.id}')"
            else
                Embeds.error chan, "An error occured while setting the values to the database: ```#{err}```", "UNEXPECTED ERROR"
                return
    Embeds.default chan, "Successfully set roles ```#{roles.map((r) -> r.name).join(', ')}``` to permission level **#{lvl}**"


    # roleentry = roles.map((r) -> r.id).join(',')
    # Main.mysql.query "SELECT * FROM perms WHERE guild = '#{guild.id}' && lvl = '#{lvl}'", (err, res) ->
    #     if !err
    #         if res and res.length > 0
    #             Main.mysql.query "UPDATE perms SET roles = '#{roleentry}' WHERE guild = '#{guild.id}' && lvl = '#{lvl}'"
    #         else
    #             Main.mysql.query "INSERT INTO perms (guild, lvl, roles) VALUES ('#{guild.id}', '#{lvl}', '#{roleentry}')"
    #         Main.cmd.setPerms roles.map((r) -> r.id), lvl 
    #         Embeds.default chan, "Successfully set roles ```#{roles.map((r) -> r.name).join(', ')}``` to permission level **#{lvl}**"
    #     else
    #         Embeds.error chan, "An error occured while setting the values to the database: ```#{err}```", "UNEXPECTED ERROR"