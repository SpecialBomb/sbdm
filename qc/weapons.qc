/*
*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 20);
		if (!deathmatch)
		{
		T_Damage (trace_ent, self, self, 20);
		}
		else
		{
		if (deathmatch == 3){
			T_Damage (trace_ent, self, self, 1000);
		}
		else {
		T_Damage (trace_ent, self, self, 80);
		}
		}
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile, mpuff;
//	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	org = trace_endpos - dir*4;
	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread, float dpp) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	//src = self.origin + v_forward*10;
	//src_z = self.absmin_z + self.size_z * 0.7;
	src = self.origin+self.view_ofs;
	
	ClearMultiDamage ();
	while (shotcount > 0)
	{
		
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (dpp, direction);
			
		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	//self.punchangle_x = -2;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	if (!deathmatch){
	FireBullets (6, dir, '0.04 0.04 0', 4);
	}
	else
	{
	FireBullets (1, dir, '0 0 0', 40);
	}
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	//self.punchangle_x = -4;
	
	if (deathmatch != 5)
		self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	if (!deathmatch)
	{
	FireBullets (14, dir, '0.14 0.08 0', 4);
	}
	else
	{
	if(self.items & IT_QUAD) {
		self.velocity = (-dir*600)+self.velocity;
	}
	else {
		self.velocity = (-dir*150)+self.velocity;
	}
	//if (deathmatch != 5)
		FireBullets (15, dir, '0.16 0.16 0', (20/3));
	}
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 120;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};



/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile, mpuff;
	
	if (deathmatch != 5)
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	//self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors (self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = T_MissileTouch;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;
          missile.weaponmodel = self.weaponmodel;
	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + self.view_ofs + v_forward*8);
	//setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};

void() Lshoot =
{
	local	vector		src;
	//org = self.origin + '0 0 16';
	src = self.origin+self.view_ofs;
	
	traceline (src, src + v_forward*2000, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, src_x);
	WriteCoord (MSG_BROADCAST, src_y);
	WriteCoord (MSG_BROADCAST, src_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	
	if (deathmatch == 4)
	{
		LightningDamage (src, trace_endpos + v_forward*4, self, 1000);
	}
	else
	{
		LightningDamage (src, trace_endpos + v_forward*4, self, 80);
	}
};

void() W_FireLightning =
{
	local	float		cells;


// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35*cells, world);
		return;
	}

	//if (self.lcharge > 0)
	//{
	//	if (self.t_width < time && self.lcharge > 0)
	//	{
	//		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
	//		self.t_width = time + 0.6;
	//	}
	//	//self.punchangle_x = -2;
	//}

	//if (self.ammo_cells > 0 && self.lcharge < 25)
	//{
	//	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	//	self.lcharge = self.lcharge + 1;
	//}
	Lshoot();
	self.attack_finished = time + 1.5;
	if (deathmatch != 4)
		self.currentammo = self.ammo_cells = self.ammo_cells - 10;
	SuperDamageSound();
	sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);

};


//=============================================================================


void() GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 120, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile, mpuff;
	
	if (deathmatch != 5)
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	//self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
          missile.weaponmodel = self.weaponmodel;
		
// set missile speed	

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200; //+ crandom()*v_right*10 + crandom()*v_up*10; remed crandom
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/



void() delete_spike =
{
	if (self.owner.classname == "player")
	{
		self.owner.nails = self.owner.nails - 1;
		count_spike(self.owner);
	}
	remove(self);
};

void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.solid = SOLID_TRIGGER;

	newmis.angles = vectoangles(dir);
	newmis.weaponmodel = self.weaponmodel;
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = delete_spike;
	if (!deathmatch)
	{
		newmis.think = SUB_Remove;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.nextthink = time + 6;
	}
	else
	{
		if (self.classname == "player")
		{
			newmis.think = delete_spike;
		}
		else
		{
			newmis.think = SUB_Remove;
		}
		newmis.movetype = MOVETYPE_TOSS;
		newmis.nextthink = time + 60;
	}
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	local entity	old;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	if (!deathmatch)
	{
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	}
	else
	{
	FireBullets(3, dir, '0.01 0.01 0.0', 6);
	}		
	//self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	local entity	old;
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		player_run ();
		W_SetCurrentAmmo ();
		return;
	}
	
	if (!(self.nails < 30))
	{
		sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	self.nails = self.nails + 1;
	count_spike(self);
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	//self.punchangle_x = -2;
};



.float hit_z;

void() spike_hurt =
{
if (other.takedamage)
	{
		local entity thing;
		local float tdmg;
		tdmg = 9;
		thing = findradius(self.origin, 1);
		while(thing)
		{
			if (thing.classname == "stuck_spike")
			{
				self.owner.nails = self.owner.nails - 1;
				remove(thing);
				tdmg = tdmg + 9;
			}
			thing = thing.chain;
		}
		spawn_touchblood (tdmg);
		T_Damage (other, self, self.owner, tdmg);
		//self.owner.nails = self.owner.nails - 1;
		count_spike(self.owner);
		remove(self);
	}
};

void() spike_touch =
{
if (!deathmatch)
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

}
else
{
local float rand;
	if (other == self.owner && self.velocity)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		self.owner.nails = self.owner.nails - 1;
		count_spike(self.owner);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
		remove(self);
		self.owner.nails = self.owner.nails - 1;
		count_spike(self.owner);
	}
	else
	{
		if (other.classname == "plat" || other.classname == "door" || other.classname == "train")
		{
			remove(self);
			self.owner.nails = self.owner.nails - 1;
			count_spike(self.owner);
			return;
		}
		
		self.classname = "stuck_spike";
		self.movetype = MOVETYPE_NONE;
		self.touch = spike_hurt;
		//setsize (self, VEC_ORIGIN, ' 0 0 4');
		self.velocity = '0 0 0';
		self.angles = vectoangles(trace_plane_normal);
		self.angles_x = self.angles_x+(crandom()*30);
		self.angles_y = self.angles_y+(crandom()*30);
		self.angles_z = self.angles_z+(crandom()*30);

		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		
		
	}

}
};

void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	//if (!(self.weapon == IT_LIGHTNING))
	//{
	player_run (); // get out of any weapon firing states
	//}		

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		if (deathmatch == 5)
			self.weaponmodel = "";
		self.weaponframe = 0;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

float() W_BestWeapon =
{
	local	float	it;
	
	
	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells > 0 && (it & IT_LIGHTNING) )
			return IT_LIGHTNING;
	if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	if(self.ammo_nails >= 1 && (it & IT_NAILGUN) && (self.nails < 30))
		return IT_NAILGUN;
	if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;
	return IT_AXE;
};

float() W_CheckNoAmmo =
{
		
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;
		
	if (deathmatch == 4)
		return TRUE;
	
	self.weapon = W_BestWeapon ();
	
	player_run ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;

void() W_Attack =
{
	local	float	r;

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == IT_AXE)
	{
		if (deathmatch == 5)
			return;
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + 0.8;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		player_rocket1();
		W_FireLightning();
		self.attack_finished = time + 1.5;
	}
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	it = self.items;
	am = 0;
	
	if (self.impulse == 1)
	{
		fl = IT_AXE;
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}		
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 1 || self.nails > 29)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 10)
			am = 1;
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;		
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1 || self.nails > 29)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 10 && deathmatch != 4)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1 || self.nails > 29)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 10 && deathmatch != 4)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	if (deathmatch)
		return;
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

/*
============
ImpulseCommands

============
*/

