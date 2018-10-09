
import glob
import random
import struct
import csv
from tensorflow.core.example import example_pb2


SQUENCE_START = '<s>'
SQUENCE_END = '</s>'
START_DECODING = '[START]' 
STOP_DECODING = '[STOP]' 
UNKNOWN_TOKEN = '[UNK]'


class Vocab(object):
    
    def __init__(self, vocab_file):
        self._word_to_id = {}
        self._id_to_word = {}
        self._count = 0 

        for w in [UNKNOWN_TOKEN, START_DECODING, STOP_DECODING,SQUENCE_START,SQUENCE_END]:
            self._word_to_id[w] = self._count
            self._id_to_word[self._count] = w
            self._count += 1


        with open(vocab_file, 'r') as vocab_f:
            reader = csv.reader(vocab_f, delimiter='\t')
            for row in reader:
                w = row[0]
                if(w in [SQUENCE_START, SQUENCE_END, UNKNOWN_TOKEN,START_DECODING,STOP_DECODING]):
                    raise Exception('{0} should not be in the vocab file:'.format(w))
                if w in self._word_to_id:
                    raise Exception('Duplicate word in vocabulary file: {0}'.format(w))
                    
                self._word_to_id[w] = self._count
                self._id_to_word[self._count] = w
                self._count += 1

        print("Vocabulary complete with {0} words. Last word added: {1}".format(self._count, 
                                                                               self._id_to_word[self._count-1]))

        
    def word2id(self, word):
        if word not in self._word_to_id:
            return self._word_to_id[UNKNOWN_TOKEN]
        return self._word_to_id[word]

    def id2word(self, word_id):
        if word_id not in self._id_to_word:
            raise ValueError('Id not found in vocab: {0}'.format(word_id))
        return self._id_to_word[word_id]

    def size(self):
        return self._count   