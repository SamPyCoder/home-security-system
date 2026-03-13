import smtplib
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import make_password
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User, Group
from myapp.models import *


@csrf_exempt
# Create your views here.
def view_login(request):

    if request.method == 'POST':
        username=request.POST['email']
        password=request.POST['password']
        print(request.POST,'==========')
        user=authenticate(request,username=username,password=password)
        if user is not None:
            if user.groups.filter(name="Admin").exists():
                print("admin")
                login(request, user)
                return redirect('/myapp/Adminhome')
            elif user.groups.filter(name="Policestation").exists():
                print("Policestation")
                login(request, user)
                return redirect('/myapp/policestation_home')
            else:
                messages.warning(request, " Invalid username or password")
                return redirect('/myapp/')
        else:
            messages.warning(request," Invalid username or password")
            return redirect('/myapp/')
    return render(request,'login.html')


def view_admin_home(request):
    return render(request,'Admin/1admin_home.html')


@csrf_exempt

def view_addpolice(request):
    return render(request,'Admin/2addpolice_station.html')


import smtplib
import random
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from django.shortcuts import render, redirect
from django.contrib import messages
from django.contrib.auth.models import User, Group
from django.contrib.auth.hashers import make_password
from .models import Police_station_table  # Ensure this import matches your app structure


def admin_add_policestation_post(request):
    if request.method == 'POST':
        # 1. Collect Data from Post
        name = request.POST.get('name')
        email = request.POST.get('email')
        phone = request.POST.get('phone')
        place = request.POST.get('place')
        post = request.POST.get('post')
        pin = request.POST.get('pin')
        latitude = request.POST.get('latitude')
        longitude = request.POST.get('longitude')
        username = request.POST.get('username')
        password = request.POST.get('password')

        # 2. Validation: Check if Username or Email already exists
        if User.objects.filter(username=username).exists():
            messages.warning(request, 'Username already taken')
            return redirect('/myapp/addpolice')

        if Police_station_table.objects.filter(email=email).exists():
            messages.error(request, 'This Police Station email is already registered')
            return redirect('/myapp/addpolice')

        try:
            # 3. Create Authentication User
            # We use first_name to store the Station Name for convenience
            new_user = User.objects.create(
                username=username,
                password=make_password(password),
                email=email,
                first_name=name
            )

            # Assign to Group
            group, created = Group.objects.get_or_create(name='Policestation')
            new_user.groups.add(group)

            # 4. Save to Police Station Profile Table
            police_station = Police_station_table(
                LOGIN=new_user,
                name=name,
                phone=phone,
                place=place,
                post=post,
                pin=pin,
                email=email,
                latitude=latitude,
                longitude=longitude
            )
            police_station.save()

            # 5. Email Notification Logic
            sender_email = "aleenap005@gmail.com"
            sender_password = "ftsh zysa rdjz uqot"  # Ensure this is a 16-character App Password

            subject = "SignSpeak - Police Station Account Created"
            body = f"""
            Hello {name},

            A new Police Station account has been created for you.

            Username: {username}
            Password: {password}

            Please login to the portal to manage your station.
            """

            msg = MIMEMultipart()
            msg['From'] = sender_email
            msg['To'] = email
            msg['Subject'] = subject
            msg.attach(MIMEText(body, 'plain'))

            # Setup SMTP Connection
            server = smtplib.SMTP(host="smtp.gmail.com", port=587)
            server.starttls()
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, email, msg.as_string())
            server.quit()

            messages.success(request, "Police Station added and credentials emailed successfully!")
            return redirect('/myapp/view_policestation')

        except Exception as e:
            # Log the error and notify the admin
            print(f"Error occurred: {e}")
            messages.error(request, f"System Error: {str(e)}")
            return redirect('/myapp/addpolice')

    return redirect('/myapp/addpolice')

