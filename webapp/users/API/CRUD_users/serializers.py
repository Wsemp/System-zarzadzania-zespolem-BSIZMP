from django.contrib.auth.models import User
from rest_framework import serializers
from users.services.user_service import create_user, update_user

class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "email",
            "is_staff",
            "password"
        ]

        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        return create_user(**validated_data)
        # return User.objects.create_user(**validated_data)

    def update(self, instance, validated_data):
        return update_user(user=instance, **validated_data)
        """
            if "password" in validated_data:
                password = validated_data.pop("password")
                instance.set_password(password)

            return super().update(instance, validated_data)
        """
