using System.Collections.Generic;

using Profiles.Framework.Utilities;

namespace Profiles.Search.Utilities
{
    public static class SearchDropDowns
    {

        private static List<GenericListItem> GetList(string type, Brand brand)
        {
            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

            switch (type)
            {
                case "institution":
                    return data.GetInstitutions(brand);

                case "department":
                    return data.GetBrandedItemsOfType("Departments", brand);
                case "division":
                    return data.GetBrandedItemsOfType("Divisions", brand);
            }
            return null;
        }

        public static string GetDefaultItemValue(string type, string defaultitem, Brand brand)
        {
            List<GenericListItem> list = GetList(type, brand);
            foreach (GenericListItem item in list)
            {       // Eric Meeks adding check for item.Text as well
                if (defaultitem == item.Value || defaultitem.Equals(item.Text))
                    return item.Value;
            }
            return null;
        }

        public static string BuildDropdown(string type, string width, string defaultitem, Brand brand)
        {
            string output = "<option value=\"\"></option>";

            List<GenericListItem> list = GetList(type, brand);

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
