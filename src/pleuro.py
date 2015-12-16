#!/usr/bin/env python

import nxt.locator
from nxt.motor import *
from nxt.sensor import *

from random import randint

'''
    Go forward until a specific distance
    Return Values:
        0 - distance traversed
        1 - proximity alarm
        2 - food (clear beneath robot)
'''
def forward(pleuro, motors, dist, prox):
    motors.run(100)
    while(1):
        if(dist < 0):
            print 'distance traversed'
            return 0;
        if(Ultrasonic(pleuro, PORT_1).get_sample() < prox):
            print 'proximity alarm'
            return 1;
        if(Color20(pleuro, PORT_3).get_color() == 1):
            print 'FOOD!!!'
            return 2;
        dist = dist - 10
        try:
            print Ultrasonic(pleuro, PORT_1).get_sample(), dist, Color20(pleuro, PORT_3).get_color()
        except ValueError:
            print 'color wrong'
    print 'returning'


def lunge(pleuro):
    power = 120                      # Set power to 120
    dist = randint(50, 100)          # Random number between 50 - 100

    loopRange = randint(5,10)

    for x in range(0, loopRange):
        m_left.turn(power, dist)        # Sets left motor to turn "left"
        m_right.turn(power, dist)       # Sets right motor to turn "right"

    for x in range(0, loopRange):
        m_left.turn(-power, dist)       # Sets left motor to turn "left"
        m_right.turn(-power, dist)      # Sets right motor to turn "right"


def defend(pleuro, defendCount):
    
    m_left = Motor(pleuro, PORT_A)
    m_right = Motor(pleuro, PORT_C)
    
    for x in range(0, 3):
        power = 100                     # Set power to 100
        dist = randint(20, 100)         # Random number between 20 - 100
        m_left.turn(-power, dist)       # Sets left motor to turn "left"
        m_right.turn(power, dist)       # Sets right motor to turn "right"
        if(Color20(pleuro, PORT_3).get_color() != 1):
            return;

    while(defendCount > 0):
        
        try:
            print 'defend', Ultrasonic(pleuro, PORT_1).get_sample(), Color20(pleuro, PORT_3).get_color()
        except ValueError:
            print 'color wrong'
    
        power = 100                     # Set power to 100
        dist = randint(200, 500)        # Random number between 200 - 500
        m_left.turn(-power, dist)       # Sets left motor to turn "left"
        m_right.turn(power, dist)       # Sets right motor to turn "right"
        
        if(Ultrasonic(pleuro, PORT_1).get_sample() < 25): # If object gets too cloase, attack
            lunge(pleuro)
        elif(Color20(pleuro, PORT_3).get_color() == 1):   # Protect the food!
            print 'FOOD!!!'
        else:                                             # No food, reduce defence
            defendCount -= 1



'''
    random 90 degree turn
'''
def random_turn(pleuro):
    
    power = 100                     # Set power to 100
    left  = randint(250, 500)       # Random number between 250 - 500
    right = randint(250, 500)       # Random number between 250 - 500
    
    # If odd, go left, if even go right
    if(randint(1,10) % 2 == 0):
        power = -power
    
    m_left = Motor(pleuro, PORT_A)  # Creates left motor object, for Port A, on Pleuro
    m_left.turn(power, left)        # Sets left motor object to turn "left" (variable above) with 100 power
    m_right = Motor(pleuro, PORT_C) # Creates right motor object, for Port C, on Pleuro
    m_right.turn(-power, right)     # Sets right motor object to turn "right" (variable above) with 100 power

'''
   near 80 degree turn
'''
def avoid_turn(pleuro):             # Stops and b   acks up - still buggy
    power = 100                     # Sets power to 100
    dist  = randint(600, 1000)      # Random number between 600 - 1000
    m_left = Motor(pleuro, PORT_A)
    m_right = Motor(pleuro, PORT_C)

    # backup
    m_left.turn(-power, 100)        # Sets left motor to reverse turn "left" with power 100
    m_right.turn(-power, 100)       # Sets right motor to reverse turn "right" with power 100
    m_left.turn(-power, 150)        # Sets left motor to reverse turn "left" with power 200
    m_right.turn(-power, 150)       # Sets right motor to reverse turn "right" with power 100
    
    # turn
    m_left.turn(-power, dist)       # Sets left motor to turn "left"
    m_right.turn(power, dist)       # Sets right motor to turn "right"


'''
   ___ MAIN LOOP ___
'''
pleuro = nxt.locator.find_one_brick()
m_left = Motor(pleuro, PORT_A)
m_right = Motor(pleuro, PORT_C)
motors = SynchronizedMotors(m_left, m_right, 0)
decision = 2                        # Created a variable called decision and set it = 2

while(1):
    decision = forward(pleuro, motors, 80, 15)
    motors.brake()
    if(decision is 0):              # dist traversed
        random_turn(pleuro)
    elif(decision is 1):            # prox alarm
        avoid_turn(pleuro)
    elif(decision is 2):            # food alarm
        defend(pleuro, 5)


