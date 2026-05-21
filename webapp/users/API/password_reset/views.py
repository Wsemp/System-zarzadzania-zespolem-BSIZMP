from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import send_mail, EmailMessage
from django.conf import settings

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response

from .serializers import PasswordResetRequestSerializer, PasswordResetConfirmSerializer

User = get_user_model()
token_generator = PasswordResetTokenGenerator()

class PasswordResetRequestView(APIView):
    """
    Przyjmuje email. Jeżeli użytkownik istnieje — wysyła maila z tokenem.
    Zwraca 200 zawsze (nie ujawniamy istnienia konta).
    """
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']

        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist:
            user = None

        # generuj token i wyślij mail tylko jeśli user istnieje
        if user:
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = token_generator.make_token(user)

            # frontend link — ustaw w settings.FRONTEND_URL lub zmodyfikuj tutaj
            frontend_url = getattr(settings, "FRONTEND_URL", "http://localhost:8000")
            reset_link = f"{frontend_url}/reset-password/?uid={uid}&token={token}"

            subject = "Password reset"
            message = f"Jeśli prosiłeś o reset hasła, użyj poniższego linku:\n\n{reset_link}\n\nJeśli nie, zignoruj."
            from_email = getattr(settings, "DEFAULT_FROM_EMAIL", None)

            # spróbuj wysłać e-mail, jeśli nie skonfigurowano — opcjonalnie loguj
            try:
                if from_email:
                    send_mail(subject, message, from_email, [user.email], fail_silently=False)
                else:
                    # gdy brak DEFAULT_FROM_EMAIL — użyj EmailMessage bez from_email albo loguj
                    EmailMessage(subject, message, to=[user.email]).send(fail_silently=True)
            except Exception:
                # nie ujawniamy błędów klientowi — logowanie po stronie serwera jest ok
                pass

            # dla środowiska deweloperskiego możesz także logować link
            if settings.DEBUG:
                # użyj loggera zamiast printu w produkcji
                print("Password reset link:", reset_link)

        return Response({"detail": "Jeśli adres email istnieje, wysłaliśmy instrukcje resetu."}, status=status.HTTP_200_OK)


class PasswordResetConfirmView(APIView):
    """
    Przyjmuje uid, token, new_password. Weryfikuje token i ustawia nowe hasło.
    """
    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        uid = serializer.validated_data['uid']
        token = serializer.validated_data['token']
        new_password = serializer.validated_data['new_password']

        try:
            uid_int = force_str(urlsafe_base64_decode(uid))
            user = User.objects.get(pk=uid_int)
        except Exception:
            return Response({"detail": "Nieprawidłowy token lub uid."}, status=status.HTTP_400_BAD_REQUEST)

        if not token_generator.check_token(user, token):
            return Response({"detail": "Token nieprawidłowy lub wygasł."}, status=status.HTTP_400_BAD_REQUEST)

        # ustaw nowe hasło
        user.set_password(new_password)
        user.save()

        return Response({"detail": "Hasło zostało zmienione."}, status=status.HTTP_200_OK)