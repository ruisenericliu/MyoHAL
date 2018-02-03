from random import randint
import pickle

def main():

    filename = 'genId.txt'
    my_list = []

    with open(filename, 'rb') as f:
        my_list = pickle.load(f)

    checker = None

    max = 100;

    while (not checker):
        temp_num = randint(0,max)
        if (len(my_list) > max) :
            print ('Out of ID numbers!')
            checker = True;
        elif (temp_num in my_list):
            checker = False    
        else:
            print ("%03d" % (temp_num,)) #output number 
            my_list.append(temp_num);
            with open(filename, 'wb') as f:
                pickle.dump(my_list, f)
            checker = True;
            

if __name__ == "__main__":
    main()

