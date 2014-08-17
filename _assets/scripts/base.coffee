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

  transformCss: (newPosition) ->
    "translate(#{newPosition.left}px,#{newPosition.top}px)"

  constructor: (args) ->
    @elem = args.elem
    @navItem = args.navItem
    @position = { top: 0, left: 0 }

  animate: ->
    newPosition = {
      top: @position.top += _.random(-3, 3),
      left: @position.left += _.random(-3, 3),
    }
    @elem.css "-webkit-transform", @transformCss(newPosition)


class NavItem
  constructor: (args) ->
    @elem = args.elem
    @container = args.container
    @letters = @createLetters()

  createLetters: ->
    navItem = this
    letters = []
    @elem.find('span').each (i, letter) ->
      letter = new Letter
        elem: $(this)
        navItem: navItem
      letters.push letter
    return letters

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
