//
//  Copyright (C) 2011 Robert Dyer, Rico Tzschichholz
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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Build
{
	public const string GETTEXT_PACKAGE;
	public const string PACKAGE;
	public const string PACKAGE_NAME;

	public const string DATADIR;
	public const string PKGDATADIR;

	public const string RELEASE_NAME;

	public const string VERSION;
	public const string VERSION_INFO;

	public const uint VERSION_MAJOR;
	public const uint VERSION_MINOR;
	public const uint VERSION_MICRO;
	public const uint VERSION_NANO;
}
