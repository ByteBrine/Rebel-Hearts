//Get inputs
getControls();

//Interacting with moving platforms after they have already moved in the "begin step event"
#region
	//Get out of solid moveplats that have positioned themselves into the player in the begin step
	#region
		var _rightWall = noone;
		var _leftWall = noone;
		var _bottomWall = noone;
		var _topWall = noone;
		var _list = ds_list_create();
		var _listSize = instance_place_list( x, y, oMovePlat, _list, false );

		//Loop through all colliding moving platforms
		for( var i = 0; i < _listSize; i++ )
		{
			var _listInst = _list[| i];
		
			//Find closest walls in each direction
				//Right walls
				if _listInst.bbox_left - _listInst.xspd >= bbox_right-1
				{
					if !instance_exists(_rightWall) || _listInst.bbox_left < _rightWall.bbox_left
					{
						_rightWall = _listInst;	
					}
				}
				//Left walls
				if _listInst.bbox_right - _listInst.xspd <= bbox_left+1
				{
					if !instance_exists(_leftWall) || _listInst.bbox_right > _leftWall.bbox_right
					{
						_leftWall = _listInst;
					}
				}
				//Bottom Wall
				if _listInst.bbox_top - _listInst.yspd >= bbox_bottom-1
				{
					if !_bottomWall || _listInst.bbox_top < _bottomWall.bbox_top
					{
						_bottomWall = _listInst;
					}
				}
				//Top
				if _listInst.bbox_bottom - _listInst.yspd <= bbox_top+1
				{
					if !_topWall || _listInst.bbox_bottom > _topWall.bbox_bottom
					{
						_topWall = _listInst;
					}
				}
		}
	
		//destroy the ds list to free memory
		ds_list_destroy(_list);
	
		//Get out of the walls
			//Right wall
			if instance_exists(_rightWall)
			{
				var _rightDist = bbox_right - x;
				x = _rightWall.bbox_left - _rightDist;
			}
			//Left wall
			if instance_exists(_leftWall)
			{
				var _leftDist = x - bbox_left;
				x = _leftWall.bbox_right + _leftDist;
			}
			//Bottom Wall
			if instance_exists(_bottomWall)
			{
				var _bottomDist = bbox_bottom - y;
				y = _bottomWall.bbox_top - _bottomDist;
			}
			//Top Wall ( includes, collision for polish and crouching features )
			if instance_exists(_topWall)
			{
				var _upDist = y - bbox_top;
				var _targetY = _topWall.bbox_bottom + _upDist;
				//Check if there isn't a wall in the way
				if !place_meeting( x, _targetY, oWall )  
				{
					y = _targetY;	
				}
			}
	#endregion

	//Don't get left behind by my moveplat!!
	earlyMoveplatXspd = false;
	if instance_exists( myFloorPlat ) && myFloorPlat.xspd != 0 && !place_meeting( x, y + moveplatMaxYspd+1, myFloorPlat )
	{
		var _xCheck = myFloorPlat.xspd;
		//Go ahead and move ourselves back onto that platform if there is no wall in the way
		if !place_meeting( x + _xCheck, y, oWall )
		{
			x += _xCheck;
			earlyMoveplatXspd = true;
		}
	}
#endregion


//Crouching
#region
	//Transition to crouch
		//Manual = downKey | Automatic = wall collision
		if onGround && (downKey ||  place_meeting(x, y, oWall))
		{
			crouching = true;
		}
		//Change collision mask
		if crouching { mask_index = crouchSpr; };
		
	//Transition out of crouching
		//Manual = !downKey | Automatic = !onGround
		if crouching && (!downKey || !onGround)
		{
			//Check if I CAN uncrouch	
			mask_index = idleSpr;
			//Uncrouch if no solid wall in the way
			if !place_meeting(x, y, oWall)
			{
				crouching = false;
			}
			//Go back to crouching mask index if we can't uncrouch
			else
			{
				mask_index = crouchSpr;
			}
		}
#endregion


