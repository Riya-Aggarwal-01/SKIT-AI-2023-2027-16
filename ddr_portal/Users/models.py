from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

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

