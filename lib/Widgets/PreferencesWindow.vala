//
//  Copyright (C) 2014 Rico Tzschichholz
//
//  This file is part of Plank.
//
//  Plank is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Plank is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank.Items;
using Plank.Drawing;
using Plank.Services;
using Plank.Services.Windows;

namespace Plank.Widgets
{
	public class PreferencesWindow : Gtk.Window
	{
		public DockPreferences prefs { get; construct; }
		
		Gtk.Builder? builder;
		
		Gtk.ComboBoxText cb_theme;
		Gtk.ComboBoxText cb_hidemode;
		Gtk.ComboBoxText cb_display_plug;
		Gtk.ComboBoxText cb_position;
		Gtk.ComboBoxText cb_alignment;
		Gtk.ComboBoxText cb_items_alignment;
		
		Gtk.SpinButton sp_hide_delay;
		Gtk.SpinButton sp_unhide_delay;
		Gtk.Scale s_offset;
		Gtk.Scale s_zoom_percent;
		
		Gtk.Adjustment adj_hide_delay;
		Gtk.Adjustment adj_unhide_delay;
		Gtk.Adjustment adj_iconsize;
		Gtk.Adjustment adj_offset;
		Gtk.Adjustment adj_zoom_percent;
		
		Gtk.Switch sw_hide;
		Gtk.Switch sw_primary_display;
		Gtk.Switch sw_workspace_only;
		Gtk.Switch sw_show_unpinned;
		Gtk.Switch sw_lock_items;
		Gtk.Switch sw_auto_pinning;
		Gtk.Switch sw_pressure_reveal;
		Gtk.Switch sw_show_dock_item;
		Gtk.Switch sw_zoom_enabled;
		
		public PreferencesWindow (DockPreferences prefs)
		{
			Object (prefs : prefs, type: Gtk.WindowType.TOPLEVEL, type_hint: Gdk.WindowTypeHint.DIALOG);
		}
		
		construct
		{
			skip_pager_hint = true;
			skip_taskbar_hint = true;
			title = _("Preferences");
			resizable = false;
			deletable = true;
			window_position = Gtk.WindowPosition.CENTER;
			gravity = Gdk.Gravity.CENTER;
			icon_name = "plank";
			
			try {
				builder = new Gtk.Builder ();
#if HAVE_GTK_3_10
				builder.add_from_resource ("%s/ui/preferences.ui".printf (Plank.G_RESOURCE_PATH));
				
				var headerbar = new Gtk.HeaderBar ();
				headerbar.show_close_button = true;
				headerbar.set_custom_title ((Gtk.Widget) builder.get_object ("dock_preferences_switcher"));
				headerbar.show ();
				set_titlebar (headerbar);
				
				var stack = (Gtk.Stack) builder.get_object ("dock_preferences");
				add (stack);
#else
				const string[] ids = { "grid_appearance", "grid_behaviour", "adj_hide_delay", "adj_iconsize", "adj_offset", "adj_unhide_delay" };
				builder.add_objects_from_resource ("%s/ui/preferences.ui".printf (Plank.G_RESOURCE_PATH), ids);
				
				var notebook = new Gtk.Notebook ();
				notebook.append_page ((Gtk.Widget) builder.get_object ("grid_appearance"), new Gtk.Label (_("Appearance")));
				notebook.append_page ((Gtk.Widget) builder.get_object ("grid_behaviour"), new Gtk.Label (_("Behaviour")));
				notebook.show ();
				add (notebook);
#endif
				
				cb_theme = builder.get_object ("cb_theme") as Gtk.ComboBoxText;
				cb_hidemode = builder.get_object ("cb_hidemode") as Gtk.ComboBoxText;
				cb_display_plug = builder.get_object ("cb_display_plug") as Gtk.ComboBoxText;
				cb_position = builder.get_object ("cb_position") as Gtk.ComboBoxText;
				sp_hide_delay = builder.get_object ("sp_hide_delay") as Gtk.SpinButton;
				sp_unhide_delay = builder.get_object ("sp_unhide_delay") as Gtk.SpinButton;
				adj_hide_delay = builder.get_object ("adj_hide_delay") as Gtk.Adjustment;
				adj_unhide_delay = builder.get_object ("adj_unhide_delay") as Gtk.Adjustment;
				adj_iconsize = builder.get_object ("adj_iconsize") as Gtk.Adjustment;
				adj_offset = builder.get_object ("adj_offset") as Gtk.Adjustment;
				adj_zoom_percent = builder.get_object ("adj_zoom_percent") as Gtk.Adjustment;
				s_offset = builder.get_object ("s_offset") as Gtk.Scale;
				s_zoom_percent = builder.get_object ("s_zoom_percent") as Gtk.Scale;
				sw_hide = builder.get_object ("sw_hide") as Gtk.Switch;
				sw_primary_display = builder.get_object ("sw_primary_display") as Gtk.Switch;
				sw_workspace_only = builder.get_object ("sw_workspace_only") as Gtk.Switch;
				sw_show_unpinned = builder.get_object ("sw_show_unpinned") as Gtk.Switch;
				sw_lock_items = builder.get_object ("sw_lock_items") as Gtk.Switch;
				sw_auto_pinning = builder.get_object ("sw_auto_pinning") as Gtk.Switch;
				sw_pressure_reveal = builder.get_object ("sw_pressure_reveal") as Gtk.Switch;
				sw_show_dock_item = builder.get_object ("sw_show_dock_item") as Gtk.Switch;
				sw_zoom_enabled = builder.get_object ("sw_zoom_enabled") as Gtk.Switch;
				cb_alignment = builder.get_object ("cb_alignment") as Gtk.ComboBoxText;
				cb_items_alignment = builder.get_object ("cb_items_alignment") as Gtk.ComboBoxText;
				
				init_dock_tab ();
 				connect_signals ();
			} catch (Error e) {
				builder = null;
				critical (e.message);
			}
		}
		