# @csrf_exempt
# def admin_add_policestation_post(request):
#     name=request.POST['name']
#     email=request.POST['email']
#     phone=request.POST['phone']
#     place=request.POST['place']
#     post=request.POST['post']
#     pin=request.POST['pin']
#     latitude=request.POST['latitude']
#     longitude=request.POST['longitude']
#     username=request.POST['username']
#     password=request.POST['password']
#
#     if User.objects.filter(username=username).exists():
#         messages.warning(request, 'Username already taken')
#         return redirect('/myapp/addpolice')
#
#         # 2. Check if Police Station Email exists
#     if Police_station_table.objects.filter(email=email).exists():
#         messages.error(request, 'Email Already Exists')
#         return redirect('/myapp/addpolice')
#
#     try:
#         # 3. Create Auth User
#         ab = User.objects.create(
#             username=username,
#             password=make_password(password),
#             email=email,
#             first_name=name
#         )
#         group = Group.objects.get(name='Policestation')
#         ab.groups.add(group)
#
#         # 4. Create Police Station Profile
#         u = Police_station_table()
#         u.LOGIN = ab
#         u.name = name
#         u.phone = phone
#         u.place = place
#         u.post = post
#         u.pin = pin
#         u.email = email
#         u.latitude = latitude
#         u.longitude = longitude
#         u.save()
#
#         # 5. Email Logic (Moved inside the main flow)
#         sender_email = "aleenap005@gmail.com"
#         sender_password = "ftsh zysa rdjz uqot"  # Ensure this is a Google App Password
#
#         subject = "Login Credentials for SignSpeak"
#         body = f"Hello {name},\n\nYour account has been created.\nUsername: {username}\nPassword: {password}\n\nPlease login to the system."
#
#         msg = MIMEMultipart()
#         msg['From'] = sender_email
#         msg['To'] = email
#         msg['Subject'] = subject
#         msg.attach(MIMEText(body, 'plain'))
#
#         # SMTP Server Setup
#         server = smtplib.SMTP("smtp.gmail.com", 587)
#         server.starttls()
#         server.login(sender_email, sender_password)
#         server.sendmail(sender_email, email, msg.as_string())
#         server.quit()
#
#         messages.success(request, "Police station added and email sent!")
#     return redirect('/myapp/view_policestation')

from django.shortcuts import render
from .models import Police_station_table
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def editpolice(request, id):
    a = Police_station_table.objects.get(id=id)

    request.session['id'] = a.id

    return render(request, 'Admin/edit police station.html', {'data': a})


@csrf_exempt
def edit_policestation_post(request):
    name=request.POST['name']
    email=request.POST['email']
    phone=request.POST['phone']
    place=request.POST['place']
    post=request.POST['post']
    pin=request.POST['pin']
    latitude=request.POST['latitude']
    longitude=request.POST['longitude']



    u=Police_station_table.objects.get(id=request.session['id'])
    u.name = name
    u.phone = phone
    u.place = place
    u.post = post
    u.pin = pin
    u.email = email
    u.latitude = latitude
    u.longitude = longitude
    u.save()
    return redirect('/myapp/view_policestation')

def delete_police_station(request,id):
    a=Police_station_table.objects.get(id=id)
    a.delete()
    return redirect('/myapp/view_policestation')

def view_policestation(request):
    var=Police_station_table.objects.all()
    return render(request,'Admin/3View_policestation.html',{'data':var})

def view_technical_issue(request):
    var=technical_issue_table.objects.filter(reply="pending")
    return render(request,'Admin/4view_technical_issue.html',{'data':var})

@csrf_exempt
def view_send_issue_reply(request,id):
    request.session['id']=id
    aa=technical_issue_table.objects.get(id=id)
    return render(request,'Admin/5send_issue_reply.html')

@csrf_exempt
def view_send_issue_reply_post(request):
    reply=request.POST['reply']
    id=request.session['id']
    aa=technical_issue_table.objects.get(id=id)
    aa.reply=reply
    aa.save()
    return redirect('/myapp/technical_issue')

def view_user_login(request):
    var=users_table.objects.all()
    print(var,'usersss')
    return render(request,'Admin/6user_login.html',{'data':var})

def view_users(request):
    var=users_table.objects.all()
    return render(request,'Admin/7view_users.html',{'data':var})


