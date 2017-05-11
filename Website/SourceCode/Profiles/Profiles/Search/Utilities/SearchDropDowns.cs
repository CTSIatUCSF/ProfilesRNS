using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using Profiles.Framework.Utilities;

namespace Profiles.Search.Utilities
{
    public static class SearchDropDowns
    {

        private static List<GenericListItem> GetList(string type)
        {
            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

            switch (type)
            {
                case "institution":
                    return data.GetInstitutions();

                case "department":
                    return data.GetDepartments();
                case "division":
                    return data.GetDivisions();
            }
            return null;
        }

        public static string GetDefaultItemValue(string type, string defaultitem)
        {
            List<GenericListItem> list = GetList(type);
            foreach (GenericListItem item in list)
            {       // Eric Meeks adding check for item.Text as well
                if (defaultitem == item.Value || defaultitem.Equals(item.Text))
                    return item.Value;
            }
            return null;
        }

        public static string BuildDropdown(string type, string width, string defaultitem)
        {
            string output = "<option value=\"\"></option>";

            List<GenericListItem> list = GetList(type);

            foreach (GenericListItem item in list)
            {       // Eric Meeks adding check for item.Text as well
                if (!defaultitem.IsNullOrEmpty() && (defaultitem == item.Value || defaultitem.Equals(item.Text)))
                    output += "<option selected=\"true\" value=\"" + item.Value + "\">" + item.Text + "</option>";
                else
                    output += "<option value=\"" + item.Value + "\">" + item.Text + "</option>";
            }

            return "<select title=\"" + type + "\" name=\"" + type + "\" id=\"" + type + "\" style=\"width:" + width + "px\">" + output + "</select>";

        }

    }

}
