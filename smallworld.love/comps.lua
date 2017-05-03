local Comp = require 'ecs/component'

Comp.define("bounds", {'offx',0,'offy',0,'w',0,'h',0})
Comp.define("scale", {'sx',1,'sy',1})
Comp.define("pos", {'x',0,'y',0})
Comp.define("vel", {'dx',0,'dy',0})

Comp.define("tag", {})

Comp.define("player", {})

Comp.define("timer", {'t',0, 'reset',0, 'countDown',true, 'loop',false, 'alarm',false})

Comp.define("controller", {'id','','leftx',0,'lefty',0,})

Comp.define("img", {'imgId','','offx',0,'offy',0,'sx',1,'sy',1,'r',0,'color',{255,255,255}})
Comp.define("sprite", {'spriteId','','frame','','offx',0,'offy',0,'sx',1,'sy',1,'r',0})

Comp.define("label", {'text','Label', 'color', {0,0,0},'font',nil, 'width', nil, 'align',nil, 'height',nil,'valign',nil})

Comp.define("circle", {'offx',0,'offy',0,'radius',0, 'color',{0,0,0}})
Comp.define("rect", {'offx',0,'offy',0,'w',0, 'h',0, 'color',{0,0,0}, 'style','fill'})

Comp.define("event", {'data',''})

Comp.define("output", {'kind',''})

Comp.define("debug", {'value',''})

Comp.define("map",{'id',''})
Comp.define("collidable", {})

Comp.define('script',{'script',''})
