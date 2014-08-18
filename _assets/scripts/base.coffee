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
  maxJiggle: { top: 4, left: 4 }

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
    randomTop = @position.top + _.random(-@jiggleDistance, @jiggleDistance)
    randomLeft = @position.left + _.random(-@jiggleDistance, @jiggleDistance)
    @position.top = randomTop unless randomTop > @maxJiggle.top or randomTop < -@maxJiggle.top
    @position.left = randomLeft unless randomLeft > @maxJiggle.left or randomLeft < -@maxJiggle.left

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
    @isNavigable = false
    @letters = []
    @createLetters()
    if Modernizr.touch then @setupTouchHandler() else @setupHoverHandler()

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

  stopJiggling: ->
    for letter in @letters
      letter.stopJiggling()

  startJiggling: ->
    for letter in @letters
      letter.startJiggling()

  setupHoverHandler: ->
    navItem = this
    @elem.hover ->
      navItem.stopJiggling()
    , ->
      navItem.startJiggling()

  setupTouchHandler: ->
    navItem = this
    $aTags = navItem.elem.find('a')

    navItem.elem.click (ev) ->
      if !navItem.isNavigable
        navItem.stopJiggling()
        navItem.isNavigable = true

    $aTags.click (ev) ->
      ev.preventDefault() if !navItem.isNavigable

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

$ ->
  FastClick.attach(document.body)

  container = new Container
    elem: $('ul')
  animate(container)
