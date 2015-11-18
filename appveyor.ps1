$ErrorActionPreference = "Stop"

function CheckLastExitCode
{
    param ([int[]]$SuccessCodes = @(0))

    if ($SuccessCodes -notcontains $LastExitCode)
	{
        $msg = @"
EXE RETURNED EXIT CODE $LastExitCode
CALLSTACK:$(Get-PSCallStack | Out-String)
"@
        throw $msg
    }
}

switch ($env:RUN)
{
	"ci"
	{
		mvn package "--batch-mode" "-B" "-e" "-V"
		CheckLastExitCode
	}
	"its_dev"
	{
		cd it
		mvn -DsonarRunner.version="2.5-SNAPSHOT" -Dsonar.runtimeVersion=DEV -Dmaven.test.redirectTestOutputToFile=false -B -e -V package
                CheckLastExitCode
	}
	"its_lts"
	{
		cd it
		mvn -DsonarRunner.version="2.5-SNAPSHOT" -Dsonar.runtimeVersion=LTS -Dmaven.test.redirectTestOutputToFile=false -B -e -V package
		CheckLastExitCode
	}

	default
	{
		throw "Unexpected test mode: ""$env:RUN"""
	}
}