//X Movement
#region
	//Direction
	moveDir = rightKey - leftKey;
	
	//Get my face
	if moveDir != 0 { face = moveDir; };
	
	//Get xspd
	runType = runKey;
	xspd = moveDir * moveSpd[runType];
	//Stop xspd if crouching
	if crouching { xspd = 0; };
	
	//X collision
	var _subPixel = .5;
	if place_meeting( x + xspd, y, oWall )
	{
		//First check if there is a slope to go up
		if !place_meeting( x + xspd, y - abs(xspd)-1, oWall )
		{
			while place_meeting( x + xspd, y, oWall ) { y -= _subPixel; };
		}
		//Next, check for ceiling slopes, otherwise, do a regular collision
		else
		{
			//Ceiling Slopes
			if !place_meeting( x + xspd, y + abs(xspd)+1, oWall )
			{
				while place_meeting( x + xspd, y, oWall ) { y += _subPixel; };
			}
			//Normal Collision
			else
			{
				//Scoot up to wall precisely
				var _pixelCheck = _subPixel * sign(xspd);
				while !place_meeting( x + _pixelCheck, y, oWall ) { x += _pixelCheck; };
	
				//Set xspd to zero to "collide"
				xspd = 0;
			}
		}
	}
	
	//Go Down Slopes
	downSlopeSemiSolid = noone;
	if yspd >= 0 && !place_meeting( x + xspd, y + 1, oWall ) && place_meeting( x + xspd, y + abs(xspd)+1, oWall )
	{
		//Check for a semisolid in the way
		downSlopeSemiSolid = checkForSemisolidPlatform( x + xspd, y + abs(xspd)+1 );
		//Precisely move down slope if there isn't a semisolid in the way
		if !instance_exists(downSlopeSemiSolid)
		{
			while !place_meeting( x + xspd, y + _subPixel, oWall ) { y += _subPixel; };
		} 
	}
	
	//Move 
	x += xspd;
