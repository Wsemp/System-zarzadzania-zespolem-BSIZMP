from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)

        if user is not None:
            if not user.is_staff:
                return render(request, 'admin_login/login.html', {'error': 'User is not admin!'})

            else:
                login(request, user)
                return redirect('home')
        else:
            return render(request, 'admin_login/login.html', {'error': 'Invalid credentials'})

    return render(request, 'admin_login/login.html')