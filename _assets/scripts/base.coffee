########## animation ##########

animationIds = []

animate = (container) ->
  for letter in container.letters
    letter.animate()

  # continue animation
  animationId = requestAnimationFrame -> animate(container)
  
  # save animation for easy cancelation
  animationIds.push animationId

stopAnimations = ->
  for id in animationIds
    cancelAnimationFrame(id)
  animationIds.length = 0

########## classes ##########

class Letter

  jiggleDistance: 2

  constructor: (args) ->
    @elem = args.elem
    @navItem = args.navItem
    @isClone = args.isClone
    @position = { top: 0, left: 0 }
    @startJiggling()

  animate: ->
    @randomizePosition() if @isJiggling
    @elem.css "transform", @transformCss()

  transformCss: ->
    "translate(#{@position.left}px,#{@position.top}px)"

  randomizePosition: ->
    @position.top += _.random(-@jiggleDistance, @jiggleDistance)
    @position.left += _.random(-@jiggleDistance, @jiggleDistance)

  stopJiggling: ->
    @elem.css "display", "none" if @isClone
    @elem.css "transition", "transform 0.1s linear"
    @position = { top: 0, left: 0 }
    @isJiggling = false

  startJiggling: ->
    @elem.css "display", ""
    @elem.css "transition", ""
    @isJiggling = true


class NavItem
  constructor: (args) ->
    @elem = args.elem
    @container = args.container
    @letters = []
    @createLetters()
    @setupHoverHandler()

  createLetters: ->
    navItem = this
    letters = []
    @elem.find('span').each ->
      letter = new Letter
        elem: $(this)
        navItem: navItem
      navItem.letters.push letter
      navItem.createCloneArmy(letter)

  createCloneArmy: (letter) ->
    _(2).times =>
      $clone = letter.elem.clone().appendTo letter.elem
      $clone.css
        position: 'absolute'
        left: 0
      clone = new Letter
        elem: $clone
        navItem: this
        isClone: true
      @letters.push clone

  setupHoverHandler: ->
    navItem = this
    @elem.hover ->
      for letter in navItem.letters
        letter.stopJiggling()
    , ->
      for letter in navItem.letters
        letter.startJiggling()

class Container
  constructor: (args) ->
    @elem = args.elem
    @width = @elem.width()
    @height = @elem.height()
    @offset = @elem.offset()
    @navItems = @createNavItems()
    @letters = @getLetters()

  createNavItems: ->
    navItems = []
    container = this
    @elem.find('li').each (i, navItem) ->
      navItem = new NavItem
        elem: $(this)
        offset: container.offset
        container: container
      navItems.push navItem
    return navItems

  getLetters: ->
    _.flatten(_.pluck(@navItems, 'letters'))

# init

container = new Container
  elem: $('ul')
animate(container)
