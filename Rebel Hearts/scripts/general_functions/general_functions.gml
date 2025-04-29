function controlsSetup()
{
	jumpBufferTime = 4;
	jumpKeyBuffered = 0;
	jumpKeyBufferTimer = 0;
}

function getControls()
{
	//Directions inputs
	rightKey = input_check("right");
		rightKey = clamp( rightKey, 0, 1 );
	leftKey = input_check("left");
		leftKey = clamp( leftKey, 0, 1 );
	downKey = input_check("down");
		downKey = clamp( downKey, 0, 1 );

	//Action inputs
	jumpKeyPressed = input_check_pressed ("accept");
		jumpKeyPressed = clamp( jumpKeyPressed, 0, 1 );
	jumpKey = input_check("accept");
		jumpKey = clamp( jumpKey, 0, 1 );
	runKey = input_check_double("left") || input_check_double("right");
		runKey = clamp( runKey, 0, 1 );
		

	//Jump key buffering
	if jumpKeyPressed
	{
		jumpKeyBufferTimer = jumpBufferTime;
	}
	if jumpKeyBufferTimer > 0
	{
		jumpKeyBuffered = 1;
		jumpKeyBufferTimer--;
	} else {
		jumpKeyBuffered = 0;
	}
}


