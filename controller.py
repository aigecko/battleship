#!/usr/bin/python

import glob
import sys
import os
import random

GENERATION_COUNT = 2

def tournament(population, tournament_size):
    mating_pool = []
    while len(mating_pool) < len(population) // 2:
        parent1 = competition(*random.sample(population, tournament_size))
        while True:
            parent2 = competition(*random.sample(population, tournament_size))
            if parent1 != parent2:
                break
        mating_pool.append((parent1, parent2))
        
    return mating_pool

def competition(*contestants):
    print("./bin/play.rb " + name(contestants[0]) + ' ' + name(contestants[1]))
    return contestants[0]

def mate(mating_pool):
    offspring = []
    for pair in mating_pool:
        offspring1 = new_idx()
        offspring2 = new_idx()
        print('./crossover ' + str(pair[0]) + ' ' + str(pair[1]) + ' ' + str(offspring1) + ' ' + str(offspring2))
        offspring.extend([offspring1, offspring2])
    return offspring


def make_index_generator(init_index):
    def new_idx():
        nonlocal init_index
        init_index += 1
        return init_index
    return new_idx

def name(index):
    return './players/' + str(index) + '.rb'

if __name__ == '__main__':
    if len(sys.argv) != 2 or not sys.argv[1].isdecimal():
        print('Usage : ' + __file__ + ' [initial_population_size]')
        exit(0)

    population = [i for i in range(1, int(sys.argv[1]) + 1)]
    print(population)
    global new_idx
    new_idx = make_index_generator(len(population))

    for _ in range(GENERATION_COUNT):
        mating_pool = tournament(population, 2)
        offspring = mate(mating_pool)
        population = offspring

