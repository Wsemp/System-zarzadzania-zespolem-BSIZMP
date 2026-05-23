using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using desktopapp.Data;
using desktopapp.Models;
using desktopapp.Services;
using Microsoft.EntityFrameworkCore;
using Moq;
using Moq.Protected;
using Newtonsoft.Json;
using Xunit;
using System.Collections.Generic;
using System.Linq;
using System;

namespace desktopapp.Tests
{
    public class ApiServiceTests
    {
        private readonly DbContextOptions<AppDbContext> _dbOptions;

        public ApiServiceTests()
        {
            _dbOptions = new DbContextOptionsBuilder<AppDbContext>()
                .UseInMemoryDatabase(databaseName: System.Guid.NewGuid().ToString())
                .Options;
        }

        private Mock<HttpMessageHandler> CreateHttpMock(HttpStatusCode statusCode, object? content = null)
        {
            var handlerMock = new Mock<HttpMessageHandler>();
            var response = new HttpResponseMessage
            {
                StatusCode = statusCode,
                Content = content != null ? new StringContent(JsonConvert.SerializeObject(content)) : null
            };

            handlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>()
                )
                .ReturnsAsync(response);

            return handlerMock;
        }

        [Fact]
        public async Task LoginAsync_Zwraca_True_Gdy_Serwer_Odpowiada_200()
        {
            var handlerMock = CreateHttpMock(HttpStatusCode.OK, new { access = "fake_token" });
            var httpClient = new HttpClient(handlerMock.Object);
            
            using (var context = new AppDbContext(_dbOptions))
            {
                await context.Database.EnsureCreatedAsync();
                var apiService = new ApiService(httpClient, context);
                bool result = await apiService.LoginAsync("testUser", "testPass");

                Assert.True(result);
                Assert.Equal("fake_token", apiService.AccessToken);
                Assert.Equal("testUser", apiService.LoggedInUsername);
            }
        }

        [Fact]
        public async Task LoginAsync_Zwraca_False_Gdy_Serwer_Zwraca_Blad()
        {
            var handlerMock = CreateHttpMock(HttpStatusCode.Unauthorized);
            var httpClient = new HttpClient(handlerMock.Object);
            
            using (var context = new AppDbContext(_dbOptions))
            {
                await context.Database.EnsureCreatedAsync();
                var apiService = new ApiService(httpClient, context);
                bool result = await apiService.LoginAsync("wrongUser", "wrongPass");
                
                Assert.False(result);
                Assert.Null(apiService.AccessToken);
            }
        }

        
        [Fact]
        public async Task GetPendingInvitationsAsync_ShouldReturnListOfInvitations_WhenApiReturns200()
        {

            var invitations = new List<InvitationModel>
            {
                new InvitationModel { Id = 1, ProjectName = "Projekt 1", InviterUsername = "Admin", Message = "Zaproszenie A" },
                new InvitationModel { Id = 2, ProjectName = "Projekt 2", InviterUsername = "User2", Message = "Zaproszenie B" }
            };
            
            var handlerMock = CreateHttpMock(HttpStatusCode.OK, invitations);
            var httpClient = new HttpClient(handlerMock.Object);
            var apiService = new ApiService(httpClient);

            // Act
            var result = await apiService.GetPendingInvitationsAsync();

            // Assert
            Assert.NotNull(result);
            Assert.Equal(2, result.Count);
            Assert.Equal("Zaproszenie A", result.First().Message);
            
            // Sprawdzamy, czy nasze nowe właściwości wyświetlają się poprawnie
            Assert.Equal("Projekt 1", result.First().DisplayProject); 
            Assert.Equal("Admin", result.First().DisplayInviter); 
        }

        [Theory]
        [InlineData(HttpStatusCode.OK, true)]
        [InlineData(HttpStatusCode.NotFound, false)]
        [InlineData(HttpStatusCode.InternalServerError, false)]
        public async Task AcceptInvitationAsync_ShouldReturnCorrectStatus(HttpStatusCode statusCode, bool expectedResult)
        {
            // Arrange
            var handlerMock = CreateHttpMock(statusCode);
            var httpClient = new HttpClient(handlerMock.Object);
            var apiService = new ApiService(httpClient);

            // Act
            var result = await apiService.AcceptInvitationAsync(1);

            // Assert
            Assert.Equal(expectedResult, result);
        }

        [Theory]
        [InlineData(HttpStatusCode.OK, true)]
        [InlineData(HttpStatusCode.NotFound, false)]
        public async Task RejectInvitationAsync_ShouldReturnCorrectStatus(HttpStatusCode statusCode, bool expectedResult)
        {
            // Arrange
            var handlerMock = CreateHttpMock(statusCode);
            var httpClient = new HttpClient(handlerMock.Object);
            var apiService = new ApiService(httpClient);

            // Act
            var result = await apiService.RejectInvitationAsync(1);

            // Assert
            Assert.Equal(expectedResult, result);
        }

        [Fact]
        public async Task GetNotificationsAsync_ShouldReturnListOfNotifications_WhenApiReturns200()
        {
            // Arrange
            var notifications = new List<NotificationModel>
            {
                new NotificationModel { Id = 1, Message = "Notification 1", CreatedAt = DateTime.Now, IsRead = false },
                new NotificationModel { Id = 2, Message = "Notification 2", CreatedAt = DateTime.Now, IsRead = true }
            };
            var handlerMock = CreateHttpMock(HttpStatusCode.OK, notifications);
            var httpClient = new HttpClient(handlerMock.Object);
            var apiService = new ApiService(httpClient);

            // Act
            var result = await apiService.GetNotificationsAsync();

            // Assert
            Assert.NotNull(result);
            Assert.Equal(2, result.Count);
            Assert.Equal("Notification 1", result.First().Message);
            handlerMock.Protected().Verify(
                "SendAsync",
                Times.Once(),
                ItExpr.Is<HttpRequestMessage>(req =>
                    req.Method == HttpMethod.Get
                    && req.RequestUri != null
                    && req.RequestUri.ToString().Contains("/api/notifications/")),
                ItExpr.IsAny<CancellationToken>()
            );
        }
        
        [Fact]
        public async Task Logout_Powinno_Wyczyscic_Token_I_Dane_Uzytkownika()
        {
            // Arrange - przygotowujemy serwer, żeby "przepuścił" logowanie
            var handlerMock = CreateHttpMock(HttpStatusCode.OK, new { access = "super_tajny_token_jwt_12345" });
            var httpClient = new HttpClient(handlerMock.Object);

            using (var context = new AppDbContext(_dbOptions))
            {
                await context.Database.EnsureCreatedAsync();
                var apiService = new ApiService(httpClient, context);

                // Symulujemy prawdziwe logowanie użytkownika (to wewnątrz ApiService ustawi token)
                await apiService.LoginAsync("admin", "tajnehaslo123");

                // Upewniamy się wstępnie, że po zalogowaniu token istnieje
                Assert.NotNull(apiService.AccessToken);
                Assert.Equal("admin", apiService.LoggedInUsername);

                // Act - wywołujemy akcję wylogowania
                apiService.Logout(); 

                // Assert - sprawdzamy (wymuszamy), czy pamięć po sesji została wyczyszczona
                Assert.Null(apiService.AccessToken);
                Assert.Null(apiService.LoggedInUsername);
            }
        }
    }
}