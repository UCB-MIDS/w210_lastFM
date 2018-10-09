

import glob
import pandas as pd
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM,GRU
from sklearn import preprocessing
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import mean_squared_error,mean_absolute_error
import tensorflow as tf
import numpy as np

from matplotlib import pyplot
from math import sqrt
from numpy import concatenate


def experiment(hps,dropout):
    train_X, train_y  = get_data(hps.train_file,hps)
    print('TRAIN:: ',train_X.shape,train_y.shape)


    validate_X, validate_y  = get_data(hps.validate_file,hps)
    print('VALIDATE:: ',validate_X.shape,validate_y.shape)    
    
    
    # design network
    if(hps.model_lstm):
        if(hps.layered):
            model = get_layered_lstm(hps,train_X,dropout)
        else:
            model = get_lstm(hps,train_X,dropout)
    else:    
        model = get_gru(hps,train_X,dropout)
        
    # fit network
    history = model.fit(train_X, train_y, 
                        epochs=hps.epochs, 
                        batch_size=hps.batch_size, 
                        validation_data=(validate_X, validate_y), 
                        verbose=2, 
                        shuffle=False)
    # plot history
    pyplot.plot(history.history['loss'], label='train')
    pyplot.plot(history.history['val_loss'], label='test')
    pyplot.legend()
    pyplot.show()   
    
    
    test_X, test_y  = get_data(hps.test_file,hps)
    print('TEST:: ',test_X.shape,test_y.shape)    
    
    # make a prediction
    yhat = model.predict(test_X)
    test_X = test_X.reshape((test_X.shape[0], test_X.shape[2]))

    # invert scaling for forecast
    inv_yhat = concatenate((yhat, test_X[:, 1:]), axis=1)
    inv_yhat = inv_yhat[:,0]

    # invert scaling for actual
    test_y = test_y.reshape((len(test_y), 1))
    inv_y = concatenate((test_y, test_X[:, 1:]), axis=1)
    inv_y = inv_y[:,0]
    
    return get_performace(inv_y,inv_yhat,test_X.shape[0],hps)



def get_data(file_name,hps):
    columns = ['start','user','session_id','gender','age','country','registered',
               'prev_session_length','avg_session_length','session_length']
    complete_files = glob.glob(file_name)
    dataset = pd.concat((pd.read_csv(f,names=columns,sep='\t') for f in complete_files))
    
    if(hps.filter_outliers):
        df_perc = np.percentile(dataset.session_length, [hps.upper_limit])
        dataset =  dataset[dataset.session_length < df_perc[0]]
        dataset =  dataset[dataset.prev_session_length < df_perc[0]]

    dataset = dataset.sort_values(by=['start'])  
    
    values = dataset.values
    X = values[:,:-1]
    y = values[:,-1]    
    
    #3D - samples,timesteps,features
    X = X.reshape((X.shape[0], 1, X.shape[1]))
    return X,y


def get_layered_lstm(hps,train_X,dropout):
    model = Sequential()
    
    model.add(LSTM(hps.layer_dims, 
                   input_shape=(train_X.shape[1], 
                                train_X.shape[2]),
                   return_sequences=True,
                   dropout=dropout))
    for i in range(hps.no_layers):
        model.add(LSTM(hps.hidden_dim, 
                       dropout=dropout))
    
    model.add(Dense(1))
    model.compile(loss=hps.loss_func, 
                  optimizer=hps.optimizer)
    return model

def get_lstm(hps,train_X,dropout):
    model = Sequential()
    
    model.add(LSTM(hps.hidden_dim, 
                   input_shape=(train_X.shape[1], 
                                train_X.shape[2]),
                   dropout=dropout))
    
    model.add(Dense(1))
    model.compile(loss=hps.loss_func, 
                  optimizer=hps.optimizer)
    return model


def get_gru(hps,train_X):
    model = Sequential()
    model.add(GRU(hps.hidden_dim, 
                   input_shape=(train_X.shape[1], 
                                train_X.shape[2])))
    
    model.add(Dense(1))
    model.compile(loss=hps.loss_func, 
                  optimizer=hps.optimizer)
    return model


def get_performace(y,y_hat,samples,hps):
    # calculate RMSE
    rmse = sqrt(mean_squared_error(y, y_hat))
#    print('Test RMSE: %.3f' % rmse)
    
    mae = mean_absolute_error(y, y_hat)
#    print('Test MAE: %.3f' % mae)
    
    norm = mae/hps.baseline_mae
#    print('Baseline Normalized MAE: %.3f' % norm)
    
    print('METRICS :: RMSE: {0} ; MAE: {1} ; Normalized MAE: {2}'.format(rmse,mae,norm))    
#     pyplot.figure()
#     pyplot.plot(y, label='actual')
#     pyplot.plot(y_hat, label='pred')
#     pyplot.legend()
#     pyplot.show()   
    
    return rmse,mae,norm


    
def get_data_1(file_name):
    columns = ['start','user','session_id','gender','age','country','registered',
               'prev_session_length','avg_session_length','session_length']
    complete_files = glob.glob(file_name)
    dataset = pd.concat((pd.read_csv(f,names=columns,sep='\t') for f in complete_files))
    
    values = dataset.values
    X = values[:,:-1]
    y = values[:,-1]    
    
    #3D - samples,timesteps,features
    X = X.reshape((X.shape[0], 1, X.shape[1]))
    return X,y


def get_sorted_data_1(file_name):
    columns = ['start','user','session_id','gender','age','country','registered',
               'prev_session_length','avg_session_length','session_length']
    complete_files = glob.glob(file_name)
    dataset = pd.concat((pd.read_csv(f,names=columns,sep='\t') for f in complete_files))
    dataset = dataset.sort_values(by=['start'])    
    
    values = dataset.values
    X = values[:,:-1]
    y = values[:,-1]    
    
    #3D - samples,timesteps,features
    X = X.reshape((X.shape[0], 1, X.shape[1]))
    return X,y
