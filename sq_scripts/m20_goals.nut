enum eGoals {
    /* Argaux and the job */
    kMeetArgaux             = 0,
    kFindArgauxsInfauxs     = 1,
    /* The Anax */
    kKidnapTheAnax          = 2,
    kBonusBurrickTrouble    = 3,
    /* The Hand */
    kStealTheHand           = 4,
    kBonusBanishTheGhost    = 5,
    /* Delivery */
    kDeliverTheItems        = 6,
    /* The Ritual */
    kStopTheRitual          = 7,
    kBonusSubvertTheRitual  = 8,
    kEscapeWithTheAnax      = 9,
    kReturnTheAnax          = 10, // Hard + Expert
    kBonusSellTheHand       = 11,
    /* Silly player */
    kKeepTheAnaxAlive       = 12,
    kDontBiteTheHand        = 13,
    /* Loot */
    kLootNormal             = 14,
    kLootHard               = 15,
    kLootExpert             = 16,
    kSpecialLootHard        = 17, // Hard + Expert special loot item (special 1)
    kSpecialLootExpert      = 18, // Expert special loot item (special 2)
    /* Thou shalt not murder */
    kDontKillBystanders     = 19,
    kDontKillHumans         = 20,
    /* Endgame */
    kReturnToTheStart       = 21
}

enum eMonologues {
    /* Argaux and the job */
    kWhereIsArgaux          = 1,
    kFoundArgauxsBody       = 6,
    kFoundArgauxsInfauxs    = 2,
    kFoundDiRuposInfos      = 4,
    /* The Anax */
    kEnteredTheSanctuary    = 5,
    kTheAnaxIsAPerson       = 3,
    kHammerTakenByBurricks  = 17, // FIXME: script this
    kGotTheFirstItem        = 12, // FIXME: script this
    /* The Hand */
    kMausoleumLocked        = 0, // FIXME: script this
    kPuzzleFailed1          = 9, // FIXME: script this
    kPuzzleFailed2          = 10, // FIXME: script this
    kPuzzleFailed3          = 11, // FIXME: script this
    kEnteredTheProphetsRoom = 16, // FIXME: script this
    kBanishedTheGhost       = 18, // FIXME: script this
    kGotTheSecondItem       = 13, // FIXME: script this
    kGonnaSellTheHand       = 20, // FIXME: script this
    /* Delivery */
    kThisIsTheDeliverySpot  = 8,
    /* The Ritual */
    kLookAtTheTower         = 14, // FIXME: script this
    kFoundTheRitual         = 7,
    kReleasedTheProphet     = 19, // FIXME: script this
    kRescuingTheAnax        = 15, // FIXME: script this
}

// FIXME: don't need these once I have recordings
local DebugMonologueText = [
    "Looks like I'll have to find another way in.",
    "Strange that Argaux's not here. I should scout around to see if he's nearby.",
    "So this is what Argaux wanted my help on. The money's good. I think I'll do the job by myself.",
    "So the Anax is a person, not a trinket. That's ... inconvenient.",       
    "So this is the job Argaux wanted my help on. I think I'll do the job by myself: then I won't have to pay his finder's fee.",
    "Now to find the Anax, whatever that is.",
    "Looks like Argaux's career has come to a sudden stop. I should check his place for info on this job. ... Guess I won't have to give up that finder's fee after all.",
    "They've already started the ritual. Need to be quick if I'm gonna stop them.",
    "This looks like the hand-off point.",
    "Must be the wrong combination.",
    "Nope!",
    "I hate to say it, but maybe some research would help me figure this out?",
    "One down, one to go.",
    "Now to deliver all this and get my money.",
    "The tower's all lit up. That's new.",
    "I hope the Hammers appreciate me rescuing this guy.",
    "I don't like the look of this.",
    "I guess the Burricks were saving him for a late night snack?",
    "You know, I really didn't think that would work!",
    "Heh heh. Sorry about the mess.",
    "Got this Hand here you might be interested in..."
];

