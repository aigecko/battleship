#!/usr/bin/python

import sys
import os
import random
import time

GENERATION_COUNT = 20


class CompeteTask:
    def __init__(pid, port):
        self.pid = pid
        self.port = port
        self.read_handle

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
    r, w = os.pipe()
    pid = os.fork()
    if pid == 0:
        os.close(r)
        os.dup2(w, 1)
        os.execl("./bin/play.rb", "./play.rb", name(contestants[0]), name(contestants[1]), '0')
    os.close(w)
    read = os.fdopen(r)
    data = read.read().split('\n')
    rnd, fired, hit, miss, unknown, fix = eval(data[0]), eval(data[1]), eval(data[2]), eval(data[3]), eval(data[4]), eval(data[5])
    print('NAME\tROUND\tHIT\tMISS\tFIX\t', file=sys.stderr)
    print('%d\t%d\t%.4f%%\t%.4f%%\t%.4f%%' % (contestants[0], fired[0], hit[0]/fired[0], miss[0]/fired[0], fix[0]/fired[0]), file=sys.stderr)
    print('%d\t%d\t%.4f%%\t%.4f%%\t%.4f%%' % (contestants[1], fired[1], hit[1]/fired[1], miss[1]/fired[1], fix[1]/fired[1]), file=sys.stderr)

    winner = ''
    if fix[0]/fired[0] < fix[1]/fired[1]:
        winner = contestants[0]
    else:
        winner = contestants[1]
    os.close(r)
    os.waitpid(pid, 0)
    return winner

def mate(mating_pool):
    offspring = []
    wait_list = []
    for pair in mating_pool:
        offspring1 = new_idx()
        offspring2 = new_idx()
        pid = os.fork()
        if pid == 0:
            os.execl('./crossover', './crossover', str(pair[0]), str(pair[1]), str(offspring1), str(offspring2),'0')
        print('%d %d => %d %d' %(pair[0], pair[1], offspring1, offspring2), file=sys.stderr)
        wait_list.append(pid)
        offspring.extend([offspring1, offspring2])
    while len(wait_list) != 0:
        pid = os.wait()[0]
        wait_list.remove(pid)
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
    global new_idx
    new_idx = make_index_generator(len(population))

    for i in range(GENERATION_COUNT):
        print('Generation : ', i, file=sys.stderr)
        print('Population : ', population, file=sys.stderr)
        mating_pool = tournament(population, 2)
        offspring = mate(mating_pool)
        population = offspring

