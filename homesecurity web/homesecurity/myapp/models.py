from django.db import models
from django.contrib.auth.models import User
# Create your models here.

class Police_station_table(models.Model):
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.BigIntegerField()
    place=models.CharField(max_length=100)
    post=models.CharField(max_length=100)
    pin=models.BigIntegerField()
    latitude=models.FloatField()
    longitude=models.FloatField()

class users_table(models.Model):
    LOGIN = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.BigIntegerField()
    place = models.CharField(max_length=100)
    post = models.CharField(max_length=100)
    pin = models.BigIntegerField()
    image=models.FileField()

class technical_issue_table(models.Model):
    USER=models.ForeignKey(users_table,on_delete=models.CASCADE)
    issue=models.CharField(max_length=1000)
    reply=models.CharField(max_length=1000)
    date=models.DateField()

class familiar_person_table(models.Model):
    USER = models.ForeignKey(users_table, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    relation = models.CharField(max_length=100)
    image = models.FileField()
    date = models.DateField()
    gender=models.CharField(max_length=10)

class complaint_table(models.Model):
    USER = models.ForeignKey(users_table, on_delete=models.CASCADE)
    POLICE = models.ForeignKey(Police_station_table, on_delete=models.CASCADE)
    complaint=models.CharField(max_length=100)
    reply = models.CharField(max_length=1000)
    date = models.DateField()


class visitor_log_table(models.Model):
    FAMILIAR_PERSON = models.ForeignKey(familiar_person_table, on_delete=models.CASCADE)
    type=models.CharField(max_length=100)
    image = models.FileField()
    date = models.DateField()
    time =models.CharField(max_length=100)


class camera_table(models.Model):
     USER=models.ForeignKey(users_table,on_delete=models.CASCADE)
     camera_number=models.CharField(max_length=100)
     date=models.DateField()
     status=models.CharField(max_length=100)


class notification_table(models.Model):
    date = models.DateField()
    image = models.FileField()
    CAMERA = models.ForeignKey(camera_table, on_delete=models.CASCADE)
    status = models.CharField(max_length=100)


class reports_table(models.Model):
     VISITORS_LOG = models.ForeignKey(notification_table, on_delete=models.CASCADE)
     STATION = models.ForeignKey(Police_station_table, on_delete=models.CASCADE)
     description= models.CharField(max_length=100)
     date = models.DateField()
     action = models.CharField(max_length=100)
     response=models.CharField(max_length=100)