local Goal = {
    IsActive = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 0);
    }
    Activate = function(goal) {
        Quest.Set("goal_state_" + goal, 0);
    }
    IsComplete = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 1);
    }
    Complete = function(goal) {
        Quest.Set("goal_state_" + goal, 1);
    }
    IsCancelled = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 2);
    }
    Cancel = function(goal) {
        Quest.Set("goal_state_" + goal, 2);
    }
    IsFailed = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 3);
    }
    Fail = function(goal) {
        Quest.Set("goal_state_" + goal, 3);
    }
    IsVisible = function(goal) {
        return (Quest.Get("goal_visible_" + goal) == 1);
    }
    Hide = function(goal) {
        Quest.Set("goal_visible_" + goal, 0);
    }
    Show = function(goal) {
        Quest.Set("goal_visible_" + goal, 1);
    }

    IsGoldilocksDifficulty = function(goal) {
        local difficulty = Quest.Get("difficulty");
        if (Quest.Exists("goal_min_diff_" + goal)) {
            local min_diff = Quest.Get("goal_min_diff_" + goal);
            if (difficulty < min_diff) {
                return false;
            }
        }
        if (Quest.Exists("goal_max_diff_" + goal)) {
            local max_diff = Quest.Get("goal_max_diff_" + goal);
            if (difficulty > max_diff) {
                return false;
            }
        }
    }

    // For a few objectives, we want notifications like Thief 2 that the player is on
    // the right track. But since this Goal table doesn't know if there's new objectives
    // or not, it's up to each goal script to call this if desired.
    PlayCompleteNotification = function()
    {
        // Only play notifications if they're turned on
        if (DarkGame.BindingGetFloat("goal_notify") != 0) {
            local player = Object.Named("Player");
            local schema = Object.Named("new_obj");
            local message = Data.GetString("PlayHint.str", "DoneGoal");
            DarkUI.TextMessage(message);
            Sound.PlaySchemaAmbient(player, schema);
        }
    }

    SpeakMonologue = function(monologue) {
        if (Quest.Get("mlog_done_" + monologue) == 0) {
            // FIXME: play the voice line here
            print("Speaking " + monologue + ": " + DebugMonologueText[monologue]);
            DarkUI.TextMessage(DebugMonologueText[monologue], 0);
            Quest.Set("mlog_done_" + monologue, 1);
        } else {
            print("Skipping " + monologue + ": " + DebugMonologueText[monologue]);
        }
    }
    CancelMonologue = function(monologue) {
        if (Quest.Get("mlog_done_" + monologue) == 0) {
            print("Cancelling " + monologue + ": " + DebugMonologueText[monologue]);
            Quest.Set("mlog_done_" + monologue, 1);
        } else {
            print("Already cancelled " + monologue + ": " + DebugMonologueText[monologue]);
        }
    }
    IsMonologueDone = function(monologue) {
        return (Quest.Get("mlog_done_" + monologue) == 1);
    }

};


/* -------- Argaux and the job -------- */


class GoalArgauxsBody extends SqRootScript
{
    /* Put this on Argaux's body. Ensure it has World: FocusScript, Script
       in its FrobInfo. */

    function Activate()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.SpeakMonologue(eMonologues.kFoundArgauxsBody);

        Goal.Cancel(eGoals.kMeetArgaux);
        Goal.Show(eGoals.kFindArgauxsInfauxs);
    }

    function OnWorldSelect()
    {
        Activate();
    }

    function OnFrobWorldEnd()
    {
        // If you frob the body, you get the key
        local player = Object.Named("Player");
        local result = Container.MoveAllContents(self, player);
    }

    function OnContainer()
    {
        // Someone's stolen our key! Good for them!
        if (message().event == eContainsEvent.kContainRemove) {
            Activate();
            DisableItemWorldFrob(self);
        }
    }

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }
}

class GoalTheFountain extends SqRootScript
{
    /* Put this on a concrete room at the fountain. */

    function OnPlayerRoomEnter()
    {
        Goal.SpeakMonologue(eMonologues.kWhereIsArgaux);
    }
}

class GoalSeizureNotice extends SqRootScript
{
    /* Put this on the notice on Argaux's door. */


    function OnFrobWorldEnd()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.SpeakMonologue(eMonologues.kFoundArgauxsBody);

        Goal.Cancel(eGoals.kMeetArgaux);
        Goal.Show(eGoals.kFindArgauxsInfauxs);
    }
}

class GoalArgauxsInfauxs extends SqRootScript
{
    /* Put this on the scroll with the job info in Argaux's bolt-hole. */

