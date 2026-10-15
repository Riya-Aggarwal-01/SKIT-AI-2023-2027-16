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

@login_required
def assign_folder_role(request):
    from django.utils.timezone import now

    admin_role_id = Role.objects.get(role_name__iexact="admin").role_id

    def assign_recursive(user_id, folder_id, role_id):
        """
        Recursively assign role to folder, all its subfolders, and documents.
        """
        # Assign role to folder itself
        FolderUserRole.objects.get_or_create(
            user_id=user_id,
            folder_id=folder_id,
            role_id=role_id,
            defaults={"assigned_at": now()}
        )

        # Assign role to all documents inside this folder
        documents = Document.objects.filter(folder_id=folder_id, is_deleted=False)
        for doc in documents:
            FolderUserRole.objects.get_or_create(
                user_id=user_id,
                file_id=doc.id,
                role_id=role_id,
                folder_id=folder_id,
                defaults={"assigned_at": now()}
            )

        # Recurse into subfolders
        subfolders = Folder.objects.filter(parent_id=folder_id, is_active=True)
        for sub in subfolders:
            assign_recursive(user_id, sub.id, role_id)

    if request.method == "POST":
        user_id = request.POST.get("user_id")
        folder_id = request.POST.get("folder_id")
        role_id = int(request.POST.get("role_id"))
        file_id = request.POST.get("file_id") or None
        include_subtree = request.POST.get("include_subtree") == "true"

        if user_id and role_id:
            try:
                if role_id == admin_role_id:
                    # Admin → assign everything
                    for folder in Folder.objects.filter(is_active=True):
                        assign_recursive(user_id, folder.id, role_id)
                    messages.success(request, "Admin role assigned with full access.")
                else:
                    if file_id and str(file_id).startswith("subfolder-"):
                        subfolder_id = int(file_id.replace("subfolder-", ""))
                        if include_subtree:
                            assign_recursive(user_id, subfolder_id, role_id)
                            messages.success(request, "Role assigned recursively to subfolder and its contents.")
                        else:
                            # Only assign to this subfolder
                            FolderUserRole.objects.get_or_create(
                                user_id=user_id,
                                folder_id=subfolder_id,
                                role_id=role_id,
                                defaults={"assigned_at": now()}
                            )
                            messages.success(request, "Role assigned to selected subfolder.")
                    else:
                        # Document or folder only
                        exists = FolderUserRole.objects.filter(
                            user_id=user_id,
                            folder_id=folder_id,
                            file_id=file_id,
                            role_id=role_id
                        ).exists()
                        if exists:
                            messages.warning(request, "This role assignment already exists.")
                        else:
                            FolderUserRole.objects.create(
                                user_id=user_id,
                                folder_id=folder_id,
                                file_id=file_id,
                                role_id=role_id,
                                assigned_at=now()
                            )
                            messages.success(request, "Role assigned successfully to document/folder.")

            except Exception as e:
                messages.error(request, f"Error: {str(e)}")
        else:
            messages.error(request, "User and role are required.")

        return redirect('assign_folder_role')

    # GET request → show form only
    users = User.objects.all()
    folders = Folder.objects.filter(is_active=True, parent__isnull=True)
    roles = Role.objects.all()
    documents = Document.objects.filter(is_deleted=False).select_related("folder")
    subfolders = Folder.objects.filter(is_active=True, parent__isnull=False)

    return render(request, "assign_folder_roles.html", {
        "users": users,
        "folders": folders,
        "roles": roles,
        "documents": documents,
        "subfolders": subfolders,
    })

def assign_recursive(user_id, folder_id, role_id):
    # Assign to the folder itself
    FolderUserRole.objects.get_or_create(user_id=user_id, folder_id=folder_id, role_id=role_id)

    # Assign to all documents in this folder
    documents = Document.objects.filter(folder_id=folder_id, is_deleted=False)
    for doc in documents:
        FolderUserRole.objects.get_or_create(user_id=user_id, file_id=doc.id, folder_id=folder_id, role_id=role_id)

    # Recurse into subfolders
    subfolders = Folder.objects.filter(parent_id=folder_id, is_active=True)
    for sub in subfolders:
        assign_recursive(user_id, sub.id, role_id)


@login_required
def under_head_role(request):
    if request.method == "GET":
        # Get current user
        current_user = request.user

        folder_head_roles = FolderUserRole.objects.filter(
            user=current_user,
            role__role_name__iexact="Head"
        ).values_list('folder_id', flat=True)

        assignments = FolderUserRole.objects.select_related("user", "folder", "role", "file").filter(folder_id__in=folder_head_roles)
        return render(request, "folder_role_assignments.html", {"assignments": assignments})
    else:
        return render(request, "error.html", {"message": "Invalid request method."})


@login_required
def folder_role_assignments(request):
    assignments = FolderUserRole.objects.select_related("user", "folder", "role", "file").all()
    return render(request, "folder_role_assignments.html", {"assignments": assignments})

    # GET request
    users = User.objects.exclude(is_superuser=True)  # remove admin from user dropdown
    folders = Folder.objects.all()
    roles = Role.objects.all()
    documents = Document.objects.select_related('folder').all()
    assignments = FolderUserRole.objects.select_related('user', 'folder', 'role', 'file')

    return render(request, "assign_folder_roles.html", {
        "users": users,
        "folders": folders,
        "roles": roles,
        "assignments": assignments,
        "documents": documents
    })

@login_required
def remove_role(request, user_role_id):
    role_instance = get_object_or_404(FolderUserRole, id=user_role_id)

    # Check if removing last admin
    if role_instance.role.role_name.lower() == "admin":
        admin_count = FolderUserRole.objects.filter(role__role_name__iexact="admin").count()
        if admin_count <= 1:
            # First confirmation
            confirm1 = request.GET.get("confirm1")
            confirm2 = request.GET.get("confirm2")

            if not confirm1:
                messages.warning(request, "Are you sure you want to remove the LAST admin? Click again to confirm.")
                return redirect(f"{request.path}?confirm1=true")

            if not confirm2:
                messages.warning(request, "This is your FINAL confirmation. Click again to permanently remove.")
                return redirect(f"{request.path}?confirm1=true&confirm2=true")

    role_instance.delete()
    messages.success(request, "Role removed successfully.")
    return redirect("folder_role_assignments")