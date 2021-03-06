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

Utils =

  random: (min, max) ->
    if (!max)
      max = min
      min = 0
    min + Math.floor(Math.random() * (max - min + 1))

class Letter

  jiggleDistance: 3
  maxJiggle: { top: 4, left: 4 }

  constructor: (args) ->
    @elem = args.elem
    @navItem = args.navItem
    @isClone = args.isClone
    @position = { top: 0, left: 0 }
    @startJiggling()

  animate: ->
    @randomizePosition() if @isJiggling
    @elem.style.transform = @transformCss()

  transformCss: ->
    "translate(#{@position.left}px,#{@position.top}px)"

  randomizePosition: ->
    randomTop = @position.top + Utils.random(-@jiggleDistance, @jiggleDistance)
    randomLeft = @position.left + Utils.random(-@jiggleDistance, @jiggleDistance)
    @position.top = randomTop # unless randomTop > @maxJiggle.top or randomTop < -@maxJiggle.top
    @position.left = randomLeft # unless randomLeft > @maxJiggle.left or randomLeft < -@maxJiggle.left

  stopJiggling: ->
    @elem.style.display = 'none' if @isClone
    @elem.style.transition = 'transform 0.1s linear'
    @position = { top: 0, left: 0 }
    @isJiggling = false

  startJiggling: ->
    @elem.style.display = ''
    @elem.style.transition = ''
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
    for $letter in @elem.querySelectorAll('span')
      letter = new Letter
        elem: $letter
        navItem: navItem
      navItem.letters.push letter
      navItem.createCloneArmy(letter)

  createCloneArmy: (letter) ->
    for i in [1..2]
      $clone = letter.elem.cloneNode(true)
      letter.elem.appendChild $clone
      $clone.style.position = 'absolute'
      $clone.style.left = 0

      clone = new Letter
        elem: $clone
        navItem: this
        isClone: true
      @letters.push clone

  stopJiggling: ->
    @elem.style.zIndex = 1
    for letter in @letters
      letter.stopJiggling()

  startJiggling: ->
    @elem.style.zIndex = 0
    for letter in @letters
      letter.startJiggling()

  setupHoverHandler: ->
    navItem = this
    @elem.onmouseover = -> navItem.stopJiggling()
    @elem.onmouseout = ->  navItem.startJiggling()

  setupTouchHandler: ->
    navItem = this
    $aTags = navItem.elem.querySelectorAll('a')

    navItem.elem.onclick = ->
      if !navItem.isNavigable
        navItem.stopJiggling()
        navItem.isNavigable = true

    $aTags.onclick = (ev) ->
      ev.preventDefault() if !navItem.isNavigable

class Container
  constructor: (args) ->
    @elem = args.elem[0]
    @width = @elem.offsetWidth
    @height = @elem.offsetHeight
    @offset =
      top: @elem.offsetTop
      left: @elem.offsetLeft
    @navItems = @createNavItems()
    @letters = @getLetters()

  createNavItems: ->
    navItems = []
    container = this
    for $li in @elem.querySelectorAll('li')
      navItem = new NavItem
        elem: $li
        offset: container.offset
        container: container
      navItems.push navItem
    return navItems

  getLetters: ->
    arrayOfLetterArrays = (navItem.letters for navItem in @navItems)
    arrayOfLetterArrays.reduce (a, b) -> a.concat(b)

# init

FastClick.attach(document.body)

container = new Container
  elem: document.querySelectorAll('ul')
animate(container)