		public override bool key_press_event (Gdk.EventKey event)
		{
			if (event.keyval == Gdk.Key.Escape)
				hide ();
			
			return base.key_press_event (event);
		}
		
		void prefs_changed (Object o, ParamSpec prop)
		{
			switch (prop.name) {
			case "Alignment":
				cb_alignment.active_id = ((int) prefs.Alignment).to_string ();
				break;
			case "AutoPinning":
				sw_auto_pinning.set_active (prefs.AutoPinning);
				break;
			case "CurrentWorkspaceOnly":
				sw_workspace_only.set_active (prefs.CurrentWorkspaceOnly);
				break;
			case "IconSize":
				adj_iconsize.value = prefs.IconSize;
				break;
			case "ItemsAlignment":
				cb_items_alignment.active_id = ((int) prefs.ItemsAlignment).to_string ();
				break;
			case "HideMode":
				var hide_none = (prefs.HideMode != HideType.NONE);
				sw_hide.set_active (hide_none);
				if (!hide_none)
					cb_hidemode.active_id = ((int) prefs.HideMode).to_string ();
				break;
			case "LockItems":
				sw_lock_items.set_active (prefs.LockItems);
				break;
			case "Monitor":
				var pos = 0;
				foreach (unowned string plug_name in Plank.PositionManager.get_monitor_plug_names (get_screen ())) {
					if (plug_name == prefs.Monitor)
						cb_display_plug.set_active (pos);
					pos++;
				}
				break;
			case "Offset":
				adj_offset.value = prefs.Offset;
				break;
			case "PinnedOnly":
				sw_show_unpinned.set_active (!prefs.PinnedOnly);
				break;
			case "Position":
				cb_position.active_id = ((int) prefs.Position).to_string ();
				break;
			case "PressureReveal":
				sw_pressure_reveal.set_active (prefs.PressureReveal);
				break;
			case "ShowDockItem":
				sw_show_dock_item.set_active (prefs.ShowDockItem);
				break;
			case "Theme":
				var pos = 0;
				foreach (unowned string theme in Plank.Drawing.Theme.get_theme_list ()) {
					if (theme == prefs.Theme)
						cb_theme.set_active (pos);
					pos++;
				}
				break;
			case "HideDelay":
				adj_hide_delay.value = prefs.HideDelay;
				break;
			case "UnhideDelay":
				adj_unhide_delay.value = prefs.UnhideDelay;
				break;
			case "ZoomEnabled":
				sw_zoom_enabled.set_active (prefs.ZoomEnabled);
				break;
			case "ZoomPercent":
				adj_zoom_percent.value = prefs.ZoomPercent;
				break;
			// Ignored settings
			case "DockItems":
				break;
			default:
				warning ("%s not supported", prop.name);
				break;
			}
			
		}
		