    function OnFrobInvEnd()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.CancelMonologue(eMonologues.kFoundArgauxsBody);
        Goal.SpeakMonologue(eMonologues.kFoundArgauxsInfauxs);
        Goal.CancelMonologue(eMonologues.kFoundDiRuposInfos);

        Goal.Cancel(eGoals.kMeetArgaux);
        if (Goal.IsActive(eGoals.kFindArgauxsInfauxs)) {
            // Don't complete it if it was already cancelled.
            Goal.Show(eGoals.kFindArgauxsInfauxs);
            Goal.Complete(eGoals.kFindArgauxsInfauxs);
        }
        Goal.Show(eGoals.kKidnapTheAnax);
        Goal.Show(eGoals.kStealTheHand);
        Goal.Show(eGoals.kDeliverTheItems);
    }
}

class GoalDiRuposInfos extends SqRootScript
{
    /* Put this on di Rupo's diary with the job info. */

    function OnFrobWorldEnd()
    {
        Goal.CancelMonologue(eMonologues.kWhereIsArgaux);
        Goal.CancelMonologue(eMonologues.kFoundArgauxsBody);
        if (Goal.IsActive(eGoals.kMeetArgaux)) {
            // If the player doesn't know Argaux is dead, use the line where Garrett is cutting Argaux out of the job.
            Goal.CancelMonologue(eMonologues.kFoundArgauxsInfauxs);
            Goal.SpeakMonologue(eMonologues.kFoundDiRuposInfos);
        } else {
            // If the player already knows Argaux is dead, use the line where Garrett is taking on the job anyway.
            Goal.SpeakMonologue(eMonologues.kFoundArgauxsInfauxs);
            Goal.CancelMonologue(eMonologues.kFoundDiRuposInfos);
        }

        Goal.Cancel(eGoals.kMeetArgaux);
        if (Goal.IsActive(eGoals.kFindArgauxsInfauxs)) {
            // Don't cancel it if it was already completed.
            Goal.Cancel(eGoals.kFindArgauxsInfauxs);
        }
        Goal.Show(eGoals.kKidnapTheAnax);
        Goal.Show(eGoals.kStealTheHand);
        Goal.Show(eGoals.kDeliverTheItems);
    }
}


/* -------- The Anax -------- */


class GoalEnterTheSanctuary extends SqRootScript
{
    /* Put this on a concrete room at the sanctuary. */

    function OnPlayerRoomEnter()
    {
        if (Goal.IsActive(eGoals.kKidnapTheAnax)
            && Goal.IsVisible(eGoals.kKidnapTheAnax)) {
            Goal.SpeakMonologue(eMonologues.kEnteredTheSanctuary);
        }
    }
}

class GoalReadingAboutTheAnax extends SqRootScript
{
    /* Put this on:
        - the Anax's diary,
        - the notice about where the Anax is sleeping,
        - the letter from the Priest to the Warden,
        - any other readables that reveal the Anax is a person.
    */

    function OnFrobInvEnd()
    {
        Activate();
    }

    function OnFrobWorldEnd()
    {
        Activate();
    }

    function Activate()
    {
        Goal.CancelMonologue(eMonologues.kEnteredTheSanctuary);
        if (Goal.IsActive(eGoals.kKidnapTheAnax)
            && Goal.IsVisible(eGoals.kKidnapTheAnax)) {
            Goal.SpeakMonologue(eMonologues.kTheAnaxIsAPerson);
        } else {
            Goal.CancelMonologue(eMonologues.kTheAnaxIsAPerson);
        }
    }
}

class GoalSeeingTheAnax extends SqRootScript
{
    /* Put this on a concrete room where the player can see the Anax. */

    function OnPlayerRoomEnter()
    {
        Goal.CancelMonologue(eMonologues.kEnteredTheSanctuary);
        if (Goal.IsActive(eGoals.kKidnapTheAnax)
            && Goal.IsVisible(eGoals.kKidnapTheAnax)) {
            Goal.SpeakMonologue(eMonologues.kTheAnaxIsAPerson);
        } else {
            Goal.CancelMonologue(eMonologues.kTheAnaxIsAPerson);
        }
    }
}

class GoalKidnapTheAnax extends WhenPlayerCarrying
{
    /* Put this on the Anax in the sanctuary. */

    function OnPlayerPickedUp()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            // Tick this off even if these objectives aren't visible yet
            Goal.Complete(eGoals.kKidnapTheAnax);
        }
    }

    function OnPlayerDropped()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            // Untick it again
            Goal.Activate(eGoals.kKidnapTheAnax);
        }
    }
}


