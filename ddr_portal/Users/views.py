from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth import login, authenticate, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.db import connection, transaction
from django.db.models import Q
from django.http import HttpResponse, HttpResponseForbidden, FileResponse, Http404, JsonResponse
from django.urls import reverse
from django.utils import timezone
from django.utils.timezone import now
from django.views.decorators.http import require_POST

# Third-party libraries
from openpyxl import Workbook
from openpyxl.styles import Font
import pandas as pd
import csv
import openpyxl, base64
import io
import json
from io import BytesIO
import hashlib
import mimetypes

# Local imports
from .forms import CustomUserCreationForm, CustomLoginForm
from .models import (
    Folder, Document, Upload, Role, FolderUserRole,
    UserRole
)
from .utils import get_user_role_id


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

# -----------------------------
# Folder and document views
# -----------------------------

@login_required
def folder_list(request):
    # Only root folders (parent is NULL)
    folders = Folder.objects.filter(is_active=True, parent__isnull=True)
    return render(request, 'folder_list.html', {'folders': folders})

@login_required
def folder_documents(request, folder_id):
    folder = get_object_or_404(Folder, id=folder_id, is_active=True)

    # Documents inside this folder
    documents = Document.objects.filter(
        folder=folder,
        is_deleted=False,
        folder__is_active=True
    )

    # Subfolders inside this folder
    subfolders = Folder.objects.filter(
        parent=folder,
        is_active=True
    )

    return render(request, 'documents.html', {
        'folder': folder,
        'documents': documents,
        'subfolders': subfolders
    })

# -----------------------------
# Excel file download view
# -----------------------------

