import cv2
from  recognize_face import rec_face_image
import requests
import os
from datetime import datetime
import time
# Replace with your IP camera's RTSP/HTTP stream URL
url = "http://192.168.29.157:8080/video"
# url = 0

cap = cv2.VideoCapture(url)
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

if not cap.isOpened():
    print("❌ Cannot connect to IP camera")
    exit()

while True:
    ret, frame = cap.read()
    if not ret:
        print("❌ Failed to grab frame")
        break
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)
    s=False
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)
        s=True
    if s:
        cv2.imwrite("sample.jpg", frame)
        res=rec_face_image("sample.jpg")
        print(res,"==============")
        if len(res)==0:


            url="http://127.0.0.1:8000/myapp//add_notification/"
            print(res)
            fn=datetime.now().strftime("%Y%m%d%H%M%S")+".png"
            cv2.imwrite(fn, frame)
            files = {
                "image": open(fn, "rb")
            }
            response = requests.post(url, data={"cameraid":"3"}, files=files)

        else:
            for ii in res:
                url = "http://127.0.0.1:8000/myapp/add_notification1"
                print(res)
                fn = datetime.now().strftime("%Y%m%d%H%M%S") + ".png"
                cv2.imwrite(fn, frame)
                files = {
                    "image": open(fn, "rb")
                }
                response = requests.post(url, data={"cameraid": "3","fpid":ii}, files=files)



    cv2.imshow('Camera Feed with Detection', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
cap.release()
cv2.destroyAllWindows()
