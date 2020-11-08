#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import csv
import time
import schedule
import distutils.util

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from people_finder import Recognition
from threading import Thread, Lock
from dotenv import load_dotenv
from datetime import datetime


load_dotenv()
### ENVIRONMENTS ###
CAMERA_PATH       = os.getenv("CAMERA_PATH")
TRAIN_PATH        = os.getenv("TRAIN_PATH")
MODEL_PATH        = os.getenv("MODEL_PATH")
MODEL_FILE        = os.getenv("MODEL_FILE")
DB_PATH           = os.getenv("DB_PATH")
DB_LOGS_FILE      = os.getenv("DB_LOGS_FILE")
CRON_TIME         = int(os.getenv("CRON_TIME"))
CLEAR_CAMERA_DATA = distutils.util.strtobool(os.getenv("CLEAR_CAMERA_DATA"))



class ImageQueue:

    def __init__(self, init_list = []):
        # Init list
        self.q = init_list

    def empty(self):
        # Return true if queue is empty
        if len(self.q) == 0:
            return True
        return False

    def size(self):
        # Return the size of the queue
        return len(self.q)

    def get(self, n = 1):
        # Get the first N elements
        return self.q[0:n]

    def pop(self, n = 1):
        # Pop the first N elements
        elements = []
        for i in range(0, n):
            elements.append(self.q.pop(0))
        return elements

    def put(self, element):
        # Put a new element
        self.q.append(element)



class NewImageEventHandler(FileSystemEventHandler):

    def __init__(self, observer, queue, lock):
        self.observer = observer
        self.queue = queue
        self.lock = lock
        self.recognizer = Recognition()
        # Train recognizer
        if not os.path.isfile(os.path.join(MODEL_PATH, MODEL_FILE)):
            self.recognizer.train_dataset(os.path.join(TRAIN_PATH), os.path.join(MODEL_PATH, MODEL_FILE))
        # Clean camera folder
        if CLEAR_CAMERA_DATA:
            self.__clear_folder(CAMERA_PATH)


    def __clear_folder(self, folder):
        # Remove all files in folder
        for content in os.listdir(folder):
            if os.path.isfile(os.path.join(folder, content)):
                os.remove(os.path.join(folder, content))
            elif os.path.isdir(os.path.join(folder, content)):
                self.__clear_folder(os.path.join(folder, content))


    def on_created(self, event):
        # Check if it's a file or a dir
        if not event.is_directory: # Ignore if it's a dir
            # Check if it's an image
            if event.src_path.lower().endswith(('.png', '.jpg', '.jpeg')): # Ignore if it isn't an image
                # Acquire the queue
                self.lock.acquire()
                # Insert created image in queue
                queue.put(event.src_path)
                # Release the queue
                self.lock.release()



class ImageProcess:

    def __init__(self, src_path, model_path, timestamp = None):
        # Set the variables
        self.src_path = src_path
        self.model_path = model_path
        self.recognizer = Recognition()
        self.timestamp = timestamp if timestamp else datetime.utcnow().timestamp()
        self.logs = os.path.join(DB_PATH, DB_LOGS_FILE)

    def process(self, lock):
        # Find people in an image
        res = self.recognizer.find_people_in_image(self.src_path, self.model_path)
        # Check if people have been found
        if len(res):
            # Get photo time or use analysis timestamp
            photo_time = os.path.getmtime(self.src_path)
            self.timestamp = photo_time if photo_time else self.timestamp
            # One (or more) person found
            for person in res:
                if person != 'unknown':
                    lock.acquire()
                    print('[result] ', person, ' found!')
                    lock.release()
                    # Insert logs
                    with open(self.logs, 'a+', newline='') as write_obj:
                        # Create a writer object from csv module
                        csv_writer = csv.writer(write_obj)
                        # Add contents of list as last row in the csv file
                        csv_writer.writerow([person, self.timestamp])
        # Remove image
        if CLEAR_CAMERA_DATA:
            os.remove(self.src_path)



class Analyzer(Thread):

    def __init__(self, queue, locks):
        # Super thread
        Thread.__init__(self)
        # Get lock
        self.stdout_lock, self.queue_lock = locks
        # Get queue
        self.queue = queue

    def run(self):
        # Lock the queue
        self.queue_lock.acquire()
        # Get the number of images to analyze
        n = self.queue.size()
        # Get list of images to analyze
        images = self.queue.pop(n)
        # Release the queue
        self.queue_lock.release()
        # Start processing all images
        if len(images) > 0:
            self.stdout_lock.acquire()
            print('[open] processing ', len(images), ' images...')
            self.stdout_lock.release()
        # Get current timestamp
        now = datetime.utcnow().timestamp()
        # Process each image
        for image in images:
            # Create tool to process image
            f = ImageProcess(image, os.path.join(MODEL_PATH, MODEL_FILE), now)
            # Process this image
            f.process(self.stdout_lock)
        # End 
        if len(images) > 0:
            self.stdout_lock.acquire()
            print('[close] ', len(images), ' images processed.')
            self.stdout_lock.release()
        
        
    
### GLOBAL ### 

# Initializing a queue 
queue = ImageQueue()
# Init locks
stdout_lock = Lock()
queue_lock = Lock()

# Cron job to repeat
def job():
    # Use global queue
    global queue, queue_lock, stdout_lock
    # Create analyzer
    a = Analyzer(queue, (stdout_lock, queue_lock))
    # Do everything
    a.start()

# Main 
def main():
    # Use global queue
    global queue, queue_lock
    # Start all
    print('[info] starting...')
    # Create observer
    observer = Observer()
    # Init recognition model
    event_handler = NewImageEventHandler(observer, queue, queue_lock)
    print('[info] recognition model generated.')
    # Schedule job for image recognition process
    schedule.every(CRON_TIME).minutes.do(job)
    print('[info] process job scheduled.')
    # Schedule event on new image
    observer.schedule(event_handler, CAMERA_PATH, recursive=True)
    observer.start()
    print('[info] observer listening...')
    # Run job schedule pending...
    while True:
        schedule.run_pending()
        time.sleep(1)
    # End
    observer.join()


### START ###
if __name__ == "__main__":
    main()