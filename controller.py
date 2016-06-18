#!/usr/bin/python

import sys
import os
import random
import time
import queue

GENERATION_COUNT = 1
PARALLEL_TASK = 7
PORT_START = 30001

# Queue Initialize
PORT_QUEUE = queue.Queue(PARALLEL_TASK)
for p in range(PORT_START, PORT_START + PARALLEL_TASK * 3, 3):
    PORT_QUEUE.put(p, True)
TASK_TABLE = {}

class CompeteTask:
    def __init__(self, pid, port, read, contestants):
        self.contestants = contestants
        self.pid = pid
        self.port = port
        self.read_fd = read
        self.is_complete = False
        self.winner = self.high_hit_rate
        self.couple_pid = 0

    def read(self):
        self.read_fo = os.fdopen(self.read_fd)
        data = self.read_fo.read().split('\n')
        self.round = eval(data[0])
        self.fired = eval(data[1])
        self.hit = eval(data[2])
        self.miss = eval(data[3])
        self.unknown = eval(data[4])
        self.fixed = eval(data[5])
        self.win = int(data[6].strip('\n.rb '))
        self.is_complete = True

    def close(self):
        self.read_fo.close()

    def show(self):
        print('NAME\tROUND\tHIT\tMISS\tFIX\t')
        print('%d\t%d\t%.4f%%\t%.4f%%\t%.4f%%' % (self.contestants[0], self.fired[0], \
            self.hit[0]/self.fired[0], self.miss[0]/self.fired[0], self.fixed[0]/self.fired[0]))
        print('%d\t%d\t%.4f%%\t%.4f%%\t%.4f%%' % (self.contestants[1], self.fired[1], \
            self.hit[1]/self.fired[1], self.miss[1]/self.fired[1], self.fixed[1]/self.fired[1]))

    def has_couple(self):
        return self.couple_pid != 0

    def couple(self):
        return TASK_TABLE[self.couple_pid]

    def high_hit_rate(self):
        if self.hit[0]/self.fired[0] > self.hit[1]/self.fired[1]:
            return self.contestants[0]
        else:
            return self.contestants[1]

    def low_fixed(self):
        if self.fixed[0]/self.fired[0] < self.fixed[1]/self.fired[1]:
            return self.contestants[0]
        else:
            return self.contestants[1]

def tournament(population, tournament_size):
    mating_pool = []
    for i in range(len(population) // 2):
        while PORT_QUEUE.empty():
            wait_complete(mating_pool, population, tournament_size)
        port1 = PORT_QUEUE.get(True)
        task1 = competition(port1, *random.sample(population, tournament_size))
        TASK_TABLE[task1.pid] = task1
        while PORT_QUEUE.empty():
            wait_complete(mating_pool, population, tournament_size)
        port2 = PORT_QUEUE.get(True)
        task2 = competition(port2, *random.sample(population, tournament_size))
        TASK_TABLE[task2.pid] = task2
        TASK_TABLE[task1.pid].couple_pid = task2.pid
        TASK_TABLE[task2.pid].couple_pid = task1.pid

    while len(mating_pool) < len(population) // 2 or not PORT_QUEUE.full():
        wait_complete(mating_pool, population, tournament_size)
        
    return mating_pool

def wait_complete(mating_pool, population, tournament_size):
    pid = os.wait()[0]
    print('PORT ', TASK_TABLE[pid].port, ' PID ', pid, ' COMPLETE', file=sys.stderr)
    TASK_TABLE[pid].read()
    TASK_TABLE[pid].show()
    TASK_TABLE[pid].close()
    PORT_QUEUE.put(TASK_TABLE[pid].port, True)
    if TASK_TABLE[pid].has_couple() and TASK_TABLE[pid].couple().is_complete:
        parent1 = TASK_TABLE[pid].winner()
        parent2 = TASK_TABLE[pid].couple().winner()
        if parent1 == parent2:
            port = PORT_QUEUE.get(True)
            task = competition(port, *random.sample(population, tournament_size))
            task.couple_pid = pid
            TASK_TABLE[task.pid] = task
            TASK_TABLE[pid].couple_pid = task.pid
        else:
            mating_pool.append([parent1, parent2])

def competition(port, *contestants):
    r, w = os.pipe()
    pid = os.fork()
    if pid == 0:
        os.close(r)
        os.dup2(w, 1)
        os.execl("./bin/play.rb", "./play.rb", name(contestants[0]), name(contestants[1]), '0', str(port))
    os.close(w)
    print('PORT ', port, ' PID ', pid, ' DELIVERED', file=sys.stderr)
    return CompeteTask(pid, port, r, contestants)

def mate(mating_pool):
    offspring = []
    wait_list = []
    for pair in mating_pool:
        offspring1 = new_idx()
        offspring2 = new_idx()
        pid = os.fork()
        if pid == 0:
            os.execl('./crossover', './crossover', str(pair[0]), str(pair[1]), str(offspring1), str(offspring2),'0')
        print('%d %d => %d %d' %(pair[0], pair[1], offspring1, offspring2))
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
        print('Generation : ', i)
        print('Population : ', population)
        mating_pool = tournament(population, 2)
        offspring = mate(mating_pool)
        population = offspring

