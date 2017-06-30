//dmesg.qc

void() shot_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " was holepunched by ";
		dmesg2 = "'s slug\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " was penetrated by ";
		dmesg2 = "'s thick round\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " was stopped by ";
		dmesg2 = "'s shotgun\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " really felt ";
		dmesg2 = "'s slug\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " was through-holed by ";
		dmesg2 = "'s round\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " accepted ";
		dmesg2 = "'s hard slug\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() shot2_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " was splattered against the wall by ";
		dmesg2 = "'s boomstick\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " was blended into a smoothie by ";
		dmesg2 = "'s buckshot\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " was turned into a spray by ";
		dmesg2 = "'s double barrel\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " got vicerated by ";
		dmesg2 = "'s boomstick\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " was blown apart by ";
		dmesg2 = "'s buckshot\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " accepted ";
		dmesg2 = "'s super spray\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() axe_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " was chopped up ";
		dmesg2 = "'s axe\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " was saladified by ";
		dmesg2 = "'s chopper\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " was torn apart by ";
		dmesg2 = "\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " got gashed by ";
		dmesg2 = "'s axe\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " was loped apart by ";
		dmesg2 = "'s chopper\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " took in ";
		dmesg2 = "'s blade\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() nail_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " didn't notice ";
		dmesg2 = "'s trap\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " stepped on one too many of ";
		dmesg2 = "'s nails\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " got spiked by ";
		dmesg2 = "\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " fell into ";
		dmesg2 = "'s trap\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " felt ";
		dmesg2 = "'s pins and needles\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " was humiliated by ";
		dmesg2 = "'s trap\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() nail2_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " was gattled down by ";
		dmesg2 = "'s machinegun\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " became ";
		dmesg2 = "'s swiss cheese\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " became ";
		dmesg2 = "'s sponge\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " became holy from ";
		dmesg2 = "'s machinegun\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " was punctured by ";
		dmesg2 = "'s machinegun\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " consumed too much of ";
		dmesg2 = "'s bullet spray\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() gl_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " ate ";
		dmesg2 = "'s pineapple\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " got a little too close to ";
		dmesg2 = "'s grenade\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " tried catching ";
		dmesg2 = "'s grenade\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " was blown up by ";
		dmesg2 = "'s grenade\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " tried to throw back ";
		dmesg2 = "'s grenade\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " simply couldn't avoid ";
		dmesg2 = "'s grenade\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() rl_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " got rocketed by ";
		dmesg2 = "\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " tried to dodge ";
		dmesg2 = "'s rocket\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " went to space on ";
		dmesg2 = "'s rocket\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " thrown about by ";
		dmesg2 = "'s rocket\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " got a facefull of ";
		dmesg2 = "'s rocket\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " tried to catch ";
		dmesg2 = "'s rocket\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};

void() lg_dmesg =
{
float	rnd;

	rnd = floor(random()*5)+1;
	
	if (rnd == 1)
	{
		dmesg1 = " was zapped by ";
		dmesg2 = "'s lightning gun\n";
	}
	else if (rnd == 2)
	{
		dmesg1 = " accepted ";
		dmesg2 = "'s shaft\n";
	}
	else if (rnd == 3)
	{
		dmesg1 = " felt ";
		dmesg2 = "'s discharge\n";
	}
	else if (rnd == 4)
	{
		dmesg1 = " couldn't escape ";
		dmesg2 = "'s bolt\n";
	}
	else if (rnd == 5)
	{
		dmesg1 = " felt the electricity of ";
		dmesg2 = "'s lightning gun\n";
	}
	else if (rnd == 6)
	{
		dmesg1 = " showed how ";
		dmesg2 = "'s is the new Zeus\n";
	}
	else
	{
		dmesg1 = "err";
		dmesg2 = "err\n";
	}

};
