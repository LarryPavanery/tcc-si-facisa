# -*- coding: utf-8 -*-
import glob
import os

path = os.path.abspath("../output/matrizesConfusao")
filtro = "*.csv"
path = os.path.join(path, filtro)

files = glob.glob(path)

#exemplo de arquivo a ser consumido
#[20155293416]-test-with-training[[201552795125]-experimento[class-10-uterances-10-num_loc_masc-8-num_loc_fem-8].csv]-assertiveness[[6.66666666666667 0 75 0 50 68.75 12.5 0 18.75 100]%]-user[F4]

class Experimento:
	def __init__ (self, name) :
		self.name = name
		self._assertiveness = None
		self._counter = 0

	def plus_assertiveness (self, assertiveness) :
		self._counter += 1

		if self._assertiveness is None :
			self._assertiveness = [ 0.0 for val in range(len(assertiveness)) ]

		for index, value in enumerate(self._assertiveness) :
			self._assertiveness[index] = value + float(assertiveness[index])

	def mean (self) :
		mean = [ (assertiveness / self._counter) for assertiveness in self._assertiveness ]
		return mean

	def single_mean (self) :
		return (sum(self.mean()) / len(self.mean()))


def merge () :
	'''
		Merge all files
	'''
	experimentos = {}
	print "Amount of files: ", len(files)

	for file in files:
		info = file.split("experimento")
		name, assertiveness = info[1].split(".csv")[0], info[1].split("[[")[1].split("]%]")[0].split(" ")

		if experimentos.get(name) is None :
			e = Experimento(name)
			e.plus_assertiveness(assertiveness)
			experimentos[name] = e

		else :
			e = experimentos[name]
			e.plus_assertiveness(assertiveness)
			experimentos[name] = e

	print "Reduced to", len(experimentos.keys())
	
	return dict([ (k, v) for k, v in experimentos.items() ])

show = merge().values()
show.sort(key=lambda obj: - obj.single_mean())

for v in show:
	print v.name, [ round(val, 2) for val in v.mean()], round(v.single_mean(),2)











