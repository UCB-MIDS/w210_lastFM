
import glob
import random
import struct
import csv
from tensorflow.core.example import example_pb2
import data

import pandas as pd
import numpy as np
import os
import glob
import random
import csv
from tqdm import tqdm
import data

from datetime import datetime as dt
from datetime import timedelta
from sklearn.model_selection import train_test_split



def get_user_id(user_id,vocab):
    try:
        return int(user_id.split('_')[1])
    except Exception as e:
        return vocab.word2id(data.UNKNOWN_TOKEN)


def get_registered_time(registered,vocab):
    try:
        return int(dt.strptime(registered,'%b %d, %Y').strftime('%s'))
    except Exception as e:
        return vocab.word2id(data.UNKNOWN_TOKEN)        
        
    
def get_time(timestamp_str,vocab):
    try:
        return int(dt.strptime(timestamp_str,'%Y-%m-%dt%H:%M:%Sz').strftime('%s'))
    except Exception as e:
        return vocab.word2id(data.UNKNOWN_TOKEN)


def get_gender_id(gender):
    try:
        if(gender.lower() == 'm'):
            return 1 
        elif(gender.lower() == 'f'):
            return 0
        else:
            return -1
    except Exception as e:
        return -1
        

def get_age(age):
    try:
        return int(age)
    except Exception as e:
        return -1

def get_seconds(in_ms):
    return 0.001*in_ms


def get_times_played(time,duration):
    if(duration != 0):
        return time / duration
    else:
        return 0

    
def get_time_difference(t1,t2):
    time1 = dt.strptime(t1,'%Y-%m-%dt%H:%M:%Sz')
    time2 = dt.strptime(t2,'%Y-%m-%dt%H:%M:%Sz')
    return (time2-time1).total_seconds()


def max_session_window():
    return timedelta(minutes=30).total_seconds() 


def get_word_id(word,vocab):
    try:
        word = word.strip()
        if(word):
            return vocab.word2id(word.lower())
        else:
            return vocab.word2id(data.UNKNOWN_TOKEN)
    except Exception as e:    
        return vocab.word2id(data.UNKNOWN_TOKEN)
    
    
def get_start_sequence(vocab,length):
    return [vocab.word2id(data.SQUENCE_START) for i in range(length)]
        
    
def get_end_sequence(vocab,length):
    return [vocab.word2id(data.SQUENCE_END) for i in range(length)]

