using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using desktopapp.Data;
using desktopapp.Services;
using Microsoft.EntityFrameworkCore;
using Moq;
using Moq.Protected;
using Xunit;

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

        [Fact]
        public async Task LoginAsync_Zwraca_True_Gdy_Serwer_Odpowiada_200()
        {
            var handlerMock = new Mock<HttpMessageHandler>();
            var response = new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("{\"access\": \"fake_token\"}")
            };

            handlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>()
                )
                .ReturnsAsync(response);

            var httpClient = new HttpClient(handlerMock.Object);
            
            using (var context = new AppDbContext(_dbOptions))
            {
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
            var handlerMock = new Mock<HttpMessageHandler>();
            var response = new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.Unauthorized,
            };

            handlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>()
                )
                .ReturnsAsync(response);

            var httpClient = new HttpClient(handlerMock.Object);
            
            using (var context = new AppDbContext(_dbOptions))
            {
                var apiService = new ApiService(httpClient, context);
                bool result = await apiService.LoginAsync("wrongUser", "wrongPass");
                
                Assert.False(result);
                Assert.Null(apiService.AccessToken);
            }
        }
    }
}