using MacSetup;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;

var builder = Host.CreateApplicationBuilder(args);

builder.Logging.ClearProviders();
builder.Services.AddSerilog((_, loggerConfiguration) =>
	loggerConfiguration
		.WriteTo.Console(outputTemplate: "{Message:lj}{NewLine}{Exception}"));

builder.Services.AddSingleton<MacSetupApp>();
builder.Services.AddSingleton<AppPaths>();
builder.Services.AddSingleton<CommandRunner>();
builder.Services.AddSingleton<PromptService>();
builder.Services.AddSingleton<PlatformService>();
builder.Services.AddSingleton<ISetupBackupService, SudoersService>();
builder.Services.AddSingleton<ISetupBackupService, HomebrewService>();
builder.Services.AddSingleton<ISetupBackupService, DotfilesService>();
builder.Services.AddSingleton<ISetupBackupService, DockService>();
builder.Services.AddSingleton<ISetupBackupService, MasService>();
builder.Services.AddSingleton<ISetupBackupService, MackupService>();
builder.Services.AddSingleton<ISetupBackupService, RaycastService>();
builder.Services.AddSingleton<ISetupBackupService, MacOsDefaultsService>();
builder.Services.AddSingleton<ISetupBackupService, CompareDefaultsService>();

using var host = builder.Build();

var platform = host.Services.GetRequiredService<PlatformService>();
platform.EnsureMacOs();

var app = host.Services.GetRequiredService<MacSetupApp>();
var exitCode = await app.RunAsync(args, CancellationToken.None);
return exitCode;
