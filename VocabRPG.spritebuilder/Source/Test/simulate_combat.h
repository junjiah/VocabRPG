//
//  simulate_combat.h
//  VocabRPG
//
//  Created by Junjia He on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#ifndef __VocabRPG__simulate_combat__
#define __VocabRPG__simulate_combat__

#include <stdio.h>
#include <cstdlib>
#include <utility>

int SimulateRound(int hero_hp, int hero_strength, double accuracy,
               int enemy_hp, int enemy_strength);

double SimulateWinningRate(int hero_hp, int hero_strength, double accuracy,
                    int enemy_hp, int enemy_strength);

std::pair<int, int> GenerateEnemyProperty(int hero_hp, int hero_strength,
                                          double accuracy);

#endif /* defined(__VocabRPG__simulate_combat__) */
