# Copyright (c) 2013-2014 SUSE LLC
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact SUSE LLC.
#
# To contact SUSE about this file by physical or electronic mail,
# you may find current contact information at www.suse.com

require_relative "../spec_helper"
require File.join(Machinery::ROOT, "schema/migrations/migrate5to6.rb")

describe Migrate5To6 do
  initialize_system_description_factory_store

  let(:description_hash) {
    JSON.parse(<<-EOT)
      {
        "packages": [
          {
            "name": "aaa_base",
            "version": "13.1",
            "release": "16.17.1",
            "arch": "x86_64",
            "vendor": "openSUSE",
            "checksum": "542cc67d16b48ea0c37b32dfb02d913c"
          },
          {
            "name": "adjtimex",
            "version": "1.29",
            "release": "2.1.2",
            "arch": "x86_64",
            "vendor": "openSUSE",
            "checksum": "6fe8798263f38820e050b3912f41b2a4"
          },
          {
            "name": "autofs",
            "version": "5.0.7",
            "release": "19.1.1",
            "arch": "x86_64",
            "vendor": "openSUSE",
            "checksum": "4db96ab66a6398ae27ee24eb793659dd"
          }
        ],
        "meta": {
          "format_version": 5
        }
      }
    EOT
  }
  let(:description_base) { system_description_factory_store.description_path("description") }

  before(:each) do
    migration = Migrate5To6.new(description_hash, description_base)
    migration.migrate
  end

  describe "packages" do
    it "adds the 'package_system' attribute" do
      expect(description_hash["packages"]["package_system"]).to eq("rpm")
    end

    it "moves the packages to packages" do
      package_names = description_hash["packages"]["packages"].map { |package| package["name"] }
      expect(package_names).to eq(["aaa_base", "adjtimex", "autofs"])
    end
  end
end
