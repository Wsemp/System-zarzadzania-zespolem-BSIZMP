from django.db import models
from django.conf import settings
from django.utils import timezone
from django.core.exceptions import ValidationError
import uuid
from django.db.models import Q

class Invitation(models.Model):

    token = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    email = models.EmailField()
    inviter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='sent_invitations'
    )

    project = models.ForeignKey(
        'projects.Project',
        on_delete=models.CASCADE,
        null=False,
        blank=False,
        related_name='invitations'
    )

    message = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    accepted = models.BooleanField(default=False)
    accepted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='accepted_invitations'
    )
    accepted_at = models.DateTimeField(null=True, blank=True)

    class Meta:

        constraints = [

            models.UniqueConstraint(
                fields=['email', 'project'],
                condition=Q(accepted=False),
                name='unique_pending_invitation_per_email_project'
            )
        ]

    def __str__(self):
        return f"Invitation({self.email}) for {self.project or 'general'} token={self.token}"

    @property
    def is_expired(self):
        return bool(self.expires_at and timezone.now() > self.expires_at)

    @property
    def can_accept(self):
        return not self.accepted and not self.is_expired

    def accept(self, user):

        if self.is_expired:
            raise ValidationError("Invitation has expired.")
        if self.accepted:
            raise ValidationError("Invitation already accepted.")
        self.accepted = True
        self.accepted_by = user
        self.accepted_at = timezone.now()
        self.save()

        if self.project:
            self.project.members.add(user)

