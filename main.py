#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import time
import shutil
import distutils.util

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from people_finder import Recognition
from threading import Thread
from dotenv import load_dotenv


load_dotenv()
# Environments
CAMERA_PATH = os.getenv("CAMERA_PATH")
TRAIN_PATH  = os.getenv("TRAIN_PATH")
MODEL_PATH  = os.getenv("MODEL_PATH")
MODEL_FILE  = os.getenv("MODEL_FILE")
CLEAR_CAMERA_DATA = distutils.util.strtobool(os.getenv("CLEAR_CAMERA_DATA"))



class NewImageEventHandler(FileSystemEventHandler):
    
    def __init__(self, observer):
        self.observer = observer
        self.recognizer = Recognition()
        # Train recognizer
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
        # Remove image
        if CLEAR_CAMERA_DATA:
            os.remove(self.src_path)
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