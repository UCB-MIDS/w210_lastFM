

import pandas as pd
import numpy as np
import os
import glob
import random
import csv
import data
import util
from data import Vocab
from tqdm import tqdm

from datetime import datetime as dt
from datetime import timedelta
from sklearn.model_selection import train_test_split



summary_file = '/data_data/session_length/nishanth01/data/summary/{0}/{1}.csv'
final_dir = '/data_data/session_length/nishanth01/data/summary/'
vocab_file = '/data_data/session_length/nishanth01/data/country_vocab.csv'


def get_users(test=0.1,val=0.1):
    columns = ['user_id']
    users = pd.read_csv('/data_data/session_length/nishanth01/data/unique_users.txt',names=columns)
    _,test_df = train_test_split(users, test_size=test+val)
    test_users,val_users = train_test_split(test_df, test_size=(val)/(test+val))
    return users,test_users,val_users


def get_user_details(user_id):
    file_name = '/data_data/session_length/nishanth01/data/users/{0}/*.csv'.format(user_id) 
    columns = ['user_id','timestamp','artist_name',
               'track_name','gender','age','country',
               'registered','duration','genre']
    
    complete_files = glob.glob(file_name)
    user_data = pd.concat((pd.read_csv(f,names=columns,sep='\t') for f in complete_files))
    return user_data

    
def process_prev_row(row,curr_time,session_start,session_id,session_length,vocab,prev_length,total):
    data = []
    new_session = False
    prev_time = row[1]['timestamp']
    times_played = 0
    
    try:
        track_duration = util.get_seconds(float(row[1]['duration']))  
    except Exception:
        track_duration = 0

    try:
        diff = util.get_time_difference(prev_time,curr_time)
        
        if(track_duration > 0):
            if(diff <= track_duration):#same session
                session_length = session_length + diff
                times_played = util.get_times_played(diff,track_duration)
            else:
                if((diff-track_duration) > util.max_session_window()):#next is new session
                    session_length = session_length + track_duration
                    times_played = util.get_times_played(track_duration,track_duration)
                    new_session = True
                else:    
                    session_length = session_length + diff    
                    times_played = util.get_times_played(diff,track_duration)
        else:    
            if(diff > util.max_session_window()):#next is new session
                new_session = True
            else:    
                session_length = session_length + diff   
                
                
        data.append(util.get_time(session_start,vocab))#start timestamp
        data.append(util.get_user_id(row[1]['user_id'],vocab))#user
#        data.append(util.get_time(curr_time,vocab))#end timestamp
        data.append(int(session_id))#session_id
        data.append(util.get_gender_id(row[1]['gender']))#gender id
        data.append(util.get_age(row[1]['age']))#age
        data.append(util.get_word_id(row[1]['country'],vocab))#country id
        data.append(util.get_registered_time(row[1]['registered'],vocab))#registered time
        data.append(int(prev_length))#previous session length
        if((session_id != 0) and ((session_id - 1) != 0)):
            average = float("{0:.2f}".format((total/(session_id - 1))))
        else:
            average = float(0)
        data.append(average)#avg session length
        data.append(int(session_length))#session_length

    except Exception as e:
        print(e)
        new_session = True
        
    return new_session,session_length,data



def create_user(user_id,test,val,vocab):
    user = get_user_details(user_id)
    user = user.sort_values(by=['timestamp'])
    total_count = len(user.index)
    test_index = int(total_count*random.uniform(0.5, 1))
    write_flag = False
    
    test_file = ''
    train_file = final_dir+'train/{0}.csv'.format(user_id)
    if(test):
        test_file = final_dir+'test/{0}.csv'.format(user_id)
    else:
        test_file = final_dir+'validate/{0}.csv'.format(user_id)    

        
    session_length = 0
    prev_length = 0
    total = 0
    
    session_id = 1
    curr_time = ''
    prev_time = ''
    session_start = ''
    new_session = False
    
    i = 0
    delete = False
    if(not test and not  val):
        delete = True
    
    with open(train_file,'w+') as train_out,open(test_file,'w+') as test_out:
        train_out = csv.writer(train_out,quoting=csv.QUOTE_NONNUMERIC,delimiter='\t')
        test_out = csv.writer(test_out,quoting=csv.QUOTE_NONNUMERIC,delimiter='\t')
        data = []
        
        try:
            for row in user.iterrows():
                try:
                    data = []
                    if(i == 0):#first time
                        session_id = 1
                        session_start = row[1]['timestamp']
                        prev_row = row
#                         train_out.writerow(util.get_start_sequence(vocab,9))  
#                         if(test or val):
#                             test_out.writerow(util.get_start_sequence(vocab,9))     

                    else:    
                        if(prev_row):
                            new_session,session_length,data = process_prev_row(prev_row,
                                                                               row[1]['timestamp'],
                                                                               session_start,
                                                                               session_id,
                                                                               session_length,
                                                                               vocab,
                                                                               prev_length,
                                                                               total)
                            prev_row = row
                            
                        else:
                            raise Exception('Unhandled error..!')

                        if(new_session):
                            total = total + session_length
                            prev_length = session_length
                            session_id = session_id + 1
                            session_length = 0
                            session_start = row[1]['timestamp']
                            write_flag = True


                    if(data and write_flag):
                        if((test or val) and i > test_index):
                            test_out.writerow(data)
                        else:
                            train_out.writerow(data)     

                        write_flag = False
                        data = []

                except Exception as e:
                    print('EXCEPTION(1): Skipping...',e)
                    pass
                
                i = i+1        
                

            if(data):
                if((test or val) and i > test_index):
                    test_out.writerow(data)
                else:
                    train_out.writerow(data)     

#             if(test or val):
#                 test_out.writerow(util.get_start_sequence(vocab,9))     
#             train_out.writerow(util.get_end_sequence(vocab,9))       
        except Exception as e:
            print('EXCEPTION(1.1): Skipping...',e)
            pass
            
    if(delete):
        try:
            os.remove(test_file) 
        except OSError:
            pass
        
    print('COMPLETED: {0}'.format(user_id))
    
    
def process(vocab):
    print('Starting..')
    failed = []
    try:
        i = 0
        users,test_users,val_users = get_users()
        for row in users.iterrows():
            try:
                test = False
                val = False
                user_id = row[1]['user_id']
                if(len(test_users.loc[test_users['user_id'] == user_id].index)):
                    test = True
                elif (len(val_users.loc[val_users['user_id'] == user_id].index)):
                    val = True
                create_user(user_id,test,val,vocab)
            except Exception as e:
                failed.append(user_id)
                pass
            i += 1
#             if(i == 4):
#                 break
    except Exception as e:
        print('EXCEPTION 0 :::',e)
    finally:
        print('FAILED Users: ',failed)
        
    print('COMPLETE!')    


if __name__ == '__main__':
    vocab = Vocab(vocab_file)
    process(vocab)    
