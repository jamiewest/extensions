import '../../open_telemetry_consts.dart';
import 'commands/clean_cache_command.dart';
import 'commands/clean_results_command.dart';
import 'telemetry/telemetry_helper.dart';

class Program {
  Program();

  static Future<int> main(List<String> args) async  {
    #pragma warning disable CA1303 // Do not pass literals as localized parameters.
        // Use Console.writeLine directly instead of ILogger to ensure proper formatting.
        System.console.writeLine(Banner);
    System.console.writeLine();
    var factory = LoggerFactory.create((builder) =>
                builder.addSimpleConsole((options) =>
                {
                    options.singleLine = true;
                }));
    var logger = factory.createLogger(ShortName);
    await logger.displayTelemetryOptOutMessageIfNeededAsync().configureAwait(false);
    var telemetryHelper = telemetryHelper(logger);
    var rootCmd = rootCommand(Banner);
    var reportCmd = command("report", "Generate a report from a result store");
    var pathOpt = Option<DirectoryInfo>(
                ["-p", "--path"],
                "Root path under which the cache and results are stored");
    var endpointOpt = Option<Uri>(
                ["--endpoint"],
                "Endpoint URL under which the cache and results are stored for Azure Data Lake Gen2 storage");
    var openReportOpt = Option<bool>(
                ["--open"],
                getDefaultValue: () => false,
                "Open the report in the default browser")
            {
                IsRequired = false,
            };
    var requiresPathOrEndpoint = (CommandResult cmd) =>
        {
            bool hasPath = cmd.getValueForOption(pathOpt) != null;
            bool hasEndpoint = cmd.getValueForOption(endpointOpt) != null;
            if (!(hasPath ^ hasEndpoint))
            {
                cmd.errorMessage = 'Either '${pathOpt.name}' or '${endpointOpt.name}' must be specified.';
      }
        };
    reportCmd.addOption(pathOpt);
    reportCmd.addOption(endpointOpt);
    reportCmd.addOption(openReportOpt);
    reportCmd.addValidator(requiresPathOrEndpoint);
    var outputOpt = Option<FileInfo>(
            ["-o", "--output"],
            "Output filename/path");
    reportCmd.addOption(outputOpt);
    var lastNOpt = Option<int>(
      ["-n"],
      () => 10,
      "Number of most recent executions to include in the report.",
    );
    reportCmd.addOption(lastNOpt);
    var formatOpt = Option<ReportCommand.format>(
                ["-f", "--format"],
                () => ReportCommand.format.html,
                "Specify the format for the generated report.");
    reportCmd.addOption(formatOpt);
    reportCmd.setHandler(
            (path, endpoint, output, openReport, lastN, format) =>
                reportCommand(logger, telemetryHelper)
                    .invokeAsync(path, endpoint, output, openReport, lastN, format),
            pathOpt,
            endpointOpt,
            outputOpt,
            openReportOpt,
            lastNOpt,
            formatOpt);
    rootCmd.add(reportCmd);
    var cleanResultsCmd = command("clean-results", "Delete results");
    cleanResultsCmd.addOption(pathOpt);
    cleanResultsCmd.addOption(endpointOpt);
    cleanResultsCmd.addValidator(requiresPathOrEndpoint);
    var lastNOpt2 = Option<int>(["-n"], () => 0, "Number of most recent executions to preserve.");
    cleanResultsCmd.addOption(lastNOpt2);
    cleanResultsCmd.setHandler(
            (path, endpoint, lastN) =>
                cleanResultsCommand(logger, telemetryHelper).invokeAsync(path, endpoint, lastN),
            pathOpt,
            endpointOpt,
            lastNOpt2);
    rootCmd.add(cleanResultsCmd);
    var cleanCacheCmd = command("clean-cache", "Delete expired cache entries");
    cleanCacheCmd.addOption(pathOpt);
    cleanCacheCmd.addOption(endpointOpt);
    cleanCacheCmd.addValidator(requiresPathOrEndpoint);
    cleanCacheCmd.setHandler(
            (
              path,
              endpoint,
            ) => cleanCacheCommand(logger, telemetryHelper).invokeAsync(path, endpoint),
            pathOpt, endpointOpt);
    rootCmd.add(cleanCacheCmd);
    var exitCode = await rootCmd.invokeAsync(args).configureAwait(false);
    return exitCode;
  }
}
