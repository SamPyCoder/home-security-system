import cv2
import mysql.connector
from recognize_face import rec_face_image

# ======== DATABASE CONNECTION ========
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="home_security"
)

cursor = db.cursor()

# ======== CAMERA SETUP ========
url = "http://192.168.29.156:8080/video"
cap = cv2.VideoCapture(url)

face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
)

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
    s = False

    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)
        s = True

    if s:
        cv2.imwrite("sample.jpg", frame)
        res = rec_face_image("sample.jpg")
        print(res, "==============")

        if res == "unknown":
            sql = "INSERT INTO `myapp_notification_table`(`date`,`image`,`status`,`CAMERA_id`) VALUES (CURDATE(), %s, %s, %s)"
            values = ("sample.jpg", "unknown", 1)  # camera id = 1
            cursor.execute(sql, values)
            db.commit()

            print("⚠️ Unknown face inserted into notification table")

    cv2.imshow('Camera Feed with Detection', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
cursor.close()
db.close()
