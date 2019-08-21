from cpp11_std_array import *
import sys


def failed(a, b, msg):
    raise RuntimeError, msg + " " + str(list(a)) + " " + str(list(b))


def compare_sequences(a, b):
    if len(a) != len(b):
        failed(a, b, "different sizes")
    for i in range(len(a)):
        if a[i] != b[i]:
            failed(a, b, "elements are different")

def compare_containers(pythonlist, alaqilarray):
    compare_sequences(pythonlist, alaqilarray)

def steps_exception(alaqilarray, i, j, step):
    try:
        if i == None and j == None:
            a = alaqilarray[::step]
        elif i == None:
            a = alaqilarray[:j:step]
        elif j == None:
            a = alaqilarray[i::step]
        else:
            a = alaqilarray[i:j:step]
        raise RuntimeError, "alaqilarray[" + str(i) + ":" + str(j) + ":" + str(step) + "] missed steps exception for " + str(list(alaqilarray))
    except ValueError, e:
#        print("exception: {}".format(e))
        pass

def del_exception(alaqilarray, i, j, step):
    try:
        if i == None and j == None:
            del alaqilarray[::step]
        elif j == None and step == None:
            del alaqilarray[i]
        elif i == None:
            del alaqilarray[:j:step]
        elif j == None:
            del alaqilarray[i::step]
        else:
            del alaqilarray[i:j:step]
        raise RuntimeError, "alaqilarray[" + str(i) + ":" + str(j) + ":" + str(step) + "] missed del exception for " + str(list(alaqilarray))
    except ValueError, e:
#        print("exception: {}".format(e))
        pass

def setslice_exception(alaqilarray, newval):
    try:
        alaqilarray[::] = newval
        raise RuntimeError, "alaqilarray[::] = " + str(newval) + " missed set exception for alaqilarray:" + str(list(alaqilarray))
    except TypeError, e:
#        print("exception: {}".format(e))
        pass


# Check std::array has similar behaviour to a Python list
# except it is not resizable

ps = [0, 1, 2, 3, 4, 5]

ai = ArrayInt6(ps)

compare_containers(ps, ai)

# slices
compare_containers(ps[0:6], ai[0:6])
compare_containers(ps[0:10], ai[0:10])
compare_containers(ps[-10:6], ai[-10:6])
compare_containers(ps[-10:10], ai[-10:10])

compare_containers(ps[0:6:1], ai[0:6:1])
compare_containers(ps[::], ai[::])
compare_containers(ps[::1], ai[::1])

compare_containers([x for x in ps], [x for x in ai])

# Reverse
compare_containers(ps[::-1], ai[::-1])
compare_containers(ps[5::-1], ai[5::-1])
compare_containers(ps[10::-1], ai[10::-1])

# Steps other than +1 and -1 not supported
steps_exception(ai, 0, 6, 3)
steps_exception(ai, None, None, 0)
steps_exception(ai, None, None, 2)
steps_exception(ai, None, None, -2)
steps_exception(ai, 1, 3, 1)
steps_exception(ai, 3, 1, -1)

# Modify content
for i in range(len(ps)):
    ps[i] = (ps[i] + 1) * 10
    ai[i] = (ai[i] + 1) * 10
compare_containers(ps, ai)

# Delete
del_exception(ai, 0, 6, 3)
del_exception(ai, None, None, 0)
del_exception(ai, None, None, 2)
del_exception(ai, None, None, -2)
del_exception(ai, 1, 3, 1)
del_exception(ai, 3, 1, -1)

del_exception(ai, 0, None, None)
del_exception(ai, 5, None, None)

# Empty
ai = ArrayInt6()
compare_containers([0, 0, 0, 0, 0, 0], ai)

# Set slice
newvals = [10, 20, 30, 40, 50, 60]
ai[::] = newvals
compare_containers(ai, newvals)

newvals = [100, 200, 300, 400, 500, 600]
ai[0:6:1] = newvals
compare_containers(ai, newvals)

newvals = [1000, 2000, 3000, 4000, 5000, 6000]
ai[::-1] = newvals
compare_containers(ai, newvals[::-1])

newvals = [10000, 20000, 30000, 40000, 50000, 60000]
ai[-10:100:1] = newvals
compare_containers(ai, newvals[-10:100:1])

setslice_exception(ai, [1, 2, 3, 4, 5, 6, 7])
setslice_exception(ai, [1, 2, 3, 4, 5])
setslice_exception(ai, [1, 2, 3, 4])
setslice_exception(ai, [1, 2, 3])
setslice_exception(ai, [1, 2])
setslice_exception(ai, [1])
setslice_exception(ai, [])

# Check return
compare_containers(arrayOutVal(), [-2, -1, 0, 0, 1, 2])
compare_containers(arrayOutConstRef(), [-2, -1, 0, 0, 1, 2])
compare_containers(arrayOutRef(), [-2, -1, 0, 0, 1, 2])
compare_containers(arrayOutPtr(), [-2, -1, 0, 0, 1, 2])

# Check passing arguments
ai = arrayInVal([9, 8, 7, 6, 5, 4])
compare_containers(ai, [90, 80, 70, 60, 50, 40])

ai = arrayInConstRef([9, 8, 7, 6, 5, 4])
compare_containers(ai, [90, 80, 70, 60, 50, 40])

ai = ArrayInt6([9, 8, 7, 6, 5, 4])
arrayInRef(ai)
compare_containers(ai, [90, 80, 70, 60, 50, 40])

ai = ArrayInt6([9, 8, 7, 6, 5, 4])
arrayInPtr(ai)
compare_containers(ai, [90, 80, 70, 60, 50, 40])

# fill
ai.fill(111)
compare_containers(ai, [111, 111, 111, 111, 111, 111])
