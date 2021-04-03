#!/usr/bin/python3

import os
import time
from datetime import datetime

path = "d:\\"
number_of_days = 14

curr_time = int(time.time())
timestamp_day = 60 * 60 * 24 #seconds in day
number_of_days = number_of_days * timestamp_day

old_time = curr_time - number_of_days
print("delete folders older than: " + str(old_time))

for el in os.listdir(path):
    try: 
        folder = os.path.join(path, el)
        folder_timestamp = int(os.path.getmtime(os.path.join(folder)))
    except Exception as e:
        print("\n\n* Directory with error: " + folder)
        print("Original Exception message: " + str(e)) 
        print("* Directory will not be analyzed and/or removed. " \
                + "Remove it manually if necessary.\n")
        continue

    folder_date = str(datetime.fromtimestamp(folder_timestamp))

    if folder_timestamp < old_time:
        print("Removed name: " + folder + " timestamp: " \
                + str(folder_timestamp) + " folder_date: " \
                + folder_date )
        try:
            # os.remove(folder)
            pass #remove pass afer uncommenting os.remove
        except Exception as e:
            print("\n\n* Folder " + folder + "could not be removed")
            print("Original Exception message: " + str(e) + "\n")