#===================================================
#==========================POLICE===================
#===================================================

def view_policestation_home(request):
    return render(request,'police/8policestation_home.html')

def view_reports(request):
    var=reports_table.objects.filter(STATION__LOGIN_id=request.user.id)
    return render(request,'police/9View_reports.html',{'data':var})

def view_response(request,id):
    request.session['id']=id
    var=reports_table.objects.get(id=id)
    if request.method == 'POST':
        response=request.POST['response']
        v=reports_table.objects.get(id=request.session['id'])
        v.response=response
        v.save()
        return redirect('/myapp/reports#about')
    return render(request,'police/10Send_response.html',{'data':var})

def view_reply(request,id):
    request.session['id'] = id
    return render(request,'police/11send_reply.html')

def view_complaint(request):
    id=request.user.id
    var = complaint_table.objects.filter(POLICE__LOGIN=id)
    return render(request,'police/12View_complaint.html',{'data':var})

@csrf_exempt
def send_reply_post(request):
    reply=request.POST['textfield']
    cid=request.session['id']
    v=complaint_table.objects.get(id=cid)
    v.reply=reply
    v.save()
    return redirect('/myapp/view_complaint#about')

def view_take_action(request,id):
    request.session['rid']=id
    if request.method == 'POST':
        response=request.POST['response']
        v=reports_table.objects.get(id=id)
        v.action=response
        v.save()
        return redirect('/myapp/reports#about')
    return render(request,'police/13take_action.html')


#user android part

def user_register(request):
    name=request.POST['name']
    email=request.POST['email']
    phone=request.POST['phone']
    pin=request.POST['pin']
    place=request.POST['place']
    post=request.POST['post']
    username=request.POST['username']
    password=request.POST['password']
    image=request.FILES['image']

    fs=FileSystemStorage()
    path=fs.save(image.name,image)




    ab=User.objects.create(username=username,password=make_password(password),email=email,first_name=name)
    ab.save()
    ab.groups.add(Group.objects.get(name='User'))


    var=users_table()
    var.LOGIN=ab
    var.name=name
    var.email=email
    var.image=path
    var.phone=phone
    var.pin=pin
    var.place=place
    var.post=post
    var.save()
    return JsonResponse({'status': 'ok'})

def user_login_page(request):
    username = request.POST['username']
    password = request.POST['password']
    print(request.POST, '==========')
    user = authenticate(request, username=username, password=password)
    if user is not None:
        if user.groups.filter(name="User").exists():
            print(user.id,'=======lid====')
            return JsonResponse({'status':'ok','type':'User','lid':str(user.id)})
        elif user.groups.filter(name="conductor").exists():
            return JsonResponse({'status':'ok','type':'conductor','lid':str(user.id)})
        else:
            return JsonResponse({'status':'not ok'})
    else:
        return JsonResponse({'status': 'not ok'})

def user_view_profile(request):
    lid = request.POST['lid']
    print(lid, 'lid====')
    var = users_table.objects.get(LOGIN_id=lid)
    print(var.LOGIN.id, '=====loginss=====')
    return JsonResponse({
        'status': 'ok',
        'name': str(var.name),
        'email': str(var.email),
        'phone': str(var.phone),
        'place': str(var.place),
        'post': str(var.post),
        'pin': str(var.pin),
        'image': str(var.image.url),
    })

def user_update_profile(request):
    lid=request.POST['lid']
    name=request.POST['name']
    email=request.POST['email']
    phone=request.POST['phone']
    place=request.POST['place']
    pin=request.POST['pin']
    post=request.POST['post']
    var=users_table.objects.get(LOGIN_id=lid)
    if 'image' in request.FILES:
        image = request.FILES['image']
        fs = FileSystemStorage()
        path = fs.save(image.name, image)
        var.image = path
    var.name=name
    var.email=email
    var.phone=phone
    var.place=place
    var.pin=pin
    var.post=post
    var.save()
    return JsonResponse({'status': 'ok'})

