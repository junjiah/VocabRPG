//
//  simulate_combat.cpp
//  VocabRPG
//
//  Created by Junjia He on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#include "simulate_combat.h"
#include <random>
#include <iostream>

const int kSimulationNumber = 10000;

std::pair<int, int> GenerateEnemyProperty(int hero_hp, int hero_strength,
                                          double accuracy, double desired_pass_rate,
                                          double epsilon=0.02)
{
  // random number generator
  std::uniform_int_distribution<int> uni_hp(0, hero_strength * 2);
  std::uniform_real_distribution<double> uni_strength(0, 0.3);
  std::default_random_engine random_engine;
  
  // a heuristic to initialize the enemy attributes
  int enemy_hp = 2 * hero_hp, enemy_strength = hero_strength;
  double winning_rate;
  
  int iter = 0;
  do {
    winning_rate = SimulateWinningRate(hero_hp, hero_strength, accuracy,
                                              enemy_hp, enemy_strength);
    if (winning_rate >= desired_pass_rate - epsilon &&
        winning_rate <= desired_pass_rate + epsilon) {
      printf("Reasonable enemy: (hp: %d, str: %d) with winning rate %.4f\n",
             enemy_hp, enemy_strength, winning_rate);
      return std::make_pair(enemy_hp, enemy_strength);
    } else {
      printf("(hp: %d, str: %d) yields winning rate of %.4f\n", enemy_hp,
             enemy_strength, winning_rate);
    }
    
    int hp_delta = uni_hp(random_engine);
    int strength_delta = uni_strength(random_engine) * enemy_strength;
    
    if (winning_rate > desired_pass_rate) {
      // in case reduced to negative
      enemy_hp += (hp_delta >= enemy_hp ? 0 : hp_delta);
      enemy_strength += (strength_delta >= enemy_strength ? 0 : strength_delta);
    } else {
      enemy_hp -= hp_delta;
      enemy_strength -= strength_delta;
    }
  } while (iter++ < 100);
  
  // failed to find a reasonable setting
  return std::make_pair(-1, -1);
}

double SimulateWinningRate(int hero_hp, int hero_strength, double accuracy,
                           int enemy_hp, int enemy_strength)
{
  double wins = 0;
  for (int i = 0; i < kSimulationNumber; ++i) {
    wins += SimulateRound(hero_hp, hero_strength, accuracy, enemy_hp, enemy_strength);
  }
  return wins / (double)kSimulationNumber;
}


int SimulateRound(int hero_hp, int hero_strength, double accuracy,
                  int enemy_hp, int enemy_strength)
{
  static std::random_device rd;
  static std::uniform_real_distribution<double> unif(0, 1);
  static std::default_random_engine random_engine(rd());
  
  while (hero_hp > 0 && enemy_hp > 0) {
    double attack_prob = unif(random_engine);
    if (attack_prob <= accuracy) {
      enemy_hp -= hero_strength;
    } else {
      hero_hp -= enemy_strength;
    }
  }
  
  return hero_hp > 0 ? 1 : 0;
}

int main(int argc, char* argv[]) {
  int hero_hp, hero_strength;
  double accuracy, desired_pass_rate;
  
  if (argc != 5)
  {
    std::cout << "Usage: ./simulate_combat <hero_hp> <hero_strength>";
    std::cout << " <accuracy> <desired_pass_rate>" << std::endl;
    exit(0);
  }
  
  sscanf(argv[1], "%d", &hero_hp);
  sscanf(argv[2], "%d", &hero_strength);
  sscanf(argv[3], "%lf", &accuracy);
  sscanf(argv[4], "%lf", &desired_pass_rate);
  
  GenerateEnemyProperty(hero_hp, hero_strength,
                        accuracy, desired_pass_rate);
}