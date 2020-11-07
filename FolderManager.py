import os
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
        except OSError:
            pass

    def getTestFolderPath(self):
        test_folder_path = self.folder_path.split('/')[0]+'/test_set'
        return test_folder_path

    def createTrainingFolder(self):
        training_folder_path = self.folder_path.split('/')[0]+'/training_set'
        try:
            os.mkdir(training_folder_path)
        except OSError:
            pass

    def getTrainingFolderPath(self):
        test_folder_path = self.folder_path.split('/')[0]+'/training_set'
        return test_folder_path
    
    def trainTestSplitFolder(self, teste_percent):
        pass