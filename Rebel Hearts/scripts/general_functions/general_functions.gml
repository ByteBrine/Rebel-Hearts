function controlsSetup()
{
	jumpBufferTime = 4;
	jumpKeyBuffered = 0;
	jumpKeyBufferTimer = 0;
}

function getControls()
{
	//Directions inputs
	rightKey = keyboard_check(ord("D")) + gamepad_button_check( 0, gp_padr );
		rightKey = clamp( rightKey, 0, 1 );
	leftKey = keyboard_check(ord("A")) + gamepad_button_check( 0, gp_padl );
		leftKey = clamp( leftKey, 0, 1 );
	downKey = keyboard_check(ord("S")) + gamepad_button_check( 0, gp_padd );
		downKey = clamp( downKey, 0, 1 );

	//Action inputs
	jumpKeyPressed = keyboard_check_pressed(vk_space) + gamepad_button_check_pressed( 0, gp_face1 );
		jumpKeyPressed = clamp( jumpKeyPressed, 0, 1 );
	jumpKey = keyboard_check(vk_space) + gamepad_button_check( 0, gp_face1 );
		jumpKey = clamp( jumpKey, 0, 1 );
	runKey = keyboard_check(ord("H")) + gamepad_button_check( 0, gp_face3 );
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
