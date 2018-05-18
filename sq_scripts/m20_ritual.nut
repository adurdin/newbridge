class RitualPerformer extends SqRootScript
{
    function OnUnpocketHand()
    {
        local controller = LinkDest(Link_GetScriptParams("Controller", self));

        // Transfer the Hand to the Alt location, and make it unfrobbable
        local link = Link.GetOne("Contains", self);
        if (link == 0) {
            SendMessage(controller, "PerformerLookMaNoHands");
        } else {
            local hand = LinkDest(link);
            Link_SetContainType(link, eContainType.kContainTypeAlt);
            Object_AddFrobAction(hand, eFrobAction.kFrobActionIgnore);
        }

        // Tell the controller about it
        SendMessage(controller, "PerformerWavingStarted");
    }

    function OnPocketHand()
    {
        local controller = LinkDest(Link_GetScriptParams("Controller", self));

        // Put the Hand back on the belt, and make it frobbable again
        local link = Link.GetOne("Contains", self);
        if (link == 0) {
            SendMessage(controller, "PerformerLookMaNoHands");
        } else {
            local hand = LinkDest(link);
            Link_SetContainType(link, eContainType.kContainTypeBelt);
            Object_RemoveFrobAction(hand, eFrobAction.kFrobActionIgnore);
        }

        // Tell the controller about it
        SendMessage(controller, "PerformerWavingFinished");
    }

    function OnPatrolPoint()
    {
        // Tell the controller we've reached another patrol point
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerPatrolPoint", message().patrolObj);
    }

    function OnConversationFinished()
    {
        // Tell the controller we've finished going down
        local controller = LinkDest(Link_GetScriptParams("Controller", self));
        SendMessage(controller, "PerformerConversationFinished");
    }
}

class RitualController extends SqRootScript
{
    // Objects and AIs involved in the ritual
    performer = null;
    victim = null;
    rounds = [];
    downs = [];
    extras = [];
    lights = [];
    strips = [];
    gores = [];

    // Vertices in the order that the performer should visit them.
    // Can tweak this to adjust the ritual timing in very large increments.
    // Timing can also be tweaked more generally with M-RitualTrance Creature Time Warp.
    // But the last entry must be 6, because that's the head.
    // FIXME: might in fact want to adjust time warp for Normal difficulty
    // FIXME: If the stages are changed, also need to adjust the Ritual tags in the conv schema.
    //stages = [0, 1, 2, 3, 4, 5, 6]; // very fast
    stages = [2, 5, 1, 4, 0, 3, 6]; // With time warp 1.5, this takes 5:20 to complete.
    //stages = [4, 2, 0, 5, 3, 1, 6]; // very slow

    // Status of the ritual
    // FIXME: the following status stuff needs to be GetData/SetData'd so it saves and loads
    is_running = false;
    current_index = 0;
    current_stage = 0;
    current_trol_target = 0;

    function OnSim()
    {
        if (message().starting) {
            PrecacheLinks();

            // Add some data links to the performer
            Link_CreateScriptParams("Controller", performer, self);

            // Make sure the gores aren't "there" initially.
            foreach (gore in gores) {
                Object.AddMetaProperty(gore, "M-NotHere");
            }
        }
    }

    function OnTurnOn()
    {
        if (! is_running) {
            is_running = true;
            StartRitual();
        } else {
            // FIXME: for testing only:
            FinishRitual();
        }
    }

    function OnPerformerPatrolPoint()
    {
        local trol = message().data;
        if (trol == current_trol_target) {
            // We've done our little dance. Time to get down tonight.
            local down = downs[current_stage];
            local strip = strips[current_stage];
            local light = lights[current_stage];
            print("RITUAL: Down " + current_index + " via " + Object.GetName(down) + " (" + down + ")");
            SendMessage(strip, "TurnOn");
            SendMessage(light, "TurnOn");
            AI.StartConversation(down);
        }
    }