		void cb_theme_changed (Gtk.ComboBox widget)
		{
			prefs.Theme = ((Gtk.ComboBoxText) widget).get_active_text ();
		}
		
		void cb_hidemode_changed (Gtk.ComboBox widget)
		{
			prefs.HideMode = (HideType) int.parse (widget.get_active_id ());
		}
		
		void cb_position_changed (Gtk.ComboBox widget)
		{
			prefs.Position = (Gtk.PositionType) int.parse (widget.get_active_id ());
		}
		
		void cb_alignment_changed (Gtk.ComboBox widget)
		{
			prefs.Alignment = (Gtk.Align) int.parse (widget.get_active_id ());
			cb_items_alignment.sensitive = (prefs.Alignment == Gtk.Align.FILL);
			s_offset.sensitive = (prefs.Alignment == Gtk.Align.CENTER);
		}
		
		void cb_items_alignment_changed (Gtk.ComboBox widget)
		{
			prefs.ItemsAlignment = (Gtk.Align) int.parse (widget.get_active_id ());
		}
		
		void hide_toggled (GLib.Object widget, ParamSpec param)
		{
			if (((Gtk.Switch) widget).get_active ()) {
				prefs.HideMode = HideType.INTELLIGENT;
				cb_hidemode.sensitive = true;
				sp_hide_delay.sensitive = true;
				sp_unhide_delay.sensitive = true;
				sw_pressure_reveal.sensitive = true;
			} else {
				prefs.HideMode = HideType.NONE;
				cb_hidemode.sensitive = false;
				sp_hide_delay.sensitive = false;
				sp_unhide_delay.sensitive = false;
				sw_pressure_reveal.sensitive = false;
			}
		}
		
		void primary_display_toggled (GLib.Object widget, ParamSpec param)
		{
			if (((Gtk.Switch) widget).get_active ()) {
				prefs.Monitor = "";
				cb_display_plug.sensitive = false;
			} else {
				prefs.Monitor = cb_display_plug.get_active_text ();
				cb_display_plug.sensitive = true;
			}
		}
		
		void workspace_only_toggled (GLib.Object widget, ParamSpec param)
		{
			prefs.CurrentWorkspaceOnly = ((Gtk.Switch) widget).get_active ();
		}
		
		void show_unpinned_toggled (GLib.Object widget, ParamSpec param)
		{
			prefs.PinnedOnly = !((Gtk.Switch) widget).get_active ();
		}
		
		void lock_items_toggled (GLib.Object widget, ParamSpec param)
		{
			prefs.LockItems = ((Gtk.Switch) widget).get_active ();
		}
		
		void auto_pinning_toggled (GLib.Object widget, ParamSpec param)
		{
			prefs.AutoPinning = ((Gtk.Switch) widget).get_active ();
		}
		
		void pressure_reveal_toggled (GLib.Object widget, ParamSpec param)
		{
			prefs.PressureReveal = ((Gtk.Switch) widget).get_active ();
		}
		
		void show_dock_item_toggled (GLib.Object widget, ParamSpec param)
		{
			prefs.ShowDockItem = ((Gtk.Switch) widget).get_active ();
		}
		
		void zoom_enabled_toggled (GLib.Object widget, ParamSpec param)
		{
			if (((Gtk.Switch) widget).get_active ()) {
				prefs.ZoomEnabled = true;
				s_zoom_percent.sensitive = true;
			} else {
				prefs.ZoomEnabled = false;
				s_zoom_percent.sensitive = false;
			}
		}
		
		void iconsize_changed (Gtk.Adjustment adj)
		{
			prefs.IconSize = (int) adj.value;
		}
		
		void offset_changed (Gtk.Adjustment adj)
		{
			prefs.Offset = (int) adj.value;
		}
		
		void hide_delay_changed (Gtk.Adjustment adj)
		{
			prefs.HideDelay = (int) adj.value;
		}
		
		void unhide_delay_changed (Gtk.Adjustment adj)
		{
			prefs.UnhideDelay = (int) adj.value;
		}
		
		void zoom_percent_changed (Gtk.Adjustment adj)
		{
			prefs.ZoomPercent = (int) adj.value;
		}
		
