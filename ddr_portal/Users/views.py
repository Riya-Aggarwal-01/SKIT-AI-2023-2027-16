from django.shortcuts import render, redirect
from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseForbidden
from django.db import connection

from .forms import CustomUserCreationForm, CustomLoginForm


def home_view(request):
    return render(request, 'home.html')

def signup_view(request):
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            return redirect('role_redirect')
    else:
        form = CustomUserCreationForm()
    return render(request, 'signup.html', {'form': form})


def login_view(request):
    if request.method == 'POST':
        form = CustomLoginForm(data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            return redirect('/role_redirect')
    else:
        form = CustomLoginForm()
    return render(request, 'login.html', {'form': form})


def logout_view(request):
    logout(request)
    return redirect('login')

def get_user_role(user_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT role_id FROM USER_ROLES WHERE user_id = %s", [user_id])
        row = cursor.fetchone()
    if row:
        return row[0]
    return None

@login_required
def admin_view(request):
    role = get_user_role(request.user.id)
    if role != 1:
        return HttpResponseForbidden("You do not have permission to access this page.")
    return render(request, 'admin.html')

@login_required
def head_view(request):
    role = get_user_role(request.user.id)
    if role != 2:
        return HttpResponseForbidden("You do not have permission to access this page.")
    return render(request, 'head.html')

@login_required
def faculty_view(request):
    role = get_user_role(request.user.id)
    if role != 3:
        return HttpResponseForbidden("You do not have permission to access this page.")
    return render(request, 'faculty.html')

@login_required
def role_redirect(request):
    user_id = request.user.id
    with connection.cursor() as cursor:
        cursor.execute("SELECT role_id FROM USER_ROLES WHERE user_id = %s", [user_id])
        row = cursor.fetchone()

    if row:
        role_id = row[0]
        if role_id == 1:
            return redirect('admin')
        elif role_id == 2:
            return redirect('head')
        elif role_id == 3:
            return redirect('faculty')

    return redirect('login')
