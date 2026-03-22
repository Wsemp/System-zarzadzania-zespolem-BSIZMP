from django.shortcuts import render
from django.contrib.auth.decorators import login_required

@login_required
def main(request):
    print(request)
    return render(request, 'main_page/main.html')
