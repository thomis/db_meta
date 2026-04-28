require "spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe DbMeta::Oracle::Helper do
  let(:host) {
    Class.new { include DbMeta::Oracle::Helper }.new
  }

  describe "#block" do
    it "produces a 3-line title block" do
      output = host.block("Title", 10)
      expect(output.lines.size).to eq(3)
      expect(output).to include("-- Title")
      expect(output.lines.first.strip).to eq("-- -------")
    end
  end

  describe "#type_sequence" do
    it "returns 99 for unknown types" do
      expect(host.type_sequence("UNKNOWN_TYPE_XYZ")).to eq(99)
    end

    it "returns the configured sequence for a known type" do
      expect(host.type_sequence("TABLE")).to be_a(Integer)
      expect(host.type_sequence("TABLE")).not_to eq(99)
    end
  end

  describe "#pluralize" do
    it "returns the singular form for n=1" do
      expect(host.pluralize(1, "object")).to eq("object")
    end

    it "appends s for the default plural" do
      expect(host.pluralize(2, "object")).to eq("objects")
    end

    it "uses the explicit plural when given" do
      expect(host.pluralize(3, "child", "children")).to eq("children")
    end
  end

  describe "#write_buffer_to_file / #remove_folder / #create_folder" do
    let(:tmp) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmp) }

    it "writes a string buffer" do
      file = File.join(tmp, "out.txt")
      host.write_buffer_to_file("hello", file)
      expect(File.read(file)).to eq("hello")
    end

    it "joins an array buffer with newlines" do
      file = File.join(tmp, "out.txt")
      host.write_buffer_to_file(["a", "b"], file)
      expect(File.read(file)).to eq("a\nb")
    end

    it "creates and removes folders" do
      folder = File.join(tmp, "Some Folder")
      host.create_folder(folder)
      expect(Dir.exist?(folder.downcase.tr(" ", "_"))).to eq(true)
      host.remove_folder(folder.downcase.tr(" ", "_"))
      expect(Dir.exist?(folder.downcase.tr(" ", "_"))).to eq(false)
    end
  end
end