@login_required
def download_excel(request, doc_id):
    document = get_object_or_404(
        Document,
        id=doc_id,
        is_deleted=False,
        folder__is_active=True
    )

    raw_data = document.dynamic_data

    try:
        # Clean newline characters
        if isinstance(raw_data, str):
            raw_data = raw_data.replace('\n', '').replace('\r', '').strip()
        else:
            return HttpResponse("dynamic_data is not a string", status=400)

        # Parse JSON
        dynamic_data = json.loads(raw_data)

        # Get main key and columns
        first_key = next(iter(dynamic_data))
        columns = dynamic_data[first_key]["columns"]

        # Create Excel workbook
        wb = Workbook()
        ws = wb.active
        ws.title = document.title
        ws.sheet_properties.tabColor = "1072BA"
        ws.freeze_panes = "A2"

        # Write column headers
        for index, col in enumerate(columns, start=1):
            name = col.get("name", "Unnamed")
            cell = ws.cell(row=1, column=index, value=name)
            cell.font = Font(bold=True)
            ws.column_dimensions[cell.column_letter].width = max(len(name) + 2, 20)

        # Prepare HTTP response
        response = HttpResponse(
            content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        filename = f"{document.title.replace(' ', '_')}.xlsx"
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        wb.save(response)
        return response

    except json.JSONDecodeError as je:
        print("JSON Decode Error:", je)
        return HttpResponse(f"JSON Decode Error: {je}", status=400)

    except KeyError as ke:
        print("Missing expected key:", ke)
        return HttpResponse(f"Missing expected key: {ke}", status=400)

    except Exception as e:
        print("Unexpected Error:", e)
        return HttpResponse(f"Unexpected Error: {e}", status=400)

@login_required
def see_template(request, doc_id):
    document = get_object_or_404(
        Document,
        id=doc_id,
        is_deleted=False,
        folder__is_active=True
    )
    raw_data = document.dynamic_data

    try:
        if isinstance(raw_data, str):
            raw_data = raw_data.replace('\n', '').replace('\r', '').strip()
        else:
            return HttpResponse("dynamic_data is not a string", status=400)

        dynamic_data = json.loads(raw_data)
        first_key = next(iter(dynamic_data))
        columns = dynamic_data[first_key]["columns"]

        return render(request, 'template_preview.html', {
            'document': document,
            'columns': columns
        })

    except json.JSONDecodeError as je:
        return HttpResponse(f"JSON Decode Error: {je}", status=400)
    except KeyError as ke:
        return HttpResponse(f"Missing key: {ke}", status=400)
    except Exception as e:
        return HttpResponse(f"Unexpected error: {e}", status=400)

    except json.JSONDecodeError as je:
        return HttpResponse(f"JSON Decode Error: {je}", status=400)
    except KeyError as ke:
        return HttpResponse(f"Missing key: {ke}", status=400)
    except Exception as e:
        return HttpResponse(f"Unexpected error: {e}", status=400)

# -----------------------------
# Uploaded Section
#-----------------------------


@login_required
def upload_folder_list(request):
    user = request.user

    # Check if user is admin
    is_admin = FolderUserRole.objects.filter(
        user=user,
        role__role_name__iexact="admin"
    ).exists()

    if is_admin:
        # Admin sees all root folders
        folders = Folder.objects.filter(parent__isnull=True, is_active=True)
    else:
        # Non-admin sees only root folders they have access to
        folders = Folder.objects.filter(
            id__in=FolderUserRole.objects.filter(user=user).values_list('folder_id', flat=True),
            parent__isnull=True,
            is_active=True
        ).distinct()

    return render(request, 'upload_file_list.html', {'folders': folders})

@login_required
def upload_document_list(request, folder_id):
    user = request.user
    is_admin = FolderUserRole.objects.filter(
        user=user,
        role__role_name__iexact="admin"
    ).exists()

    if not is_admin:
        has_access = FolderUserRole.objects.filter(user=user, folder_id=folder_id).exists()
        if not has_access:
            return HttpResponse("Unauthorized", status=403)

    folder = get_object_or_404(Folder, id=folder_id, is_active=True)
    if is_admin:
        documents = Document.objects.filter(folder=folder, is_deleted=False)
    else:
        assigned_file_ids = FolderUserRole.objects.filter(
            user=user,
            folder=folder
        ).values_list('file_id', flat=True)
        documents = Document.objects.filter(
            id__in=assigned_file_ids,
            is_deleted=False
        )

    if is_admin:
        subfolders = Folder.objects.filter(parent=folder, is_active=True)
    else:
        subfolders = Folder.objects.filter(
            parent=folder,
            is_active=True,
            id__in=FolderUserRole.objects.filter(user=user).values_list('folder_id', flat=True)
        ).distinct()

    return render(request, 'upload_document_list.html', {
        'folder': folder,
        'documents': documents,
        'subfolders': subfolders
    })


@require_POST

@login_required
def ajax_upload_file(request):
    try:
        uploaded_file = request.FILES.get('file')
        folder_id = request.POST.get('folder_id')
        document_id = request.POST.get('document_id')

        if not uploaded_file or not folder_id or not document_id:
            return JsonResponse({'success': False, 'error': 'Missing data'})

        folder = get_object_or_404(Folder, id=folder_id, is_active=True)
        document = get_object_or_404(Document, id=document_id, is_deleted=False)
        file_blob = uploaded_file.read()

        upload_instance = Upload.objects.create(
            document=document,
            folder=folder,
            uploaded_by=request.user,
            file_name=uploaded_file.name,
            file_blob=file_blob,
            file_size=uploaded_file.size,
            mime_type=uploaded_file.content_type,
            sha256_hash=hashlib.sha256(file_blob).hexdigest()
        )
        ActivityLog.objects.create(
            user=request.user,
            upload=upload_instance,
            file_name=upload_instance.file_name,
            action="UPLOAD"
        )


        return JsonResponse({'success': True})

    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)})

def get_visible_documents(user, folder):
    # Get roles for the user in this folder
    user_roles = FolderUserRole.objects.filter(user=user, folder=folder)

    # If the user is Head, return all documents
    if user_roles.filter(role__name='Head').exists():
        return Document.objects.filter(folder=folder, is_active=True)

    # If Faculty, return only assigned documents
    faculty_roles = user_roles.filter(role__name='Faculty', file__isnull=False, is_active=True, is_deleted=False)
    return Document.objects.filter(id__in=faculty_roles.values_list('file_id', flat=True), is_active=True, is_deleted=False)