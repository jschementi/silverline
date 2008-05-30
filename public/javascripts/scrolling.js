Effect.Scroll = Class.create(); 
Object.extend(Object.extend(Effect.Scroll.prototype, Effect.Base.prototype), { 
  initialize: function(element) { 
    this.element = $(element); 
    var options = Object.extend({ 
      x:    0, 
      y:    0, 
      mode: 'absolute' 
    } , arguments[1] || {}  ); 
    this.start(options); 
  }, 
  setup: function() { 
    if (this.options.continuous && !this.element._ext ) { 
      this.element.cleanWhitespace(); 
      this.element._ext=true; 
      this.element.appendChild(this.element.firstChild); 
    } 
     
    this.originalLeft=this.element.scrollLeft; 
    this.originalTop=this.element.scrollTop; 
     
    if(this.options.mode == 'absolute') { 
      this.options.x -= this.originalLeft; 
      this.options.y -= this.originalTop; 
    } else { 
     
    } 
  }, 
  update: function(position) {     
    this.element.scrollLeft = this.options.x * position + this.originalLeft; 
    this.element.scrollTop  = this.options.y * position + this.originalTop; 
  } 
}); 

function moveTo(container, element) {
  Position.prepare();
  container_y = Position.cumulativeOffset($(container))[1]
  element_y = Position.cumulativeOffset($(element))[1]
  new Effect.Scroll(container, {x:0, y:(element_y-container_y)});
  return false;
}
