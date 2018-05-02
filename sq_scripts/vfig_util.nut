class DebugQuestVars extends SqRootScript
{
    //-- Utils

    function MissionPathname()
    {
        // If we had access to the Mission Pathname property from script, 
        // we wouldn't have to hardcode this. :-/
        return "miss20";
    }

    function GoalExists(num) {
        return Quest.Exists("goal_state_" + num);
    }

    function DumpGoal(num) {
        local text = "Goal " + num + ":";

        if (GoalExists(num)) {
            local goal_text = Data.GetString(MissionPathname() + "/goals", "text_" + num, "", "intrface");
            local goal_state = Quest.Get("goal_state_" + num).tointeger();
            local goal_visible = Quest.Get("goal_visible_" + num).tointeger();
            local goal_reverse = Quest.Get("goal_reverse_" + num).tointeger();
            local goal_type = Quest.Get("goal_type_" + num).tointeger();
            local goal_target = Quest.Get("goal_target_" + num).tointeger();
            local goal_target_name = Object.GetName(goal_target);
            local goal_irreversible = Quest.Get("goal_irreversible_" + num).tointeger();
            local goal_final = Quest.Get("goal_final_" + num).tointeger();
            local goal_max_diff = Quest.Get("goal_max_diff_" + num).tointeger();
            local goal_min_diff = Quest.Get("goal_min_diff_" + num).tointeger();
            local goal_loot = Quest.Get("goal_loot_" + num).tointeger();
            local goal_gold = Quest.Get("goal_gold_" + num).tointeger();
            local goal_gems = Quest.Get("goal_gems_" + num).tointeger();
            local goal_goods = Quest.Get("goal_goods_" + num).tointeger();
            local goal_special = Quest.Get("goal_special_" + num).tointeger();
            local difficulty = Quest.Get("difficulty");

            if (goal_state == 0) {
                text += " [ ]   "
            } else if (goal_state == 1) {
                text += " [DONE]"
            } else if (goal_state == 2) {
                text += " [N/A] "
            } else if (goal_state == 3) {
                text += " [FAIL]"
            }

            if (goal_visible == 0) {
                text += " (hidden)"
            }

            text += " \"" + goal_text + "\"";

            if (goal_reverse == 1) {
                text += " don't"
            }

            if (goal_type == 0) {
                text += " (scripted)"
            } else if (goal_type == 1) {
                text += " steal"
            } else if (goal_type == 2) {
                text += " kill"
            } else if (goal_type == 3) {
                text += " loot:"
            } else if (goal_type == 3) {
                text += " go to"
            }

            if (goal_type == 1 || goal_type == 2 || goal_type == 4) {
                text += " " + goal_target_name + " (" + goal_target + ")";
            } else if (goal_type == 3) {
                if (goal_gold != 0) {
                    text += " " + goal_gold + " gold;";
                }
                if (goal_gems != 0) {
                    text += " " + goal_gems + " gems;";
                }
                if (goal_goods != 0) {
                    text += " " + goal_goods + " goods;";
                }
                if (goal_special != 0) {
                    text += " " + goal_special + " special;";
                }
                if (goal_loot != 0) {
                    text += " " + goal_loot + " total;";
                }

            }

            if (goal_irreversible != 0) {
                text += " (irreversible)";
            }

            if (goal_final != 0) {
                text += " (final goal)";
            }

            local diff_names = array(3);
            diff_names[0] = "Normal";
            diff_names[1] = "Hard";
            diff_names[2] = "Expert";

            if (goal_min_diff != 0) {
                if (goal_max_diff != 0) {
                    text += " [" + diff_names[goal_min_diff] + " - " + diff_names[goal_max_diff] + "]";
                } else {
                    text += " [" + diff_names[goal_min_diff] + " - expert]";
                }
            } else if (goal_max_diff != 0) {
                    text += " [normal - " + diff_names[goal_max_diff] + "]";
            }

            if (goal_min_diff != 0 || goal_max_diff != 0) {
                text += " (currently: " + diff_names[difficulty] + ")";
            }

        } else {
            text += " does not exist.";
        }

        return text;
    }

    function DumpAllGoals() {
        local text = "";
        for (local num = 0; num < 32; num += 1) {
            if (GoalExists(num)) {
                text += DumpGoal(num) + "\n";
            }
        }
        return text;
    }

    function Display(text) {
        DarkUI.TextMessage(text);
        print(text);
    }

    function GetNumber(name)
    {
        local lastIndex;
        for (local i = name.find("_");
                i != null;
                i = name.find("_", i + 1)) {
            lastIndex = i;
        }
        if (lastIndex != null) {
            return name.slice(lastIndex + 1).tointeger();
        } else {
            return 999;
        }
    }

    function GetName(name)
    {
        local lastIndex;
        for (local i = name.find("_");
                i != null;
                i = name.find("_", i + 1)) {
            lastIndex = i;
        }
        if (lastIndex != null) {
            return name.slice(0, lastIndex);
        } else {
            return "???";
        }
    }

    //-- Messages

    function OnBeginScript()
    {
        print("DebugQuestVars on " + Object.GetName(self) + " (" + self + ") is watching all goals.");
        for (local num = 0; num < 32; num += 1) {
            if (GoalExists(num)) {
                Quest.SubscribeMsg(self, "goal_state_" + num);
                Quest.SubscribeMsg(self, "goal_visible_" + num);
            }
        }
        //Display(DumpAllGoals());
    }

    function OnQuestChange()
    {
        if (message().m_oldValue != message().m_newValue) {
            local name = GetName(message().m_pName);
            local num = GetNumber(message().m_pName);
            if (name == "goal_state") {
                Display(DumpGoal(num));
            } else {
                print(DumpGoal(num));
            }
            print("    " + message().m_pName + ": " + message().m_oldValue + " -> " + message().m_newValue);
        }
    }

    function OnTurnOn()
    {
        Display(DumpAllGoals());
    }
}