void () wjcheck =
{
	local	vector vecm;
	local	vector vecr;
	local	vector vecl;
	
	makevectors(self.angles);
	
	traceline (self.origin, (self.origin + (v_forward * -41)), FALSE, self);
	vecm = trace_endpos;
	traceline (self.origin, (self.origin + (v_right * 16) + (v_forward * -41)), FALSE, self);
	vecr = trace_endpos;
	traceline (self.origin, (self.origin + (v_right * -16) + (v_forward * -41)), FALSE, self);
	vecl = trace_endpos;
	
	if (vlen(vecm - self.origin) <= 40 || vlen(vecr - self.origin) <= 40 || vlen(vecl - self.origin) <= 40)
	{
		self.wjump = 1;
	}
	else
	{
		self.wjump = 0;
	}
};

void() walljump =
{
	wjcheck ();
	if (self.wjump == 1 && self.wjcount < 3)
	{
		self.wjcount = self.wjcount + 1;
		local	vector wj;
		local	vector wwj;
		wj_y = self.angles_y;
		makevectors (wj);
		wwj = v_forward * 500;
		wwj_z = 200;
		self.velocity = wwj;
		sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
	}
};

void() ImpulseCommands =
{
	if (!self.deadflag)
	{
	
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon ();

	if (self.impulse == 9)
		CheatCommand ();
	if (self.impulse == 10)
		CycleWeaponCommand ();
	if (self.impulse == 11)
		ServerflagsCommand ();
	if (self.impulse == 12)
		CycleWeaponReverseCommand ();

	if (self.impulse == 255)
		QuadCheat ();
		
	}
		
	if (self.impulse == 13 && vote_time > time && self.voted == 0) //yes
	{
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 14 && vote_time > time && self.voted == 0) //no
	{
		vote_no = vote_no + 1;
		self.voted = 1;
		sprint (self, "Voted no\n");
		bprint (self.netname);
		bprint (" voted no\n");
	}
	
	if (self.impulse == 15 && vote_time < time) //dm1
	{
		vote_time = time + 30;
		vote_subj = "changelevel dm1";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change map to dm1 type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 16 && vote_time < time) //dm2
	{
		vote_time = time + 30;
		vote_subj = "changelevel dm2";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change map to dm2 type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 17 && vote_time < time) //dm3
	{
		vote_time = time + 30;
		vote_subj = "changelevel dm3";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change map to dm3 type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 18 && vote_time < time) //dm4
	{
		vote_time = time + 30;
		vote_subj = "changelevel dm4";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change map to dm4 type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 19 && vote_time < time) //dm5
	{
		vote_time = time + 30;
		vote_subj = "changelevel dm5";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change map to dm5 type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 20 && vote_time < time) //dm6
	{
		vote_time = time + 30;
		vote_subj = "changelevel dm6";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change map to dm6 type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 23 && vote_time < time) //vote_deathmatch
	{
		vote_time = time + 30;
		vote_subj = "deathmatch 1; restart";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change gamemode to deathmatch type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 24 && vote_time < time) //vote_instaaxe
	{
		vote_time = time + 30;
		vote_subj = "deathmatch 3; restart";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change gamemode to instagib axes type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 25 && vote_time < time) //vote_instagib
	{
		vote_time = time + 30;
		vote_subj = "deathmatch 4; restart";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change gamemode to instagib type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 26 && vote_time < time) //vote_practice
	{
		vote_time = time + 30;
		vote_subj = "deathmatch 5; restart";
		vote_yes = vote_yes + 1;
		self.voted = 1;
		sprint (self, "Voted yes\n");
		bprint ("Vote to change gamemode to walljump practice type yes or no in console\n");
		bprint (self.netname);
		bprint (" voted yes\n");
	}
	
	if (self.impulse == 21) //spikes
		count_spike(self);
		
	local	entity	nail;	
	if (self.impulse == 22) //dspikes
	{
		for (nail = world; (nail = find (nail, classname, "stuck_spike")); )
		{
			if (nail.owner == self)
			{
				remove(nail);
				self.nails = self.nails - 1;
			}
		}
		count_spike(self);
	}
		
	if (self.impulse == 30 && !self.deadflag)
		walljump ();
		
	self.impulse = 0;
};