def user_view_visitor_log(request):
    l=[]
    lid=request.POST['lid']
    var=visitor_log_table.objects.filter(FAMILIAR_PERSON__USER__LOGIN_id=lid)
    for i in var:
        l.append({
            'id':i.id,
            'type':i.type,
            'FAMILIAR_PERSON':i.FAMILIAR_PERSON.name,
            'date':str(i.date),
            'time':str(i.time),
            'image':str(i.image.url),
        })
    return JsonResponse({'status': 'ok','data':l})




def user_add_family(request):
    lid=request.POST['lid']
    name=request.POST['name']
    relation=request.POST['relation']
    gender=request.POST['gender']
    image=request.FILES['image']

    fs=FileSystemStorage()
    path=fs.save(image.name,image)

    var=familiar_person_table()
    var.USER=users_table.objects.get(LOGIN_id=lid)
    var.date=datetime.now().today().date()
    var.image=path
    var.relation=relation
    var.gender=gender
    var.name=name
    var.save()
    return JsonResponse({'status': 'ok'})

def insert_cam_notification(request):
    cid=request.POST['cid']
    type=request.POST['type']
    image=request.POST['image']
    ob=visitor_log_table()
    ob.FAMILIAR_PERSON = familiar_person_table.objects.get(id=cid)
    ob.type=type
    ob.image =image
    ob.date = datetime.today()
    ob.time =datetime.now()
    ob.save()


    return JsonResponse({'status': 'ok'})


def user_view_familiar_person(request):
    l=[]
    lid=request.POST['lid']
    var=familiar_person_table.objects.filter(USER__LOGIN_id=lid)
    for i in var:
        l.append({
            'id':i.id,
            'name':i.name,
            'relation':str(i.relation),
            'image':str(i.image.url),
            'date':str(i.date),
            'gender':str(i.gender),

        })
    return JsonResponse({'status': 'ok','data':l})


def user_view_policestation(request):
    l=[]
    var=Police_station_table.objects.all()
    for i in var:
        l.append({
            'id':i.id,
            'name':i.name,


        })

    return JsonResponse({'status': 'ok','data':l})


def user_add_complaint(request):
    lid=request.POST['lid']
    policeid=request.POST['policeid']
    complaint=request.POST['complaint']
    var=complaint_table()
    var.date=datetime.now().today().date()
    var.USER=users_table.objects.get(LOGIN_id=lid)
    var.POLICE=Police_station_table.objects.get(id=policeid)
    var.complaint=complaint
    var.reply='pending'
    var.save()
    return JsonResponse({'status': 'ok'})


def user_view_reports(request):
    l=[]
    var=reports_table.objects.all()
    for i in var:
        l.append({
            'id': i.id,
            'STATION':str(i.STATION.name),
            'description':str(i.description),
            'date':str(i.date),
            'action':str(i.action),
            'response':str(i.response),

        })
    return JsonResponse({'status': 'ok'})


def user_view_techinical_issue(request):
    lid=request.POST['lid']
    l=[]
    var=technical_issue_table.objects.filter(USER__LOGIN_id=lid)
    for i in var:
        l.append({
            'id': i.id,
            'issue':str(i.issue),
            'reply':str(i.reply),
            'date':str(i.date),

        })
    print(l)
    return JsonResponse({'status': 'ok','data':l})



def user_view_camera(request):
    lid=request.POST['lid']
    l=[]
    var= camera_table.objects.filter(USER__LOGIN_id=lid)
    for i in var:
        l.append({
            'id': i.id,
            'camera_number': str(i.camera_number),
            'date': str(i.date),
            'status': str(i.status),

        })
    return JsonResponse({'status': 'ok','data':l})


def user_view_camera_person(request,id):
    cid=id
    l=[]
    var= camera_table.objects.get(id=cid)
    uid=var.USER.id
    print(uid)

    var = familiar_person_table.objects.filter(USER__id=uid)
    for i in var:
        l.append({
            'id': i.id,
            'image': str(i.image),

        })
    print(l)
    return JsonResponse({'status': 'ok', 'data': l})