#endregion
	
	
//Y Movement
#region
	//Gravity
	if coyoteHangTimer > 0
	{
		//Count the timer down
		coyoteHangTimer--;
	} else {
		//Apply gravity to the player
		yspd += grav;
		//We're no longer on the ground
		setOnGround(false);
	}
	
	//Reset/Prepare jumping variables
	if onGround
	{
		jumpCount = 0;	
		coyoteJumpTimer = coyoteJumpFrames;
		jumpHoldTimer = 0;
	} else {
		//If the player is in the air, make sure they can't do an extra jump
		coyoteJumpTimer--;
		if jumpCount == 0 && coyoteJumpTimer <= 0 { jumpCount = 1; };
	}
	
	//Initiate the Jump
	var _floorIsSolid = false;
	if instance_exists(myFloorPlat)
	&& ( myFloorPlat.object_index == oWall || object_is_ancestor(myFloorPlat.object_index, oWall) )
	{
		_floorIsSolid = true;
	}
	if jumpKeyBuffered && jumpCount < jumpMax && ( !downKey || _floorIsSolid )
	{
		//Reset the buffer
		jumpKeyBuffered = false;
		jumpKeyBufferTimer = 0;
		//Increase the number of performed jumps
		jumpCount++;
		//Set the jump hold timer
		jumpHoldTimer = jumpHoldFrames[jumpCount-1];
		//Tell ourself we're no longer on the ground
		setOnGround(false);
	}
	//Jump based on the timer/holding the button
	if jumpHoldTimer > 0 
	{
		//Constantly set the yspd to be jumping speed
		yspd = jspd[jumpCount-1];
		//Count down the timer
		jumpHoldTimer--;
	}
	//Cut off the jump by releasing the jump button
	if !jumpKey
	{
		jumpHoldTimer = 0;
	}

	//Y Collision and final movement
	#region
		//Cap falling speed
		if yspd > termVel { yspd = termVel; };
		
		//Y Collision
		var _subPixel = .5;
		
		//Upwards Y Collision (with ceiling slopes)
		if yspd < 0 && place_meeting( x, y + yspd, oWall ) 
		{
			//Jump into sloped ceilings
			var _slopeSlide = false;

			//Slide UpLeft slope
			if moveDir == 0 && !place_meeting( x - abs(yspd)-1, y + yspd, oWall )
			{
				while place_meeting( x, y + yspd, oWall ) { x -= 1; };
				_slopeSlide = true;
			}
			
			//Slide UpRight slope
			if moveDir == 0 && !place_meeting( x + abs(yspd)+1, y + yspd, oWall )
			{
				while place_meeting( x, y + yspd, oWall ) { x += 1; };	
				_slopeSlide = true;
			}
			
			//Normal Y collision
			if !_slopeSlide
			{
				//Scoot up to the wall precisely
				var _pixelCheck = _subPixel * sign(yspd);
				while !place_meeting( x, y + _pixelCheck, oWall )
				{
					y += _pixelCheck;	
				}
			
				//Bonk (OPTIONAL)
				//if yspd < 0 { jumpHoldTimer = 0; };
			
				//Set yspd to 0 to collide
				yspd = 0;
			}
		}
		

		//Floor Y Collision
			//Check for solid and semisolid platforms under me
			var _clampYspd = max( 0, yspd );
			var _list = ds_list_create(); // Create a DS list to store all of the objects we run into
			var _array = array_create(0);
			array_push( _array, oWall, oSemiSolidWall );
		
			//Do the actual check and add objects to list
			var _listSize = instance_place_list( x, y+1 + _clampYspd + moveplatMaxYspd, _array, _list, false );
		
				/////////(FIX FOR HIGH RESOLUTION/HIGH SPEED PROJECTS - same principal as how i fixed that downwards slope issue) Check for a semisolid plat below me
				var _yCheck = y+1 + _clampYspd;
				if instance_exists(myFloorPlat) { _yCheck += max(0, myFloorPlat.yspd); };
				var _semiSolid = checkForSemisolidPlatform(x, _yCheck );
			
			//Loop through the colliding instances and only return one if it's top is bellow the player
			for( var i = 0; i < _listSize; i++ )
			{
				//Get an instance of oWall or oSemiSolidWall from the list
				var _listInst = _list[| i];
			
				//Avoid magnetism
				if (_listInst != forgetSemiSolid
				&& ( _listInst.yspd <= yspd || instance_exists(myFloorPlat) )
				&& ( _listInst.yspd > 0 || place_meeting( x, y+1 + _clampYspd, _listInst ) ))
				|| (_listInst == _semiSolid)/////////(HIGH SPEED FIX)
				{
					//Return a solid wall or any semisolid walls that are below the player
					if _listInst.object_index == oWall
					|| object_is_ancestor( _listInst.object_index, oWall )
					|| floor(bbox_bottom) <= ceil(_listInst.bbox_top - _listInst.yspd)
					{
						//Return the "highest" wall object
						if !instance_exists(myFloorPlat)
						|| _listInst.bbox_top + _listInst.yspd <= myFloorPlat.bbox_top + myFloorPlat.yspd
						|| _listInst.bbox_top + _listInst.yspd <= bbox_bottom
						{
							myFloorPlat = _listInst;
						}
					}
				}
			}
			//Destroy the DS list to avoid a memory leak
			ds_list_destroy(_list);
		
			//Downslope semisolid for making sure we don't miss semisolid's while going down slopes
			if instance_exists(downSlopeSemiSolid) { myFloorPlat = downSlopeSemiSolid; };
		
			//One last check to make sure the floor platform is actually below us
			if instance_exists(myFloorPlat) && !place_meeting( x, y + moveplatMaxYspd, myFloorPlat )
			{
				myFloorPlat = noone;
			}
		
			//Land on the ground platform if there is one
			if instance_exists(myFloorPlat)
			{
				//Scoot up to our wall precisely
				var _subPixel = .5;
				while !place_meeting( x, y + _subPixel, myFloorPlat ) && !place_meeting( x, y, oWall ) { y += _subPixel; };
				//Make sure we don't end up below the top of a semisolid
				if myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor(myFloorPlat.object_index, oSemiSolidWall)
				{
					while place_meeting( x, y, myFloorPlat ) { y -= _subPixel; };
				}
				//Floor the y variable
				y = floor(y);
			
				//Collide with the ground
				yspd = 0;
				setOnGround(true);
			}
		
		//Manually Fall Through a semisolid platform
		if downKey && jumpKeyPressed
		{
			//Make sure we have a floor platform thats a semisolid
			if instance_exists(myFloorPlat)
			&& ( myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor(myFloorPlat.object_index, oSemiSolidWall) )
			{
				//Check if we CAN go below the semisolid
				var _yCheck = max( 1, myFloorPlat.yspd+1 );
				if !place_meeting( x, y + _yCheck, oWall )
				{
					//Move below the platform
					y += 1;
					
					//Inherit any downward speed from my floor platform so it doesn't catch me
					yspd = _yCheck-1;
					
					//Forget this platform for a brief time so we don't get caught again
					forgetSemiSolid = myFloorPlat;
					
					//No more floor platform
					setOnGround(false);
				}
			}
		}

		//Move
		if !place_meeting( x, y + yspd, oWall ) { y += yspd; };
		
		//Reset forgetSemiSolid variable
		if instance_exists(forgetSemiSolid) && !place_meeting(x, y, forgetSemiSolid)
		{
			forgetSemiSolid = noone;
		}
	#endregion
