from .utils import get_user_role_id

def role_context(request):
    if request.user.is_authenticated:
        role_id = get_user_role_id(request.user.id)
    else:
        role_id = None
    return {"role_id": role_id}