void () TraceID =
{
    makevectors (self.v_angle);
    traceline ((self.origin+self.view_ofs), ((self.origin+self.view_ofs) + (v_forward * 1000)), FALSE, self);
    if ((trace_ent.classname == "player") && (time > self.tidtime))
    {
		self.tidtime = time + 1;
        centerprint (self, trace_ent.netname);
        self.tidcheck = 1;
    }
    if (trace_ent.classname != "player" && self.tidcheck == 1)
    {
		centerprint (self, "\n");
		self.tidcheck = 0;
		self.tidtime = time;
    }
};



/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/

void() W_WeaponFrame =
{

	if (!self.deadflag)
	{
	
	if ((self.flags & FL_CLIENT))
	{
		TraceID ();
	}
	
	if ((self.flags & FL_ONGROUND) && self.wjcount != 0)
	{
		self.wjcount = 0;
	}

	if (self.impulse == 30)
		ImpulseCommands ();
		
	//if (self.button0 == FALSE && self.weapon == IT_LIGHTNING && self.lcharge > 0)
	//{
	//	Lshoot ();
	//	SuperDamageSound();
	//	sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);
	//	self.lcharge = 0;
	//	self.attack_finished = time + 0.4;
	//}
	
	if (time == self.attack_finished && self.weapon == IT_LIGHTNING && self.ammo_cells > 0 && self.health > 0)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		stuffcmd(self, "bf\n");
	}
	
	if (self.button0 == FALSE && deathmatch == 4 && self.weapon == IT_LIGHTNING && self.ammo_cells < 10)
	{
		self.ammo_cells = 10;
	}
	
	if (time < self.attack_finished)
		return;

	}
	
	if (self.impulse)
		ImpulseCommands ();
	
// check for attack
	if (self.button0 && !self.deadflag)
	{
		SuperDamageSound ();
		W_Attack ();
	}
	
		
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


