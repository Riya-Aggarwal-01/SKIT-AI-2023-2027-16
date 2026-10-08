from django.db import connection

def get_user_role_id(user_id):
    """Fetch the role_id for the given user from USER_ROLES table."""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT role_id
            FROM USER_ROLES
            WHERE user_id = %s
        """, [user_id])
        result = cursor.fetchone()
        return result[0] if result else None

def is_admin_or_faculty(user_id):
    """Return True if the user is Admin (1) or Faculty (3)."""
    role_id = get_user_role_id(user_id)
    return role_id in (1, 3)