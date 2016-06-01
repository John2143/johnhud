function this:__init()

        local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
        local difficulty_index = tweak_data:difficulty_to_index(difficulty)
        self:ModifyTaskData(tweak_data.group_ai, difficulty_index, difficulty)
        self:ModifyUnitCategories(tweak_data.group_ai, difficulty_index)
        self:ModifyTweakData(tweak_data.group_ai, difficulty_index)
        
        jhud.hook("CopDamage", "init", function(weapon, unit)
            CopDamage._hurt_severities = {
                none = false,
                light = false,
                moderate = false,
                heavy = false,
                explode = false
            }
        end)
        jhud.hook("EnemyManager", "_init_enemy_data", function(enemy_manager)
            enemy_manager._enemy_data.max_nr_active_units = 2000
        end)
        jhud.hook("GroupAIStateBesiege", "init", function(ai_state)
            GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS = 3000
        end)
    
end

function this:ModifyTaskData(data, difficulty_index, difficulty)

    data.besiege.recurring_group_SO = {
        recurring_cloaker_spawn = {
            interval = {0, 1},
            retire_delay = 30
        },
        recurring_spawn_1 = {
            interval = {0, 1}
        }
    }

    data.besiege.assault.groups = {
        FBI_swats = {
            1,
            1,
            1
        },
        FBI_heavys = {
            1,
            1,
            1
        },
        FBI_shields = {
            1,
            1,
            1
        },
        FBI_tanks = {
            1,
            1,
            1
        },
        CS_tazers = {
            1,
            1,
            1
        },
        FBI_spoocs = {
            1,
            1,
            1
        },
        single_spooc = {
            1,
            1,
            1
        }
    }

    data.besiege.reenforce.groups = {
        CS_defend_a = {
            1,
            1,
            1
        },
        FBI_defend_b = {
            1,
            1,
            1
        },
        FBI_defend_c = {
            1,
            1,
            1
        },
        FBI_defend_d = {
            1,
            1,
            1
        }
    }

    data.besiege.recon.groups = {
        FBI_stealth_a = {
            1,
            1,
            1
        },
        FBI_stealth_b = {
            1,
            1,
            1
        },
        single_spooc = {
            1,
            1,
            1
        }
    }

end

function this:ModifyUnitCategories(data, difficulty_index)

    local access_type_all = { walk = true, acrobatic = true }

    data.special_unit_spawn_limits = {
        tank = 1337,
        taser = 1337,
        spooc = 1337,
        shield = 1337,
    }
    data.unit_categories.FBI_shield.special_type = nil
    data.unit_categories.FBI_tank.special_type = nil
    data.unit_categories.CS_tazer.special_type = nil
    data.unit_categories.CS_shield.special_type = nil
    data.unit_categories.CS_tazer.units = {
        Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
        Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
        Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
    }
    
    data.unit_categories.FBI_tank.units = {
        Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
        Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
        Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
    }
    
    data.unit_categories.FBI_shield.units = {
        Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
        Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
        Idstring("units/payday2/characters/ene_shield_2/ene_shield_2")
    }
    data.unit_categories.spooc.units = {
        Idstring("units/payday2/characters/ene_spook_1/ene_spook_1"),
        Idstring("units/payday2/characters/ene_spook_1/ene_spook_1"),
        Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
    }
    
    data.unit_categories.CS_cop_C45_R870 = data.unit_categories.FBI_shield
    data.unit_categories.CS_cop_stealth_MP5 = data.unit_categories.CS_tazer
    data.unit_categories.CS_swat_MP5 = data.unit_categories.spooc
    data.unit_categories.CS_swat_R870 = data.unit_categories.CS_tazer
    data.unit_categories.CS_heavy_M4 = data.unit_categories.spooc
    data.unit_categories.CS_heavy_M4_w = data.unit_categories.FBI_tank
    data.unit_categories.CS_tazer = data.unit_categories.CS_tazer
    data.unit_categories.CS_shield = data.unit_categories.FBI_tank
    data.unit_categories.FBI_suit_C45_M4 = data.unit_categories.CS_tazer
    data.unit_categories.FBI_suit_M4_MP5 = data.unit_categories.spooc
    data.unit_categories.FBI_suit_stealth_MP5 = data.unit_categories.FBI_shield
    data.unit_categories.FBI_swat_M4 = data.unit_categories.FBI_shield
    data.unit_categories.FBI_swat_R870 = data.unit_categories.FBI_tank
    data.unit_categories.FBI_heavy_G36 = data.unit_categories.CS_tazer
    data.unit_categories.FBI_heavy_G36_w = data.unit_categories.CS_tazer
    data.unit_categories.FBI_tank = data.unit_categories.FBI_tank