		void monitor_changed (Gtk.ComboBox widget)
		{
			prefs.Monitor = ((Gtk.ComboBoxText) widget).get_active_text ();
		}
		
		void connect_signals ()
		{
			prefs.notify.connect (prefs_changed);
			
			cb_theme.changed.connect (cb_theme_changed);
			cb_hidemode.changed.connect (cb_hidemode_changed);
			cb_position.changed.connect (cb_position_changed);
			adj_hide_delay.value_changed.connect (hide_delay_changed);
			adj_unhide_delay.value_changed.connect (unhide_delay_changed);
			cb_display_plug.changed.connect (monitor_changed);
			adj_iconsize.value_changed.connect (iconsize_changed);
			adj_offset.value_changed.connect (offset_changed);
			adj_zoom_percent.value_changed.connect (zoom_percent_changed);
			sw_hide.notify["active"].connect (hide_toggled);
			sw_primary_display.notify["active"].connect (primary_display_toggled);
			sw_workspace_only.notify["active"].connect (workspace_only_toggled);
			sw_show_unpinned.notify["active"].connect (show_unpinned_toggled);
			sw_lock_items.notify["active"].connect (lock_items_toggled);
			sw_auto_pinning.notify["active"].connect (auto_pinning_toggled);
			sw_pressure_reveal.notify["active"].connect (pressure_reveal_toggled);
			sw_show_dock_item.notify["active"].connect (show_dock_item_toggled);
			sw_zoom_enabled.notify["active"].connect (zoom_enabled_toggled);
			cb_alignment.changed.connect (cb_alignment_changed);
			cb_items_alignment.changed.connect (cb_items_alignment_changed);
		}
		
		void init_dock_tab ()
		{
			var pos = 0;
			foreach (unowned string theme in Plank.Drawing.Theme.get_theme_list ()) {
				cb_theme.append ("%i".printf (pos), theme);
				if (theme == prefs.Theme)
					cb_theme.set_active (pos);
				pos++;
			}

			cb_hidemode.active_id = ((int) prefs.HideMode).to_string ();
			cb_hidemode.sensitive = (prefs.HideMode != HideType.NONE);
			cb_position.active_id = ((int) prefs.Position).to_string ();
			adj_hide_delay.value = prefs.HideDelay;
			adj_unhide_delay.value = prefs.UnhideDelay;

			pos = 0;
			foreach (unowned string plug_name in Plank.PositionManager.get_monitor_plug_names (get_screen ())) {
				cb_display_plug.append ("%i".printf (pos), plug_name);
				if (plug_name == prefs.Monitor)
					cb_display_plug.set_active (pos);
				pos++;
			}
			if (prefs.Monitor == "")
				cb_display_plug.set_active (0);
			cb_display_plug.sensitive = (prefs.Monitor != "");
			
			sp_hide_delay.sensitive = (prefs.HideMode != HideType.NONE);
			sp_unhide_delay.sensitive = (prefs.HideMode != HideType.NONE);
			
			adj_iconsize.value = prefs.IconSize;
			adj_offset.value = prefs.Offset;
			adj_zoom_percent.value = prefs.ZoomPercent;
			s_offset.sensitive = (prefs.Alignment == Gtk.Align.CENTER);
			s_zoom_percent.sensitive = prefs.ZoomEnabled;
			sw_hide.set_active (prefs.HideMode != HideType.NONE);
			sw_primary_display.set_active (prefs.Monitor == "");
			sw_workspace_only.set_active (prefs.CurrentWorkspaceOnly);
			sw_show_unpinned.set_active (!prefs.PinnedOnly);
			sw_lock_items.set_active (prefs.LockItems);
			sw_auto_pinning.set_active (prefs.AutoPinning);
			sw_pressure_reveal.set_active (prefs.PressureReveal);
			sw_show_dock_item.set_active (prefs.ShowDockItem);
			sw_zoom_enabled.set_active (prefs.ZoomEnabled);
			cb_alignment.active_id = ((int) prefs.Alignment).to_string ();
			cb_items_alignment.active_id = ((int) prefs.ItemsAlignment).to_string ();
			cb_items_alignment.sensitive = (prefs.Alignment == Gtk.Align.FILL);
		}
	}
}
