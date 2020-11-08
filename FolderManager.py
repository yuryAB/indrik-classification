import os, shutil
import random
class FolderManager:

    def __init__(self, folder_path):
        self.folder_path = folder_path
        self.folder_name = self.getFolderName()
        self.test_folder_path = self.getTestFolderPath()
        self.training_folder_path = self.getTrainingFolderPath()

    def getFolderName(self):
        folder_name = self.folder_path.split('/')[-1]
        return folder_name

    def createTestFolder(self):
        test_folder_path = self.folder_path.split('/')[0]+'/test_set'
        try:
            os.mkdir(test_folder_path)
            print("Folder: test_set created.")
        except OSError:
            pass

    def getTestFolderPath(self):
        test_folder_path = self.folder_path.split('/')[0]+'/test_set'
        return test_folder_path

    def createTrainingFolder(self):
        training_folder_path = self.folder_path.split('/')[0]+'/training_set'
        try:
            os.mkdir(training_folder_path)
            print("Folder: training_set created.")
        except OSError:
            pass

    def getTrainingFolderPath(self):
        test_folder_path = self.folder_path.split('/')[0]+'/training_set'
        return test_folder_path
    
    def trainTestSplitFolder(self, test_percent):
        self.createTestFolder()
        self.createTrainingFolder()
        folder_in_test_folder_path = self.getTestFolderPath()+'/'+self.folder_name
        folder_in_training_folder_path = self.getTrainingFolderPath()+'/'+self.folder_name

        try:
            os.mkdir(folder_in_test_folder_path)
        except OSError:
            pass
        try:
            os.mkdir(folder_in_training_folder_path)
        except OSError:
            pass

        files_list = os.listdir(self.folder_path)
        folder_length = len(files_list)
        percent = test_percent/100
        test_length = int(folder_length * percent)
        random.shuffle(files_list)
        train_data = files_list[test_length:]
        test_data = files_list[:test_length] 
        print("Training data length: ",len(train_data))
        print("Test data length: ",len(test_data))
        for file in files_list:
            main_path = self.folder_path+'/'+file
            if file in test_data:
                shutil.move(main_path, folder_in_test_folder_path)
            if file in train_data:
                shutil.move(main_path, folder_in_training_folder_path)

        


# class1 = FolderManager("dataset/Indrik")

# class1.trainTestSplitFolder(20)