/* -------- The Hand -------- */


class GoalStealTheHand extends WhenPlayerCarrying
{
    /* Put this on the Hand in the catacombs. */

    function OnPlayerPickedUp()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            // Tick this off even if these objectives aren't visible yet
            Goal.Complete(eGoals.kStealTheHand);
        }
    }

    function OnPlayerDropped()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)) {
            // Untick it again
            Goal.Activate(eGoals.kStealTheHand);
        }
    }
}


/* -------- Delivery -------- */


class GoalNearTheFishmongers extends WatchForItems
{
    /* Put this on a concrete room in front of the fishmongers. 
       Add a ControlDevice link to its door, and ScriptParams("WatchThis") links
       to the Sanctuary Anax and the Mausoleum Hand.

       Make sure to have a button to open the door from the inside in case
       a clever player tries to trap themself! */

    function OnPlayerRoomEnter()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)
            && Goal.IsVisible(eGoals.kDeliverTheItems)) {
            Goal.SpeakMonologue(eMonologues.kThisIsTheDeliverySpot);
        }
    }

    function OnPlayerRoomExit()
    {
        if (Goal.IsComplete(eGoals.kDeliverTheItems)) {
            // Close the door to the fishmongers again when leaving.
            Link.BroadcastOnAllLinks(self, "TurnOff", "ControlDevice");
        }
    }

    function OnItemsArrived()
    {
        if (Goal.IsActive(eGoals.kDeliverTheItems)
            && Goal.IsVisible(eGoals.kDeliverTheItems)) {
            // If you drop both items outside the fishmongers before getting
            // the "deliver the items" objective, too bad, you're gonna
            // have to take them out and in again.
            local all_items = message().data;
            if (all_items) {
                // Open the door to the fishmongers when approaching with the items.
                Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
            }
        }
    }
}

class GoalDeliverTheItems extends MultipleDeliveries
{
    /* Put this on the concrete room where the items should be delivered.
       On The Anax and The Prophet's Hand put the ItemToDeliver script, with
       a ScriptParams("DeliveryRoom") link to this room.
       Give the room a ControlDevice link to the conversation to trigger. */

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }

    function OnItemDelivered()
    {
        local item = message().data;
        DisableItemWorldFrob(item);

        base.OnItemDelivered();
    }

    function OnAllItemsDelivered()
    {
        Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
    }
}

class GoalDeliveryDiRupo extends SqRootScript
{
    // Triggered by conversation
    function OnGivePayment()
    {
        // Trigger the loot goals to update for this payment.
        // Got to do this before transferring containment, otherwise that'll
        // set off quest var state changes.
        local link = Link.GetOne("Contains", self);
        local payment = LinkDest(link);
        SendMessage(payment, "UpdateLootGoals");

        // Give the player everything di Rupo is carrying
        local player = Object.Named("Player");
        local result = Container.MoveAllContents(self, player);
   }

   // Triggered by conversation
   function OnConversationFinished()
   {
        Goal.Complete(eGoals.kKidnapTheAnax);
        Goal.Complete(eGoals.kStealTheHand);
        Goal.Complete(eGoals.kDeliverTheItems);
        Goal.PlayCompleteNotification();
   }
}

/* -------- Intervention -------- */

class GoalPullTheStrings extends SqRootScript
{
    /* Put this on the intervention Keeper. Link to the continuation conversations
        with ScriptParams("ConvNormal") and ScriptParams("ConvHard").
    */

    // Triggered by conversation
    function OnGiveKey()
    {
        // Give the player everything the keeper is carrying
        local player = Object.Named("Player");
        local result = Container.MoveAllContents(self, player);
    }

    // Triggered by conversation
    function OnConversationContinuation()
    {
        // Figure out which conversation to play next according to difficulty
        local difficulty = Quest.Get("Difficulty");
        local conv;
        if (difficulty == 0) {
            conv = LinkDest(Link_GetScriptParams("ConvNormal", self));
        } else {
            conv = LinkDest(Link_GetScriptParams("ConvHard", self));
        }
        AI.StartConversation(conv);
    }

