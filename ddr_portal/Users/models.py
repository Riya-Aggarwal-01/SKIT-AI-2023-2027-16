from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from django.contrib.auth.models import User

class Folder(models.Model):
    id = models.AutoField(primary_key=True)
    folder_name = models.CharField(max_length=255)
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True)
    category = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'FOLDERS'
        managed = False

    def __str__(self):
        return self.folder_name

class Document(models.Model):
    id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    folder = models.ForeignKey(Folder, on_delete=models.CASCADE)
    dynamic_data = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()
    is_deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'DOCUMENTS'
        managed = False

    def __str__(self):
        return self.title

class Upload(models.Model):
    id = models.AutoField(primary_key=True)
    document = models.ForeignKey('Document', on_delete=models.CASCADE, db_column='document_id')
    folder = models.ForeignKey('Folder', on_delete=models.CASCADE, db_column='folder_id')
    uploaded_by = models.ForeignKey(User, on_delete=models.CASCADE, db_column='uploaded_by')
    upload_time = models.DateTimeField(auto_now_add=True)
    file_name = models.CharField(max_length=255)
    file_blob = models.BinaryField()
    file_size = models.BigIntegerField(null=True, blank=True)
    mime_type = models.CharField(max_length=255, null=True, blank=True)
    sha256_hash = models.CharField(max_length=64, null=True, blank=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'UPLOADS'
        managed = False

    def __str__(self):
        return self.file_name
    def __str__(self):
        return f"{self.file_name} ({'Deleted' if self.is_deleted else 'Active'})"

class Role(models.Model):
    role_id = models.AutoField(primary_key=True)
    role_name = models.CharField(max_length=255)
    description = models.TextField()

    class Meta:
        db_table = 'ROLES'
        managed = False

    def __str__(self):
        parts = [self.user.username, self.folder.folder_name]
        if self.document:
            parts.append(self.document.title)
        parts.append(self.role.role_name)
        return " - ".join(parts)

class UserRole(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, db_column='user_id', primary_key=True)
    role = models.ForeignKey(Role, on_delete=models.CASCADE, db_column='role_id')

    class Meta:
        db_table = 'USER_ROLES'
        managed = False

class FolderUserRole(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    folder = models.ForeignKey('Folder', on_delete=models.CASCADE)
    file = models.ForeignKey('Document', on_delete=models.CASCADE, null=True, blank=True)  # newly added
    role = models.ForeignKey('Role', on_delete=models.CASCADE)
    assigned_at = models.DateTimeField()

    class Meta:
        db_table = 'FOLDER_USER_ROLE'
        managed = False
        unique_together = ('user', 'folder', 'file')  # updated uniqueness constraint

    def __str__(self):
        parts = [self.user.username, self.folder.folder_name]
        if self.document:
            parts.append(self.document.title)  # assuming 'title' is the correct field
        parts.append(self.role.role_name)
        return " - ".join(parts)