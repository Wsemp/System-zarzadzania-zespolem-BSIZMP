from django.shortcuts import render

def test_view(request):
    print(request)
    return render(request, 'main_page/main.html')
