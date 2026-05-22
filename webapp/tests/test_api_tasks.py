from datetime import timedelta

from django.test import TestCase
from django.contrib.auth import get_user_model
from django.utils import timezone
from tasks.models import Task, Tag
from projects.models import Project
from tasks.services.task_services import create_task, delete_task, update_task

User = get_user_model()


class TestTaskServices(TestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            username="user",
            password="123"
        )

        self.assigned_user = User.objects.create_user(
            username="assigned",
            password="123"
        )

        self.tag1 = Tag.objects.create(name="tag1")
        self.tag2 = Tag.objects.create(name="tag2")

    def test_create_task(self):

        project = Project.objects.create(
            name="Test project",
            owner=self.user
        )

        project.members.add(self.assigned_user,)

        task = create_task(
            created_by=self.user,
            title="Test task",
            description="desc",
            priority="Low",
            status="todo",
            assigned_to=self.assigned_user,
            tags=[self.tag1, self.tag2],
            due_date=timezone.now(),
            project=project
        )

        self.assertEqual(Task.objects.count(), 1)
        self.assertEqual(task.title, "Test task")
        self.assertEqual(task.created_by, self.user)

        # ManyToMany
        self.assertEqual(task.tags.count(), 2)
        self.assertIn(self.tag1, task.tags.all())

    def test_delete_task(self):

        project = Project.objects.create(
            name="Test project",
            owner=self.user
        )

        task = Task.objects.create(
            created_by=self.user,
            title="Test",
            description="desc",
            status="todo",
            assigned_to=self.assigned_user,
            due_date=timezone.now(),
            project=project
        )

        result = delete_task(task_id=task.id)

        self.assertTrue(result)
        self.assertEqual(Task.objects.count(), 0)

    def test_update_task(self):

        project = Project.objects.create(
            name="Test project",
            owner=self.user
        )

        task = Task.objects.create(
            created_by=self.user,
            title="Old",
            description="desc",
            status="todo",
            assigned_to=self.assigned_user,
            due_date=timezone.now(),
            project=project,
        )

        task.tags.set([self.tag1])

        updated_task = update_task(
            task_id=task.id,
            title="New title",
            tags=[self.tag2]
        )

        self.assertEqual(updated_task.title, "New title")

        # sprawdzenie tagów
        self.assertEqual(updated_task.tags.count(), 1)
        self.assertIn(self.tag2, updated_task.tags.all())
