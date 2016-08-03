
void () NewRing_touch =
{
	if (!(other.flags & FL_CLIENT)) return;
	else if (other.health <= 0) return;
	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	//stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = (other.items | self.items);
	other.invisible_time = 1;
	other.invisible_finished = time + self.invisible_finished;
	self.nextthink = time + frametime;
};

void () DropRing =
{

	local entity item;
	item = spawn ();
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/invisibl.mdl");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin (item, (self.origin - '0 0 20'));
	//item.origin = (self.origin - '0 0 44');
	item.items = IT_INVISIBILITY;
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random () * 200));
	item.velocity_y = (-100 + (random () * 200));
	item.classname = "item_artifact_invisibility";
	item.invisible_time = 0;
	item.invisible_finished = self.invisible_finished - time;
	item.flags = FL_ITEM;
	item.touch = NewRing_touch;
	item.noise = "items/inv1.wav";
	item.nextthink = time + 60;
	item.think = SUB_Remove;
};

void () NewQuad_touch =
{
	if (!(other.flags & FL_CLIENT)) return;
	else if (other.health <= 0) return;
	
	
	sound (other, CHAN_AUTO, self.noise, WEAPON_SHOTGUN, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = (other.items | self.items);

	other.super_time = 1;
	other.super_damage_finished = (time + self.super_damage_finished);
	self.nextthink = time + frametime;
};

void () DropQuad =
{
	bprint ("Time left is ");
    bprint (ftos(self.super_damage_finished));
    bprint ("\n");
	if (self.super_damage_finished < 1) return;
	local entity item;
	item = spawn ();
	setmodel (item, "progs/quaddama.mdl");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin (item, (self.origin - '0 0 20'));
	item.items = IT_QUAD;
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random () * 200));
	item.velocity_y = (-100 + (random () * 200));
	item.classname = "item_artifact_super_damage";
	item.super_time = 0;
	item.super_damage_finished = self.super_damage_finished - time;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.touch = NewQuad_touch;
	item.noise = "items/damage.wav";
	item.nextthink = time + 60;
	item.think = SUB_Remove;
};

