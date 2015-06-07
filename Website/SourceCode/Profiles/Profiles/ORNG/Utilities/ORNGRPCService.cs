using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Profiles.Framework.Utilities;
using System.Web.UI;
using System.Configuration;

namespace Profiles.ORNG.Utilities
{
    public abstract class ORNGRPCService
    {
        private static readonly string KEY_PREFIX = "ORNG.ORNGRPCService :";

        private static List<WeakReference> managers = new List<WeakReference>();

        private OpenSocialManager om;
        private List<string> channels = new List<string>();

        public ORNGRPCService(string uri, Page page, bool editMode, string[] chnls)
        {
            this.om = OpenSocialManager.GetOpenSocialManager(uri, page, false);
            this.channels.AddRange(chnls);
            // Add to Session so that it does not get prematurely garbage collected
            HttpContext.Current.Session[KEY_PREFIX + ":" + om.GetGuid().ToString()] = this;
            managers.Add(new WeakReference(this));
            DebugLogging.Log("ORNGRPCService created :" + om.GetGuid().ToString() + " channels " + this.channels.ToString());
        }

        public OpenSocialManager GetOpenSocialManager()
        {
            return this.om;
        }

        public static ORNGRPCService GetRPCService(Guid guid, string channel)
        {
            DebugLogging.Log("ORNGRPCService guid :" + guid);
            ORNGRPCService retval = null;
            foreach (WeakReference wr in managers.ToArray<WeakReference>())
            {
                if (wr.Target == null)
                {
                    DebugLogging.Log("ORNGRPCService removing WeakReference :" + wr);
                    managers.Remove(wr);
                }
                else if (((ORNGRPCService)wr.Target).match(guid, channel))
                {
                    retval = wr.Target as ORNGRPCService;
                }
            }
            return retval;
        }

        private bool match(Guid guid, string channel)
        {
            return guid.Equals(om.GetGuid()) && channels.Contains(channel);
        }

        public abstract string call(string channel, string opt_params);
    }

}