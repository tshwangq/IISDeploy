<%@ WebHandler Language="C#" Class="PostReceiveHook" %>

using System;
using System.Web;
using System.Threading ;
using System.Configuration;

public class PostReceiveHook : IHttpHandler {

    public Logger Log {
        get;
        set;
    }
    public void ProcessRequest(HttpContext context) {
        Log = new Logger(context.Server.MapPath("~/log1.txt"));
        var req = context.Request;
        Log.Log("reqest received");
        //if (req.HttpMethod.ToLower() == "post" && !string.IsNullOrWhiteSpace(req.Form["payload"]) && req.QueryString["token"] == ConfigurationManager.AppSettings["token"])  {
        //    Deploy();
        //}

        if (  req.QueryString["token"] == ConfigurationManager.AppSettings["token"]) {
            Deploy();
        }
        context.Response.ContentType = "text/plain";
        context.Response.Write("OK");
        Log.Dispose();
    }

    private void Deploy() {
        ExecuteCommandSync(string.Format(@"cd {0} && git reset --hard HEAD && git pull", ConfigurationManager.AppSettings["WebRoot"]));
    }
    
    /// <summary>
    /// Executes a shell command synchronously.
    /// </summary>
    /// <param name="command">string command</param>
    /// <returns>string, as output of the command.</returns>
    public void ExecuteCommandSync(object command) {
        try {
            Log.Log(command.ToString());
            Log.Log("begin deploy");
            // create the ProcessStartInfo using "cmd" as the program to be run,
            // and "/c " as the parameters.
            // Incidentally, /c tells cmd that we want it to execute the command that follows,
            // and then exit.
            var start =  new System.Diagnostics.ProcessStartInfo("cmd.exe ", "/c " + command);

            // The following commands are needed to redirect the standard output.
            // This means that it will be redirected to the Process.StandardOutput StreamReader.
            start.RedirectStandardOutput = true;
            start.UseShellExecute = false;
            // Do not create the black window.
            start.CreateNoWindow = true;
            // Now we create a process, assign its ProcessStartInfo and start it
            System.Diagnostics.Process proc = new System.Diagnostics.Process();
            proc.StartInfo = start;
            proc.Start();
            proc.WaitForExit();
            // Get the output into a string
            string result = proc.StandardOutput.ReadToEnd();
             Log.Log(result); // Display the command output.
            Log.Log("end deploy");
           
        } catch (Exception exp) {
            // Log the exception
            Log.LogError(exp.Message);
        }
    }
    /// <summary>
    /// Execute the command Asynchronously.
    /// </summary>
    /// <param name="command">string command.</param>
    public void ExecuteCommandAsync(string command) {
        try {
            //Asynchronously start the Thread to process the Execute command request.
            var thread = new Thread(new ParameterizedThreadStart(ExecuteCommandSync));
            //Make the thread as background thread.
            thread.IsBackground = true;
            //Set the Priority of the thread.
            thread.Priority = ThreadPriority.AboveNormal;
            //Start the thread.
            thread.Start(command);
        } catch (ThreadStartException exp) {
            // Log the exception
        } catch (ThreadAbortException exp) {
            // Log the exception
        } catch (Exception exp) {
            // Log the exception
        }
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}