    function OnPerformerWavingStarted()
    {
        print("RITUAL: Waving");
        // FIXME: make the extras chant, if they're not busy
    }

    function OnPerformerWavingFinished()
    {
        print("RITUAL: Stopped waving");
        // FIXME: make the extras stop chanting, if they're not busy

        local light = lights[current_stage];
            SendMessage(light, "TurnOff");

        // Check if we've finished the final stage
        if (current_index == (stages.len() - 1)) {
            FinishRitual();
        }
    }

    function OnPerformerLookMaNoHands()
    {
        print("RITUAL: Hand has been stolen");
        // FIXME: stop the ritual and make di rupo react
        print("RITUAL DEATH: look ma no hands!");
        Object.Destroy(self);
    }

    function OnPerformerConversationFinished()
    {
        // The ritual is proceeding according to plan.
        SetCurrentIndex(current_index + 1);
        print("RITUAL: Round " + current_index + " to " + current_stage);
    }

    function StartRitual()
    {
        print("RITUAL: Start");
        // Begin at the beginning
        SetCurrentIndex(0);
        Link_SetCurrentPatrol(performer, current_trol_target);
        Object.AddMetaProperty(performer, "M-DoesPatrol");
        Object.AddMetaProperty(performer, "M-RitualTrance");

        // FIXME: lights and extras

    }

    function FinishRitual()
    {
        print("RITUAL: Finish");
        // Stop patrolling
        Object.RemoveMetaProperty(performer, "M-DoesPatrol");
        print("RITUAL DEBUG: stopped patrolling");

        // FIXME: lights and extras
    
        // Destroy the victim, and bring out the gores
        Object.Destroy(victim);
        print("RITUAL DEBUG: victim destroyed");
        // Fling body parts everywhere, why don't you?
        local z_angles = [141.429, 192.857, 244.286, 295.714, 347.143, 38.571, 90.0];
        for (local i = 0; i < gores.len(); i++) {
            local gore = gores[i];
            Object.RemoveMetaProperty(gore, "M-NotHere");
            print("RITUAL DEBUG: gore " + i + " brought back");
            /*
            // Launch it
            local a = z_angles[i]  * 3.14 / 180;
            local vel = vector(cos(a), sin(a), 1);
            vel.Normalize();
            vel.Scale(30.0);
            //Property.Set(gore, "PhysControl", "Controls Active", 0);
            //print("RITUAL DEBUG: gore " + i + " decontrolled");
            Physics.Activate(gore);
            print("RITUAL DEBUG: gore " + i + " activated");
            Physics.SetVelocity(gore, vel);
            print("RITUAL DEBUG: gore " + i + " launched");
            */
        }

        print("RITUAL DEBUG: about to post mesage");
        PostMessage(self, "ExplodeVictim");

    }

    function OnExplodeVictim()
    {
        print("RITUAL DEBUG: explode victim");
        // Fling body parts everywhere, why don't you?
        local z_angles = [141.429, 192.857, 244.286, 295.714, 347.143, 38.571, 90.0];
        for (local i = 0; i < gores.len(); i++) {
            local gore = gores[i];
            // Launch it
            local a = z_angles[i]  * 3.14 / 180;
            local vel = vector(cos(a), sin(a), 1);
            vel.Normalize();
            vel.Scale(30.0);
            Property.Set(gore, "PhysControl", "Controls Active", 0);
            print("RITUAL DEBUG: gore " + i + " decontrolled");
            Physics.Activate(gore);
            print("RITUAL DEBUG: gore " + i + " activated");
            Physics.SetVelocity(gore, vel);
            print("RITUAL DEBUG: gore " + i + " launched");
        }
    }

    function SetCurrentIndex(index)
    {
        // Update the ritual status, and the performer's target
        current_index = index;
        if (current_index >= stages.len()) {
            print("RITUAL DEATH: me am go too far!");
            Object.Destroy(self);
        }
        current_stage = stages[current_index];
        current_trol_target = rounds[current_stage];

        // FIXME: update lights
        // FIXME: update extras
    }