    // Triggered by conversation
    function OnConversationFinished()
    {
        Goal.Show(eGoals.kStopTheRitual);
        Goal.Show(eGoals.kReturnTheAnax);

        // Open the door again. Unlock it if it has a linked lock.
        local door = LinkDest(Link_GetScriptParams("Door", self));
        local lock_link = Link.GetOne("Lock", door);
        if (lock_link != 0) {
            SendMessage(LinkDest(lock_link), "Unlock");
        } else {
            SendMessage(door, "Open");
        }
    }

    function OnPatrolPoint()
    {
        // Go away when we reach the end of the patrol
        local link = Link.GetOne("AIPatrol", message().patrolObj);
        if (link == 0) {
            Object.Destroy(self);
        }
    }
}


class GoalDamnKeepers extends SqRootScript
{
    /* Put this on each concrete room where the Keeper intervention can happen. Give it:
        - a ScriptParams("Door") link to the (locked) door for this room.
        - a ScriptParams("Patrol") link to the TrolPt where the Keeper should start
          (it should face the way the Keeper should face).
        - a ScriptParams("Conv") link to the conversation for the encounter.
    */

    function OnPlayerRoomEnter()
    {
        local already_triggered = (Quest.Get("triggered_damn_keepers") == 1);
        if (Goal.IsComplete(eGoals.kDeliverTheItems)
            && (! Goal.IsVisible(eGoals.kStopTheRitual))
            && (! already_triggered))
        {
            // Don't trigger any of the keeper points again.
            Quest.Set("triggered_damn_keepers", 1);

            local player = Object.Named("Player");
            local door = LinkDest(Link_GetScriptParams("Door", self));
            local patrol = LinkDest(Link_GetScriptParams("Patrol", self));
            local conv = LinkDest(Link_GetScriptParams("Conv", self));
            local keeper = LinkDest(Link_GetConversationActor(1, conv));
            local garrett_voice = LinkDest(Link_GetConversationActor(2, conv));

            if (player == 0) { print("Failed to find player!"); return; }
            if (door == 0) { print("Failed to find door!"); return; }
            if (patrol == 0) { print("Failed to find patrol!"); return; }
            if (conv == 0) { print("Failed to find conv!"); return; }
            if (keeper == 0) { print("Failed to find keeper!"); return; }
            if (garrett_voice == 0) { print("Failed to find garrett_voice!"); return; }

            local patrol_pos = Object.Position(patrol);
            local player_pos = Object.Position(player);
            local facing = Object.Facing(patrol);

            // Close the door in front of the player. Lock it if it has a linked lock.
            local lock_link = Link.GetOne("Lock", door);
            if (lock_link != 0) {
                SendMessage(LinkDest(lock_link), "Lock");
            } else {
                SendMessage(door, "Close");
            }

            // Make sure the Keeper can find the door again when the conversation ends.
            local keeper_door_link = Link.Create("ScriptParams", keeper, door);
            LinkTools.LinkSetData(keeper_door_link, "", "Door");

            // Teleport the actors to the patrol point, and make the keeper face the player.
            Object.Teleport(keeper, patrol_pos, facing);
            Object.Teleport(garrett_voice, patrol_pos, facing);

            // Ensure the keeper will patrol away when the conversation is done
            // AICurrentPatrol is a singleton link, so make sure to delete any existing ones.
            Link_DestroyAll("AICurrentPatrol", keeper);
            Link.Create("AICurrentPatrol", keeper, patrol);
            Object.AddMetaProperty(keeper, Object.Named("M-DoesPatrol"));
            
            // And start the conversation (which should maybe start with a momentary Wait?)
            AI.StartConversation(conv);
        }
    }
}

/* -------- The Ritual -------- */

class GoalStopTheRitualByForce extends SqRootScript
{
    /* Put this on the ritual-performing Lady di Rupo. Fires if she is knocked out or killed. */

    function OnAIModeChange()
    {
        if (message().mode == eAIMode.kAIM_Dead) {
            Goal.Complete(eGoals.kStopTheRitual);
            Goal.Show(eGoals.kEscapeWithTheAnax);
        }
    }
}


class GoalStopTheRitualByTheft extends WhenPlayerCarrying
{
    /* Put this on the ritual versions of The Anax and The Prophet's Hand. Fires if they're picked up by the player. */

    function OnPlayerPickedUp()
    {
        Goal.Complete(eGoals.kStopTheRitual);
        Goal.Show(eGoals.kEscapeWithTheAnax);
    }
}