end
function this:ModifyTweakData(data, difficulty_index)

    local self = data
    self.enemy_spawn_groups = {}
    self.enemy_spawn_groups.CS_defend_a = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_cop_C45_R870",
                freq = 15,
                tactics = self._tactics.CS_cop,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.CS_defend_b = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_swat_MP5",
                freq = 15,
                amount_min = 18,
                tactics = self._tactics.CS_cop,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.CS_defend_c = {
        amount = {50, 65},
        spawn = {
            {
                unit = "CS_heavy_M4",
                freq = 15,
                amount_min = 18,
                tactics = self._tactics.CS_cop,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.CS_cops = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_cop_C45_R870",
                freq = 15,
                amount_min = 18,
                tactics = self._tactics.CS_cop,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.CS_stealth_a = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_cop_stealth_MP5",
                freq = 3,
                amount_min = 3,
                tactics = self._tactics.CS_cop_stealth,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.CS_swats = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_swat_MP5",
                freq = 15,
                tactics = self._tactics.CS_swat_rifle,
                rank = 2
            },
            {
                unit = "CS_swat_R870",
                freq = 4.5,
                amount_max = 30,
                tactics = self._tactics.CS_swat_shotgun,
                rank = 1
            },
            {
                unit = "CS_swat_MP5",
                freq = 15,
                tactics = self._tactics.CS_swat_rifle_flank,
                rank = 3
            }
        }
    }

    self.enemy_spawn_groups.CS_heavys = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_heavy_M4",
                freq = 15,
                tactics = self._tactics.CS_swat_rifle,
                rank = 2
            },
            {
                unit = "CS_heavy_M4",
                freq = 3.5,
                tactics = self._tactics.CS_swat_rifle_flank,
                rank = 3
            }
        }
    }

    self.enemy_spawn_groups.CS_shields = {
        amount = {50, 60},
        spawn = {
            {
                unit = "CS_shield",
                freq = 15,
                amount_min = 18,
                amount_max = 30,
                tactics = self._tactics.CS_shield,
                rank = 3
            },
            {
                unit = "CS_cop_stealth_MP5",
                freq = 4.5,
                amount_max = 9,
                tactics = self._tactics.CS_cop_stealth,
                rank = 1
            },
            {
                unit = "CS_heavy_M4_w",
                freq = 7.5,
                amount_max = 12,
                tactics = self._tactics.CS_swat_heavy,
                rank = 2
            }
        }
    }

    self.enemy_spawn_groups.CS_tazers = {
        amount = {20, 25},
        spawn = {
            {
                unit = "CS_tazer",
                freq = 15,
                amount_min = 18,
                amount_max = 15,
                tactics = self._tactics.CS_tazer,
                rank = 2
            },
            {
                unit = "CS_swat_MP5",
                freq = 15,
                amount_max = 18,
                tactics = self._tactics.CS_cop_stealth,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.CS_tanks = {
        amount = {5, 8},
        spawn = {
            {
                unit = "FBI_tank",
                freq = 3,
                amount_min = 3,
                tactics = self._tactics.FBI_tank,
                rank = 2
            },
            {
                unit = "CS_tazer",
                freq = 1.5,
                amount_max = 3,
                tactics = self._tactics.CS_tazer,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_defend_a = {
        amount = {40, 40},
        spawn = {
            {
                unit = "FBI_suit_C45_M4",
                freq = 15,
                amount_min = 30,
                tactics = self._tactics.FBI_suit,
                rank = 2
            },
            {
                unit = "CS_cop_C45_R870",
                freq = 15,
                tactics = self._tactics.FBI_suit,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_defend_b = {
        amount = {50, 50},
        spawn = {
            {
                unit = "FBI_suit_M4_MP5",
                freq = 15,
                amount_min = 30,
                tactics = self._tactics.FBI_suit,
                rank = 2
            },
            {
                unit = "FBI_swat_M4",
                freq = 15,
                tactics = self._tactics.FBI_suit,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_defend_c = {
        amount = {50, 50},
        spawn = {
            {
                unit = "FBI_swat_M4",
                freq = 20,
                tactics = self._tactics.FBI_suit,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_defend_d = {
        amount = {30, 40},
        spawn = {
            {
                unit = "FBI_heavy_G36",
                freq = 20,
                tactics = self._tactics.FBI_suit,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_stealth_a = {
        amount = {30, 40},
        spawn = {
            {
                unit = "FBI_suit_stealth_MP5",
                freq = 15,
                amount_min = 30,
                tactics = self._tactics.FBI_suit_stealth,
                rank = 1
            },
            {
                unit = "CS_tazer",
                freq = 15,
                amount_max = 30,
                tactics = self._tactics.CS_tazer,
                rank = 2
            }
        }
    }

    self.enemy_spawn_groups.FBI_stealth_b = {
        amount = {40, 50},
        spawn = {
            {
                unit = "FBI_suit_stealth_MP5",
                freq = 15,
                amount_min = 30,
                tactics = self._tactics.FBI_suit_stealth,
                rank = 1
            },
            {
                unit = "FBI_suit_M4_MP5",
                freq = 7.5,
                tactics = self._tactics.FBI_suit,
                rank = 2
            }
        }
    }

    self.enemy_spawn_groups.FBI_swats = {
        amount = {40, 50},
        spawn = {
            {
                unit = "FBI_swat_M4",
                freq = 15,
                amount_min = 30,
                tactics = self._tactics.FBI_swat_rifle,
                rank = 2
            },
            {
                unit = "FBI_swat_M4",
                freq = 7.5,
                tactics = self._tactics.FBI_swat_rifle_flank,
                rank = 3
            },
            {
                unit = "FBI_swat_R870",
                freq = 4.5,
                amount_max = 30,
                tactics = self._tactics.FBI_swat_shotgun,
                rank = 1
            },
            {
                unit = "spooc",
                freq = 0.15,
                amount_max = 8,
                tactics = self._tactics.spooc,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_heavys = {
        amount = {9, 12},
        spawn = {
            {
                unit = "FBI_heavy_G36",
                freq = 15,
                tactics = self._tactics.FBI_swat_rifle,
                rank = 1
            },
            {
                unit = "FBI_heavy_G36",
                freq = 7.5,
                tactics = self._tactics.FBI_swat_rifle_flank,
                rank = 2
            },
            {
                unit = "CS_tazer",
                freq = 1,
                amount_max = 9,
                tactics = self._tactics.CS_tazer,
                rank = 3
            }
        }
    }

    self.enemy_spawn_groups.FBI_shields = {
        amount = {40, 50},
        spawn = {
            {
                unit = "FBI_shield",
                freq = 15,
                amount_min = 30,
                amount_max = 50,
                tactics = self._tactics.FBI_shield_flank,
                rank = 3
            },
            {
                unit = "CS_tazer",
                freq = 2.5,
                amount_max = 6,
                tactics = self._tactics.CS_tazer,
                rank = 2
            },
            {
                unit = "FBI_heavy_G36",
                freq = 4.5,
                amount_max = 9,
                tactics = self._tactics.FBI_swat_rifle_flank,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.FBI_tanks = {
        amount = {12, 15},
        spawn = {
            {
                unit = "FBI_tank",
                freq = 2,
                amount_max = 20,
                tactics = self._tactics.FBI_tank,
                rank = 1
            },
            {
                unit = "FBI_shield",
                freq = 2,
                amount_min = 20,
                amount_max = 50,
                tactics = self._tactics.FBI_shield_flank,
                rank = 3
            },
            {
                unit = "FBI_heavy_G36_w",
                freq = 2.5,
                amount_min = 8,
                tactics = self._tactics.FBI_heavy_flank,
                rank = 1
            }
        }
    }

    self.enemy_spawn_groups.single_spooc = {
        amount = {8, 20},
        spawn = {
            {
                unit = "spooc",
                freq = 2,
                amount_min = 2,
                tactics = self._tactics.spooc,
                rank = 1
            }
        }
    }
    self.enemy_spawn_groups.FBI_spoocs = self.enemy_spawn_groups.single_spooc

    self.besiege.assault.force = {
        200,
        300,
        400
    }

    self.besiege.assault.force_pool = {
        400,
        800,
        1500
    }

    self.besiege.reenforce.interval = {
        1,
        2,
        3
    }

    self.besiege.assault.force_balance_mul = {
        24,
        32,
        48,
        64
    }
    self.besiege.assault.force_pool_balance_mul = {
        12,
        18,
        24,
        32
    }

    self.besiege.assault.hostage_hesitation_delay = {
        0,
        0,
        0
    }

    self.besiege.assault.delay = {
        20,
        15,
        10
    }

    self.besiege.assault.sustain_duration_min = {
        120,
        160,
        240
    }

    self.besiege.assault.sustain_duration_max = {
        240,
        320,
        480
    }

    self.besiege.assault.sustain_duration_balance_mul = {
        1.3,
        1.5,
        1.7,
        1.9
    }

end