    function PrecacheLinks()
    {
        local links = Link.GetAll("ScriptParams", self);
        foreach (link in links) {
            local obj = LinkDest(link);
            local data = LinkTools.LinkGetData(link, "");
            if (data == "Performer") {
                performer = obj;
            } else if (data == "Victim") {
                victim = obj;
            } else if (data == "Round") {
                rounds.append(obj);
            } else if (data == "Down") {
                downs.append(obj);
            } else if (data == "Light") {
                lights.append(obj);
            } else if (data == "Extra") {
                extras.append(obj);
            } else if (data == "Strip") {
                strips.append(obj);
            } else if (data == "Gore") {
                gores.append(obj);
            }
        }

        // Check everything's okay
        if (performer == null) {
            print("RITUAL DEATH: no performer.");
            Object.Destroy(self);
        }
        if (victim == null) {
            print("RITUAL DEATH: no victim.");
            Object.Destroy(self);
        }
        if (rounds.len() != stages.len()) {
            print("RITUAL DEATH: incorrect number of rounds.");
            Object.Destroy(self);
        }
        if (downs.len() != stages.len()) {
            print("RITUAL DEATH: incorrect number of downs.");
            Object.Destroy(self);
        }
        if (lights.len() != stages.len()) {
            print("RITUAL DEATH: incorrect number of lights.");
            Object.Destroy(self);
        }
        // FIXME:
        /*
        if (extras.len() != stages.len()) {
            print("RITUAL DEATH: incorrect number of extras.");
            Object.Destroy(self);
        }
        */
        if (strips.len() != stages.len()) {
            print("RITUAL DEATH: incorrect number of strips.");
            Object.Destroy(self);
        }
        if (gores.len() != stages.len()) {
            print("RITUAL DEATH: incorrect number of gores.");
            Object.Destroy(self);
        }
    }
}

class RitualFloorStrip extends SqRootScript
{
    /* When turned on, brighten up and pulse illumination. */

    is_on = false;
    selfillum = 0.0; // 0...1
    selfillum_off = 0.0;
    selfillum_min = 0.125;
    selfillum_max = 0.375;
    period = 2.0;
    direction = 1.0;
    previous_time = 0;

    function OnTurnOn()
    {
        if (! is_on) {
            is_on = true;
            // Make sure we're animating
            direction = 1.0;
            previous_time = message().time;
            SetFlickering(true);
        }
    }

    function OnTurnOff()
    {
        if (is_on) {
            is_on = false;
            direction = -1.0;
            previous_time = message().time;
            SetFlickering(true);
        }
    }

    function OnTweqComplete()
    {
        // Figure out how much time has passed since the last update
        local time = message().time
        local elapsed = (time - previous_time) / 1000.0;
        if (elapsed < 0) {
            elapsed = 0;
        } else if (elapsed > period) {
            elapsed = period;
        }
        previous_time = time;

        // Calculate the selfillum change corresponding to the elapsed time
        local min = (is_on ? selfillum_min : selfillum_off);
        local max = selfillum_max;
        selfillum = selfillum + ((max - min) * direction * elapsed / period);
        if (direction == -1.0 && selfillum < min) {
            selfillum = min;
            direction = 1.0;
        } else if (direction == 1.0 && selfillum > max) {
            selfillum = max;
            direction = -1.0;
        }

        // Stop updates if we've reached minimum and we're turned off
        if ((! is_on) && (selfillum == selfillum_off)) {
            SetFlickering(false);
        }

        // Self-illuminate accordingly
        Property.Set(self, "ExtraLight", "Amount (-1..1)", selfillum);
    }

    function SetFlickering(on) {
        // Turn on or off the flicker tweq
        local animS = Property.Get(self, "StTweqBlink", "AnimS");
        local newAnimS = (on ? (animS | 1) : (animS & ~1));
        Property.Set(self, "StTweqBlink", "AnimS", newAnimS);
    }
}
