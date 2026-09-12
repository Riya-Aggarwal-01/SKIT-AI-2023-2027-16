from . import views
from django.urls import path
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('signup/', views.signup_view, name='signup'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('custom_admin/', views.admin_view, name='admin'),
    path('head/', views.head_view, name='head'),
    path('faculty/', views.faculty_view, name='faculty'),
    path('role_redirect/', views.role_redirect, name='role_redirect'),
]