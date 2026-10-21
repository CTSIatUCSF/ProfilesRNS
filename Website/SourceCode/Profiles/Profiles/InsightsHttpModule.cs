using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles
{
    public class InsightsHttpModule : IHttpModule
    {
        public void Init(HttpApplication context)
        {
            // Hook early into the pipeline before URL rewrite rules evaluate
            context.BeginRequest += OnBeginRequest;
        }

        private void OnBeginRequest(object sender, EventArgs e)
        {
            HttpApplication app = (HttpApplication)sender;

            // This injects the variable into the server environment context
            app.Context.Request.Headers["MY_INST"] = "ucsd";
        }

        public void Dispose() { }
    }
}