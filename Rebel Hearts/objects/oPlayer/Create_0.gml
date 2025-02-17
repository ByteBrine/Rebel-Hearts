//Custom functions for player
function setOnGround(_val = true)
{
	if _val == true
	{
		onGround = true;
		coyoteHangTimer = coyoteHangFrames;
	} else {
		onGround = false;
		myFloorPlat = noone;
		coyoteHangTimer = 0;
	}
}
function checkForSemisolidPlatform(_x, _y)
{
	//Create a return variable
	var _rtrn = noone;
	
	//We must not be moving upwards, and then we check for a normal collision
	if yspd >= 0 && place_meeting(_x, _y, oSemiSolidWall)
	{
		//Creat a ds list to store all colliding instances of oSemiSolidWall
		var _list = ds_list_create();
		var _listSize = instance_place_list(_x, _y, oSemiSolidWall, _list, false);
		
		//Loop through the colliding instances and only return one of it's top is below the player
		for( var i = 0; i < _listSize; i++ )
		{
			var _listInst = _list[| i];
			if _listInst != forgetSemiSolid && floor(bbox_bottom) <= ceil( _listInst.bbox_top - _listInst.yspd )
			{
				//Return the id of a semisolid platform
				_rtrn = _listInst;
				//Exit the loop early
				i = _listSize;
			}
		}
		
		//destroy ds list to free memory
		ds_list_destroy(_list);
	}
	
	//Return our variable
	return _rtrn;
}

//depth = -30;

//Control setup
controlsSetup();

//Sprites
maskSpr = sPlayerIdle;
idleSpr = sPlayerIdle;
walkSpr = sPlayerWalk;
runSpr = sPlayerRun;
jumpSpr = sPlayerJump;
crouchSpr = sPlayerCrouch;

//Moving
face = 1;
moveDir = 0;
runType = 0;
moveSpd[0] = 2;
moveSpd[1] = 3.5;
xspd = 0;
yspd = 0;

//State variables
crouching = false;

//Jumping
	grav = .275;
	termVel = 4;
	onGround = true;
	jumpMax = 1;
	jumpCount = 0;
	jumpHoldTimer = 0;
		//Jump values for each successive jump
		jumpHoldFrames[0] = 18;
		jspd[0] = -3.15;
		jumpHoldFrames[1] = 10;
		jspd[1] = -2.85;
	
	//Coyote Time
	//Hang time
	coyoteHangFrames = 2;
	coyoteHangTimer = 0;
	//Jump buffer time
	coyoteJumpFrames = 4;
	coyoteJumpTimer = 0;

//Moving Platforms
myFloorPlat = noone;
earlyMoveplatXspd = false;
downSlopeSemiSolid = noone;
forgetSemiSolid = noone;
moveplatXspd = 0;
moveplatMaxYspd = termVel; // How fast can the player follow a downwards moving platform
crushTimer = 0;
crushDeathTime = 3;