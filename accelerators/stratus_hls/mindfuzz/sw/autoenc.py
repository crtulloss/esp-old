# Custom autoencoder and Keras autoencoder comparison
#
# Author: Abhinav Parihar

import numpy as np
# from myutils.widgets import ProgressBar, KerasProgressBar

# Custom autoencoder
class Autoencoder:
	def __init__(self,rate=1e-6):
		self.w1 = np.ones(4,dtype='float32')
		self.w2 = np.ones(4,dtype='float32')
		self.dw1 = np.zeros(4,dtype='float32')
		self.dw2 = np.zeros(4,dtype='float32')
		self.r = np.float32(rate)
		
	def train(self,X,batch_size=70,epochs=1,progress=True):
		for i in range(0,len(X),batch_size):
			for e in range(epochs):
				self.batch(X[i:i+batch_size])
	def sample(self,x):
		x = np.float32(x)
		h = self.w1.dot(x)
		y = h * self.w2
		e = x - y
		self.dw2 += 2 * h * e
		self.dw1 += 2 * x * e.dot(self.w2)
		
	def batch(self,X):
		self.dw1 = np.zeros(4,dtype='float32')
		self.dw2 = np.zeros(4,dtype='float32')
		for x in X:
			self.sample(x)
		k = np.float32(1/np.size(X))
		dw1 = self.r * self.dw1 * k
		dw2 = self.r * self.dw2 * k
		self.w1 += dw1
		self.w2 += dw2

# Keras autoencoder
from keras.layers import Dense
from keras import Input
from keras import Sequential
from keras.initializers import Zeros, Ones
from keras.optimizers import SGD

class KerasAutoencoder():
	def __init__(self,rate=1e-6):
		self.w1 = np.ones(4,dtype='float32')
		self.w2 = np.ones(4,dtype='float32')
		self.model = Sequential()
		self.model.add(Dense(1, input_shape=(4,),
								use_bias=False,
								kernel_initializer=Ones(), 
								bias_initializer=Zeros()))
		self.model.add(Dense(4, use_bias=False,
								kernel_initializer=Ones(), 
								bias_initializer=Zeros()))
		self.model.compile(optimizer=SGD(learning_rate=rate), loss='mse')
	
	def train(self,X,batch_size=70,epochs=1,progress=True):
		cb = []
		self.model.fit(X,X,epochs=epochs,batch_size=batch_size,
					shuffle=False,verbose=False,
					callbacks=cb)
		self.w1 = self.model.layers[0].get_weights()[0].T
		self.w2 = self.model.layers[1].get_weights()[0]
					
if __name__=='__main__':
	n = 1000
	amp = 400
	noise = 10
	p = amp*np.random.rand(n)
	w = np.array([1.2, 0.8, 0.5, 0.7])
	x1 = w[0]*p + noise*np.random.rand(n)
	x2 = w[1]*p + noise*np.random.rand(n)
	x3 = w[2]*p + noise*np.random.rand(n)
	x4 = w[3]*p + noise*np.random.rand(n)
	X = np.array([x1,x2,x3,x4]).T
	kae = KerasAutoencoder()
	ae = Autoencoder()
	kae.train(X,epochs=1,batch_size=30,progress=False)
	ae.train(X,epochs=1,batch_size=30,progress=False)
	print('   My W1 : ',np.round(ae.w1,3))
	print('Keras W1 : ',np.round(kae.w1,3))
	print('   My W2 : ',np.round(ae.w2,3))
	print('Keras W2 : ',np.round(kae.w2,3))
	print('  Orig W : ',np.round(w,3))
	wn = w/np.linalg.norm(w)
	w2n = ae.w2/np.linalg.norm(ae.w2)
	angle = np.arccos(np.dot(wn,w2n))*180/np.pi
	print('Ang W-W2 : ',angle)
	