def user_view_complaint(request):
    l=[]
    lid=request.POST['lid']
    var=complaint_table.objects.filter(USER__LOGIN_id=lid)
    for i in var:
        l.append({
            'id': i.id,
            'POLICE':str(i.POLICE.name),
            'complaint':str(i.complaint),
            'reply':str(i.reply),
            'date':str(i.date),
        })
    return JsonResponse({'status': 'ok','data':l})


def user_add_technicalissue(request):
    lid=request.POST['lid']
    issue=request.POST['issue']
    var=technical_issue_table()
    var.date=datetime.now().today().date()
    var.USER=users_table.objects.get(LOGIN_id=lid)
    var.issue=issue
    var.reply='pending'
    var.save()
    return JsonResponse({'status': 'ok'})

def user_add_camera(request):
    lid = request.POST['lid']
    cam_no = request.POST['camera']
    var = camera_table()
    var.date = datetime.now().today().date()
    var.USER = users_table.objects.get(LOGIN_id=lid)
    var.camera_number = cam_no
    var.status = 'Active'
    var.save()
    return JsonResponse({'status': 'ok'})

def activate_camera(request):
    cam_id=request.POST['camid']
    obj=camera_table.objects.get(id=cam_id)
    obj.status="Active"
    obj.save()
    return JsonResponse({"status":"ok"})

def deactivate_camera(request):
    cam_id=request.POST['camid']
    obj=camera_table.objects.get(id=cam_id)
    obj.status="Deactivate"
    obj.save()
    return JsonResponse({"status":"ok"})



def add_notification(request):
    date=datetime.now().today()
    status="pending"
    camera=request.POST['cameraid']
    image=request.FILES['image']

    obj=notification_table()
    obj.date=date
    obj.status=status
    obj.CAMERA_id=camera
    obj.image=image
    obj.save()
    return JsonResponse({'status':'ok'})

def add_notification1(request):
    date=datetime.now().today()
    status="pending"
    fpid=request.POST['fpid']

    image=request.FILES['image']

    obj=visitor_log_table()
    obj.FAMILIAR_PERSON=familiar_person_table.objects.get(id=fpid)
    obj.date=date
    obj.type=status
    obj.time=datetime.now().strftime("%H:%M")

    obj.image=image
    obj.save()


    return JsonResponse({'status':'ok'})


def view_notification_alert(request):
    lid=request.POST['lid']
    ob=notification_table.objects.filter(CAMERA__USER__LOGIN__id=lid,status="pending")
    if len(ob)>0:
        ob=ob[0]
        ob.status='viwed'
        ob.save()
        return JsonResponse({"status":"ok"})
    return JsonResponse({"status":"na"})



def view_notification_user(request):
    lid=request.POST['lid']
    ob=notification_table.objects.filter(CAMERA__USER__LOGIN__id=lid).order_by("-id")
    l=[]
    for i in ob:
        ac="Action : pending"
        res="Response : pending"
        obc=reports_table.objects.filter(VISITORS_LOG__id=i.id)
        if len(obc)>0:
            ac = "Action : "+obc[0].action
            res = "Response : "+obc[0].response
        l.append({
            'id': i.id,
            'date':str(i.date),
            'image':str(i.image.url),
            'status':str(i.status),
            'ac':ac,
            'res':res,

        })
    return JsonResponse({"status":"ok","data":l})



def forward_notification(request):
    lid=request.POST['nid']
    obn=notification_table.objects.get(id=lid)
    obn.status="forwarded"
    obn.save()
    ob=reports_table()
    ob.VISITORS_LOG = obn
    ob.STATION = Police_station_table.objects.all().order_by("-id")[0]
    ob.description= "forwarded"
    ob.date = datetime.today()
    ob.action = "pending"
    ob.response="pending"
    ob.save()
    return JsonResponse({"status":"ok"})


def admin_delete_user(request,id):
    a=users_table.objects.get(id=id)
    a.delete()
    return redirect('/myapp/users')
def delete_issue(request,id):
    a=technical_issue_table.objects.get(id=id)
    a.delete()
    return redirect('/myapp/technical_issue')
