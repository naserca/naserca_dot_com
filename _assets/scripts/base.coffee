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

  constructor: (args) ->
    @elem = args.elem
    @navItem = args.navItem
    @position = { top: 0, left: 0 }
    @startJiggling()

  animate: ->
    @randomizePosition() if @isJiggling
    @elem.css "transform", @transformCss()

  transformCss: ->
    "translate(#{@position.left}px,#{@position.top}px)"

  randomizePosition: ->
    @position.top += _.random(-2, 2)
    @position.left += _.random(-2, 2)

  stopJiggling: ->
    @elem.css "transition", "transform 0.1s linear"
    @position = { top: 0, left: 0 }
    @isJiggling = false

  startJiggling: ->
    @elem.css "transition", ""
    @isJiggling = true


class NavItem
  constructor: (args) ->
    @elem = args.elem
    @container = args.container
    @createCloneArmy()
    @letters = @createLetters()
    @setupHoverHandler()

  createCloneArmy: ->
    @elem.find('span').each ->
      $span = $(this)
      _(1).times ->
        clone = $span.clone().appendTo $span
        clone.css
          position: 'absolute'
          left: 0

  createLetters: ->
    navItem = this
    letters = []
    @elem.find('span').each (i, letter) ->
    @elem.find('span').each ->
      letter = new Letter
        elem: $(this)
        navItem: navItem
      letters.push letter
    return letters

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
