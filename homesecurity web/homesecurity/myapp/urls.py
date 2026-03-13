from django.urls import path

from myapp import views

urlpatterns = [
    path('',views.view_login),
    path('Adminhome',views.view_admin_home),
    path('addpolice',views.view_addpolice),
    path('admin_add_policestation_post',views.admin_add_policestation_post),

    path('view_policestation',views.view_policestation),
    path('edit_policestation_post',views.edit_policestation_post),
    path('delete_issue/<id>',views.delete_issue),
    path('editpolice/<id>',views.editpolice),
    path('delete_police_station/<id>',views.delete_police_station),

    path('technical_issue',views.view_technical_issue),
    path('send_issue_reply/<id>',views.view_send_issue_reply),
    path('view_send_issue_reply_post',views.view_send_issue_reply_post),
    # path('user_login',views.user_login),
    path('users',views.view_users),
    path('policestation_home',views.view_policestation_home),
    path('reports',views.view_reports),
    path('response/<id>',views.view_response),
    path('admin_delete_user/<id>',views.admin_delete_user),
    path('reply/<id>',views.view_reply),
    path('view_complaint',views.view_complaint),
    path('send_reply_post',views.send_reply_post),
    path('take_action/<id>',views.view_take_action),



    path('user_register',views.user_register),
    path('user_login_page',views.user_login_page),
    path('/user_view_visitor_log',views.user_view_visitor_log),
    path('/user_view_techinical_issue/',views.user_view_techinical_issue),
    path('/user_view_complaint/',views.user_view_complaint),
    path('/user_view_familiar_person/',views.user_view_familiar_person),
    path('/user_view_camera/',views.user_view_camera),
    path('/user_view_profile/',views.user_view_profile),
    path('/user_update_profile',views.user_update_profile),
    path('/user_add_complaint/',views.user_add_complaint),
    path('/user_view_policestation/',views.user_view_policestation),
    path('/user_add_technicalissue/',views.user_add_technicalissue),
    path('/user_add_family/',views.user_add_family),
    path('/user_add_camera/',views.user_add_camera),
    path('/activate_camera/',views.activate_camera),
    path('/deactivate_camera/',views.deactivate_camera),
    path('/add_notification/',views.add_notification),
    path('/user_view_camera_person/<id>',views.user_view_camera_person),

    path('view_notification_alert',views.view_notification_alert),
    path('view_notification_user',views.view_notification_user),
    path('add_notification1',views.add_notification1),
    path('forward_notification',views.forward_notification),


]