#endregion
	
		
//Final moving platform collisions and movement
#region
	//X - moveplatXspd and collision
		//Get the moveplatXspd
		moveplatXspd = 0;
		if instance_exists(myFloorPlat) { moveplatXspd = myFloorPlat.xspd; };
	
		//Move with moveplatXspd
		if !earlyMoveplatXspd
		{
			if place_meeting( x + moveplatXspd, y, oWall )
			{
				//Scoot up to wall precisely	
				var _subPixel = .5;
				var _pixelCheck = _subPixel * sign(moveplatXspd);
				while !place_meeting( x + _pixelCheck, y, oWall )
				{
					x += _pixelCheck;
				}
		
				//Set moveplatXspd to 0 to finish collision
				moveplatXspd = 0;
			}
			//Move
			x += moveplatXspd;
		}

	//Y - Snap myself to myFloorPlat if is a moving platform or it's moving vertically
	if instance_exists(myFloorPlat) 
	&& (myFloorPlat.yspd != 0
	|| myFloorPlat.object_index == oMovePlat
	|| object_is_ancestor(myFloorPlat.object_index, oMovePlat)
	|| myFloorPlat.object_index == oSemiSolidMovePlat
	|| object_is_ancestor(myFloorPlat.object_index, oSemiSolidMovePlat) )
	{
		//Snap to the top of the floor platform ( un-floor our y variable so it's not choppy )
		if !place_meeting( x, myFloorPlat.bbox_top, oWall )
		&& myFloorPlat.bbox_top >= bbox_bottom-moveplatMaxYspd
		{
			y = myFloorPlat.bbox_top;
		}
		
		/*This section of code was seemingly ultimately made redundant by
		the code block directly below "Get pushed down through a semisolid by a moving solid platform"
		I'm just leaving it here for you to reference in the video when we first cover it!//*/
							/*/Going up into a solid wall while on a semisolid platform
							if myFloorPlat.yspd < 0 && place_meeting(x, y + myFloorPlat.yspd, oWall)
							{
								//Get pushed down through the semisolid floor platform
								if myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor(myFloorPlat.object_index, oSemiSolidWall)
								{
									//Get pushed down through the semisolid
									var _subPixel = .25;
									while place_meeting( x, y + myFloorPlat.yspd, oWall ) { y += _subPixel; };
									//If we got pushed into a solid wall while goign downwards, push ourselfves back out
									while place_meeting( x, y, oWall ) { y -= _subPixel; };
									y = round(y);
								}
			
								//Cancel the myFloorPlat variable
								setOnGround(false);
							}//*/
	}
	
	//Get pushed down through a semisolid by a moving solid platform
	if instance_exists( myFloorPlat )
	&& ( myFloorPlat.object_index == oSemiSolidWall || object_is_ancestor(myFloorPlat.object_index, oSemiSolidWall) )
	&& place_meeting( x, y, oWall )
	{
		//If I'm already stuck in a wall at this point, try and move me down to get below a semisolid
		//If I'm still stuck afterwards, that just means I've been properly "crushed"
		
		//Also, don't check too far, we dont want to warp below walls
		var _maxPushDist = 10;//Basically the fastest a moveplat should be able to move downwards
		var _pushedDist = 0;
		var _startY = y;
		while place_meeting( x, y, oWall ) && _pushedDist <= _maxPushDist
		{
			y++;
			_pushedDist++;
		}
		//Forget myFloorPlat
		myFloorPlat = false;
		
		//If I'm still in a wall at this point, I've been crushed regardless, take me back to my start y to avoid the funk
		if _pushedDist > _maxPushDist { y = _startY; };
	}
#endregion


	//Check if I'm "crushed" by turning blue
	//You don't need this code, just here to check stuff!
	image_blend = c_white;
	if place_meeting(x, y, oWall)
	{
		image_blend = c_blue;	
	}


//Sprite Control
	//Walking
	if abs(xspd) > 0 { sprite_index = walkSpr; };
	//Running
	if abs(xspd) >= moveSpd[1] { sprite_index = runSpr; };
	//Not moving
	if xspd == 0 { sprite_index = idleSpr; };
	//In the air
	if !onGround { sprite_index = jumpSpr; };
	//Crouching
	if crouching { sprite_index = crouchSpr; };
		//set the collision mask
		mask_index = maskSpr;
		if crouching { mask_index = crouchSpr; };

