from google.appengine.ext import db

class AMFImgData(db.Model):
	img = db.BlobProperty()
	
class ByteArrayModel(db.Model):
	bytes = db.BlobProperty()