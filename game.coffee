# Coffee Inc style clicker game skeleton in CoffeeScript

class Game
  constructor: ->
    @money = 0
    @coffeePerClick = 1
    @coffeePerSecond = 0
    @upgrades = [
      name: 'Better Beans'
      cost: 15
      cps: 0
      cpc: 1
    ,
      name: 'Fancy Grinder'
      cost: 100
      cps: 2
      cpc: 0
    ]
    @tickInterval = null
    @lastTick = Date.now()

  start: ->
    return if @tickInterval?
    @lastTick = Date.now()
    @tickInterval = setInterval(@tick, 1000 / 30)

  stop: ->
    return unless @tickInterval?
    clearInterval @tickInterval
    @tickInterval = null

  reset: ->
    @money = 0
    @coffeePerClick = 1
    @coffeePerSecond = 0
    @upgrades.forEach (upgrade) -> upgrade.level = 0

  click: ->
    @money += @coffeePerClick
    @render()

  purchase: (upgradeIndex) ->
    upgrade = @upgrades[upgradeIndex]
    return unless upgrade?
    upgrade.level ?= 0
    return if @money < upgrade.cost

    @money -= upgrade.cost
    upgrade.level += 1
    @coffeePerClick += upgrade.cpc if upgrade.cpc?
    @coffeePerSecond += upgrade.cps if upgrade.cps?
    @render()

  tick: =>
    now = Date.now()
    deltaSeconds = (now - @lastTick) / 1000
    @lastTick = now

    @money += @coffeePerSecond * deltaSeconds
    @render()

  render: ->
    console.clear()
    console.log "☕ Coffee Inc"
    console.log "Beans: #{Math.floor @money}"
    console.log "Per Click: #{@coffeePerClick}"
    console.log "Per Second: #{@coffeePerSecond.toFixed 1}"
    console.log '\nUpgrades:'
    @upgrades.forEach (upgrade, index) =>
      upgrade.level ?= 0
      console.log "#{index + 1}. #{upgrade.name} (Cost: #{upgrade.cost}) Level: #{upgrade.level}"

  handleInput: (key) ->
    switch key
      when 'c' then @click()
      when 'q' then @stop()
      else
        index = parseInt(key, 10) - 1
        if index >= 0 then @purchase index

# Example usage when running via node
if require?.main is module
  readline = require 'readline'
  game = new Game()
  game.start()

  rl = readline.createInterface
    input: process.stdin
    output: process.stdout

  console.log "Welcome to Coffee Inc!"
  console.log "Press 'c' to collect beans, number keys to buy upgrades, 'q' to quit."

  process.stdin.setRawMode true
  process.stdin.resume()
  process.stdin.on 'data', (buffer) ->
    key = buffer.toString().trim()
    if key is 'q'
      game.stop()
      rl.close()
      process.exit 0
    else
      game.handleInput key
