//Move in a circle
dir += rotSpd;

//Get our target positions
var _targetX = xstart + lengthdir_x( radius, dir );
var _targetY = ystart + lengthdir_y( radius, dir );

//Get our xspd and yspd
xspd = _targetX - x;
if !moveOnXAxis { xspd = 0; };
yspd = _targetY - y;
if !moveOnYAxis { yspd = 0; };

//Move
x += xspd;
y += yspd;