class GoalEscapeWithTheAnax extends WatchForItems
{
    /* Put this on the concrete room where the Anax should be carried to fulfill
       the "escape" goal. Add a ScriptParams("WatchThis") link to the ritual Anax. */

    function OnItemsArrived()
    {
        local all_items = message().data;
        if (all_items) {
            // It's okay, you can drop him now.
            Goal.Complete(eGoals.kEscapeWithTheAnax);
            if (Goal.IsGoldilocksDifficulty(eGoals.kEscapeWithTheAnax)) {
                Goal.PlayCompleteNotification();
            }
        }
    }
}


class GoalReturnTheAnax extends SqRootScript
{
    /* Put this on the concrete room where the Anax should be delivered to the sanctuary.

       On the ritual Anax, put ItemToDeliver script, with a ScriptParams("DeliveryRoom") link
       to the room. */

    function OnItemDelivered()
    {
        local item = message().data;
        DisableItemWorldFrob(item);
        Goal.Complete(eGoals.kReturnTheAnax);
        Goal.PlayCompleteNotification();
    }

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }
}


/* -------- Silly player -------- */


class GoalKeepTheAnaxAlive extends SqRootScript
{
    /* Put this on all the Anaxes. */

    function OnSlain()
    {
        Goal.Show(eGoals.kKeepTheAnaxAlive);
        Goal.Fail(eGoals.kKeepTheAnaxAlive);
    }
}


class GoalTheHandThatFeeds extends PreserveMe
{
    /* Put this on pre-ritual Lady di Rupo and all the Keepers. */

    function OnNotPreserved()
    {
        Goal.Show(eGoals.kDontBiteTheHand);
        Goal.Fail(eGoals.kDontBiteTheHand);
    }
}


/* -------- Loot -------- */


class GoalSellTheHand
{
    /* Put this on the concrete room where the ritual hand should be delivered.
       On the ritual hand put the ItemToDeliver script, with a ScriptParams("DeliveryRoom")
       link to this room. Add a ControlDevice link to the conversation to trigger. */

    function DisableItemWorldFrob(item)
    {
        const IgnoreFlag = 8;
        Property.Set(item, "FrobInfo", "World Action", IgnoreFlag);
    }

    function OnItemDelivered() {
        local item = message().data;
        DisableItemWorldFrob(item);

        Goal.Show(eGoals.kBonusSellTheHand);
        Goal.Complete(eGoals.kBonusSellTheHand);

        Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
    }
}


/* ------------- */


class GoalUpdateLootGoals extends SqRootScript
{
    /* Put this on a loot item that has value, but shouldn't count towards loot
       objectives (e.g. payment for a job). It adds its own loot values to the
       values of all loot goals. Needs FrobInfo > World: Move/Script to work.
    */
    function OnUpdateLootGoals()
    {
        AddLootValuesToGoals();
    }

    function AddLootValuesToGoals()
    {
        if (Property.Possessed(self, "Loot")) {
            local item_gold = Property.Get(self, "Loot", "Gold").tointeger();
            local item_gems = Property.Get(self, "Loot", "Gems").tointeger();
            local item_goods = Property.Get(self, "Loot", "Art").tointeger();
            local item_total = item_gold + item_gems + item_goods;
            for (local goal = 0; goal < 32; goal += 1) {
                local state_name = "goal_state_" + goal;
                if (! Quest.Exists(state_name)) break;
                local total_name = "goal_loot_" + goal;
                local gold_name = "goal_gold_" + goal;
                local gems_name = "goal_gems_" + goal;
                local goods_name = "goal_goods_" + goal;
                if (Quest.Exists(total_name)) {
                    local goal_total = Quest.Get(total_name).tointeger();
                    Quest.Set(total_name, goal_total + item_total);
                }
                if (Quest.Exists(gold_name)) {
                    local goal_gold = Quest.Get(gold_name).tointeger();
                    Quest.Set(gold_name, goal_gold + item_gold);
                }
                if (Quest.Exists(gems_name)) {
                    local goal_gems = Quest.Get(gems_name).tointeger();
                    Quest.Set(gems_name, goal_gems + item_gems);
                }
                if (Quest.Exists(goods_name)) {
                    local goal_goods = Quest.Get(goods_name).tointeger();
                    Quest.Set(goods_name, goal_goods + item_goods);
                }
            }
        }
    }
}