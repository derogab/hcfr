#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import time

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from people_finder import Recognition
from threading import Thread

# Environments
CAMERA_PATH = os.getenv("CAMERA_PATH")
TRAIN_PATH  = os.getenv("TRAIN_PATH")
MODEL_PATH  = os.getenv("MODEL_PATH")
MODEL_FILE  = os.getenv("MODEL_FILE")



class NewImageEventHandler(FileSystemEventHandler):
    
    def __init__(self, observer):
        self.observer = observer
        # Init recognizer
        self.recognizer = Recognition()
        self.recognizer.train_dataset(TRAIN_PATH, os.path.join(MODEL_PATH, MODEL_FILE))

    def on_created(self, event):
        # Check if it's a file or a dir
        if not event.is_directory: # Ignore if it's a dir
            # Check if it's an image
            if event.src_path.lower().endswith(('.png', '.jpg', '.jpeg')): # Ignore if it isn't an image
                # Create thread to process file
                f = ImageProcess(event.src_path, os.path.join(MODEL_PATH, MODEL_FILE))
                # Start the created thread
                f.start()



class ImageProcess(Thread):
    
    def __init__(self, src_path, model_path):
        Thread.__init__(self)
        # Set the variables
        self.src_path = src_path
        self.model_path = model_path
        self.recognizer = Recognition()

    def run(self):
        # Wait upload time
        time.sleep(5)
        # Find people in an image
        res = self.recognizer.find_people_in_image(self.src_path, self.model_path)
        # Check if people have been found
        if len(res):
            # One (or more) person found
            for person in res:
                if person != 'unknown':
                    print(person + ' found!')



if __name__ == "__main__":
    print('Starting...')
    observer = Observer()
    event_handler = NewImageEventHandler(observer)
    observer.schedule(event_handler, CAMERA_PATH, recursive=True)
    observer.start()
    print('Running...')
    observer.join()